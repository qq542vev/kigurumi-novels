#!/usr/bin/gmake -f

# Macro
# =====

THREAD_FILE = threads.tsv
THREAD_ID = cut -d "	" -f 1 -- ${THREAD_FILE}
THREAD_DIR = docs/thread
NOVEL_DIR = docs/novel
XSL_DIR = docs/xsl
CSS_DIR = docs/css
TMP = TMPFILE
BASEURL = https://qq542vev.github.io/kigurumi-novels/

#.PRECIOUS: docs/src/csv/%.rdf docs/src/csv/%.csv docs/src/html/%.html

.PHONY: all program thread novel help

all: program thread novel docs/index.html

docs/index.html: docs/sitemap.xml ${XSL_DIR}/sitemap2index.xsl ${CSS_DIR}/normalize.css
	xmlstarlet tr ${XSL_DIR}/sitemap2index.xsl $< >$@

docs/sitemap.xml: $(shell find docs '!' '(' -path 'docs/sitemap.xml' -o -path 'docs/index.html' ')' -a -type f)
	gensitemap -b ${BASEURL} -i index.html docs | xmlstarlet fo -t >$@

# Message
# =======

help:
	@echo ''
	@echo ''
	@echo ''
	@echo ''
	@echo ''

version:
	@echo ''

# Novel
# =====

novel: $(shell find ${NOVEL_DIR} -name 'index.rdf' -exec dirname '{}' ';' | xargs -I '{ARG}' printf '%s\n' '{ARG}' '{ARG}/index.html' '{ARG}/index.txt')

${NOVEL_DIR}/%/index.html: ${NOVEL_DIR}/%/index.rdf ${XSL_DIR}/rdf2html.xsl ${CSS_DIR}/normalize.css
	xmlstarlet tr ${XSL_DIR}/rdf2html.xsl $< >$@

${NOVEL_DIR}/%/index.txt: ${NOVEL_DIR}/%/index.rdf ${XSL_DIR}/rdf2text.xsl
	xmlstarlet tr ${XSL_DIR}/rdf2text.xsl $< >$@

${NOVEL_DIR}/%: ${NOVEL_DIR}/%/index.rdf ${XSL_DIR}/novelrdf.xsl
	xmlstarlet tr ${XSL_DIR}/novelrdf.xsl $< | xmlstarlet fo -t - >${TMP}
	mv -f -- ${TMP} $<

${XSL_DIR}/novelrdf.xsl: $(shell ${THREAD_ID} | xargs printf '${THREAD_DIR}/%s/index.rdf\n')

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

program:

#bin/%.sh: src/%.sh src/%.awk
#	cuktash $< >$@

#bin/%.awk: src/%.awk
#	cuktash $< >$@

# CSS
# ===

${CSS_DIR}/normalize.css: node_modules/normalize.css/normalize.css
	cp -f -- $< $@

node_modules/normalize.css/normalize.css
	npm install normalize.css 
