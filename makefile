#!/usr/bin/gmake -f

# Macro
# =====

VERSION = 1.0.3
THREAD_FILE = threads.tsv
THREAD_ID = cut -d "	" -f 1 -- ${THREAD_FILE}
BIN_DIR = bin
SRC_DIR = src
DOC_DIR = docs
THREAD_DIR = ${DOC_DIR}/thread
NOVEL_DIR = ${DOC_DIR}/novel
XSL_DIR = ${DOC_DIR}/xsl
CSS_DIR = ${DOC_DIR}/css
TMP = TMPFILE
BASEURL = https://qq542vev.github.io/kigurumi-novels/

.PHONY: all css program thread novel index clean help version

all: css program thread novel index

# Index
# =====

index: ${DOC_DIR}/sitemap.xml ${DOC_DIR}/index.html

${DOC_DIR}/index.html: ${DOC_DIR}/sitemap.xml ${XSL_DIR}/sitemap2index.xsl
	xmlstarlet tr ${XSL_DIR}/sitemap2index.xsl $< >$@

${DOC_DIR}/sitemap.xml: $(shell find ${DOC_DIR} '!' '(' -path '${DOC_DIR}/sitemap.xml' -o -path '${DOC_DIR}/index.html' ')' -type f)
	gensitemap -b ${BASEURL} -i index.html docs | xmlstarlet fo -t >$@

# Novel
# =====

novel: $(shell find ${NOVEL_DIR} -name 'index.rdf' -exec dirname '{}' ';' | xargs -I '{}' printf '%s\n' '{}' '{}/index.html' '{}/index.txt')

${NOVEL_DIR}/%/index.html: ${NOVEL_DIR}/%/index.rdf ${XSL_DIR}/rdf2html.xsl
	xmlstarlet tr ${XSL_DIR}/rdf2html.xsl $< >$@

${NOVEL_DIR}/%/index.txt: ${NOVEL_DIR}/%/index.rdf ${XSL_DIR}/rdf2text.xsl
	xmlstarlet tr ${XSL_DIR}/rdf2text.xsl $< >$@

${NOVEL_DIR}/%: ${NOVEL_DIR}/%/index.rdf ${XSL_DIR}/novelrdf.xsl
	xmlstarlet tr ${XSL_DIR}/novelrdf.xsl $< | xmlstarlet fo -t - >${TMP}
	mv -f -- ${TMP} $<

# Thread
# ======

thread: $(shell ${THREAD_ID} | xargs -I '{}' printf '${THREAD_DIR}/%s/index.%s\n' '{}' 'html' '{}' 'csv' '{}' 'rdf')

${THREAD_DIR}/%/index.rdf: ${THREAD_DIR}/%/index.csv ${BIN_DIR}/csv2sioc.sh
	awk -F '\t' -v id=$* -v dep=$< -- '$$1 == id { system(sprintf("${BIN_DIR}/csv2sioc.sh \"%s\" \"%s\" \"%s\" \"%s\"", dep, $$2, $$3, $$4)); }' ${THREAD_FILE} >$@

${THREAD_DIR}/%/index.csv: ${THREAD_DIR}/%/index.html ${BIN_DIR}/thread2csv.sh
	${BIN_DIR}/thread2csv.sh $< >$@

${THREAD_DIR}/%/index.html:
	mkdir -p -- ${@D}
	awk -v id=$* -- '$$1 == id { system(sprintf("wget --no-config -O - \"%s\"", $$2)); }' ${THREAD_FILE} >$@

# Program
# =======

program: $(shell ls ${SRC_DIR} | xargs -I '{}' printf '%s/%s\n' ${BIN_DIR} '{}')

${BIN_DIR}/%: ${SRC_DIR}/%
	mkdir -p -- ${@D}
	cuktash $< >$@
	chmod -- 755 $@

# XSLT
# ====

${XSL_DIR}/sitemap2index.xsl: ${XSL_DIR}/template-html.xsl

${XSL_DIR}/rdf2html.xsl: ${XSL_DIR}/template-html.xsl

${XSL_DIR}/novelrdf.xsl: $(shell ${THREAD_ID} | xargs printf '${THREAD_DIR}/%s/index.rdf\n')

${XSL_DIR}/template-html.xsl: ${XSL_DIR}/param.xsl

# CSS
# ===

css: ${CSS_DIR}/normalize.css

${CSS_DIR}/normalize.css: node_modules/normalize.css/normalize.css
	cp -f -- $< $@

# Clean
# =====

clean:
	rm -rf -- '${BIN_DIR}' '${DOC_DIR}/index.html' '${DOC_DIR}/sitemap.xml' '${CSS_DIR}/normalize.css'
	${THREAD_ID} | xargs -I '{ARG}' rm -rf -- '${THREAD_DIR}/{ARG}'
	find ${NOVEL_DIR} '(' -name 'index.html' -o -name 'index.txt' ')' -type f -exec rm -f '{}' '+'

# Message
# =======

help:
	@echo 'all     全てのファイルを作成する。'
	@echo 'index   インデックスファイルを作成する。'
	@echo 'novel   小説を作成する。'
	@echo 'thread  スレッドを作成する。'
	@echo 'program プログラムを作成する。'
	@echo 'css     CSSファイルを作成する。'
	@echo 'clean   作成したファイルを削除する。'
	@echo 'help    このメッセージを表示する。'
	@echo 'version バージョン情報を表示する。'

version:
	@echo ${VERSION}
