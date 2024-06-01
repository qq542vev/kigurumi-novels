#!/usr/bin/gmake -f

# Macro
# =====

VERSION = 1.0.1
THREAD_FILE = threads.tsv
THREAD_ID = cut -d "	" -f 1 -- ${THREAD_FILE}
THREAD_DIR = docs/thread
NOVEL_DIR = docs/novel
XSL_DIR = docs/xsl
CSS_DIR = docs/css
TMP = TMPFILE
BASEURL = https://qq542vev.github.io/kigurumi-novels/

.PHONY: all program thread novel index clean help version

all: program thread novel index

# Index
# =====

index: docs/sitemap.xml docs/index.html

docs/index.html: docs/sitemap.xml ${XSL_DIR}/sitemap2index.xsl
	xmlstarlet tr ${XSL_DIR}/sitemap2index.xsl $< >$@

docs/sitemap.xml: $(shell find docs '!' '(' -path 'docs/sitemap.xml' -o -path 'docs/index.html' ')' -a -type f)
	gensitemap -b ${BASEURL} -i index.html docs | xmlstarlet fo -t >$@

# Novel
# =====

novel: $(shell find ${NOVEL_DIR} -name 'index.rdf' -exec dirname '{}' ';' | xargs -I '{ARG}' printf '%s\n' '{ARG}' '{ARG}/index.html' '{ARG}/index.txt')

${NOVEL_DIR}/%/index.html: ${NOVEL_DIR}/%/index.rdf ${XSL_DIR}/rdf2html.xsl
	xmlstarlet tr ${XSL_DIR}/rdf2html.xsl $< >$@

${NOVEL_DIR}/%/index.txt: ${NOVEL_DIR}/%/index.rdf ${XSL_DIR}/rdf2text.xsl
	xmlstarlet tr ${XSL_DIR}/rdf2text.xsl $< >$@

${NOVEL_DIR}/%: ${NOVEL_DIR}/%/index.rdf ${XSL_DIR}/novelrdf.xsl
	xmlstarlet tr ${XSL_DIR}/novelrdf.xsl $< | xmlstarlet fo -t - >${TMP}
	mv -f -- ${TMP} $<

# Thread
# ======

thread: $(shell ${THREAD_ID} | xargs -I '{ARG}' printf '${THREAD_DIR}/%s/index.%s\n' '{ARG}' 'html' '{ARG}' 'csv' '{ARG}' 'rdf')

${THREAD_DIR}/%/index.rdf: ${THREAD_DIR}/%/index.csv bin/csv2sioc.sh
	awk -F '\t' -v id=$* -v dep=$< -- '$$1 == id { system(sprintf("bin/csv2sioc.sh \"%s\" \"%s\" \"%s\" \"%s\"", dep, $$4, $$2, $$3)); }' ${THREAD_FILE} >$@

${THREAD_DIR}/%/index.csv: ${THREAD_DIR}/%/index.html bin/thread2csv.sh
	bin/thread2csv.sh $< >$@

${THREAD_DIR}/%/index.html:
	mkdir -p -- ${@D}
	awk -v id=$* -- '$$1 == id { system(sprintf("wget --no-config -O - \"%s\"", $$2)); }' ${THREAD_FILE} >$@

# Program
# =======

program: $(shell find src -type f | sed -e 's/^src/bin/')

bin/%: src/%
	mkdir -p -- ${@D}
	cuktash $< >$@

# XSLT
# ====

${XSL_DIR}/sitemap2index.xsl: ${XSL_DIR}/template-html.xsl

${XSL_DIR}/rdf2html.xsl: ${XSL_DIR}/template-html.xsl

${XSL_DIR}/novelrdf.xsl: $(shell ${THREAD_ID} | xargs printf '${THREAD_DIR}/%s/index.rdf\n')

${XSL_DIR}/template-html.xsl: ${XSL_DIR}/param.xsl

# CSS
# ===

${CSS_DIR}/normalize.css: node_modules/normalize.css/normalize.css
	cp -f -- $< $@

# Clean
# =====

clean:
	rm -rf -- 'docs/index.html' 'docs/sitemap.xml' '${CSS_DIR}/normalize.css'
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
	@echo 'clean   作成したファイルを削除する。'
	@echo 'help    このメッセージを表示する。'
	@echo 'version バージョン情報を表示する。'

version:
	@echo ${VERSION}
