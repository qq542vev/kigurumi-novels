#!/usr/bin/gmake -f

THREADS = $(shell awk -- '{ split("html csv rdf", e); for(i = 1; i in e; i++) { printf("docs/src/%s/%s.%s\n", e[i], $$1, e[i]); }; }' threads.tsv)
NOVELS = $(shell find docs/novel -name 'index.rdf' -exec dirname '{}' ';' | xargs -I '{ARG}' printf '%s\n' '{ARG}' '{ARG}/index.html' '{ARG}/index.txt')
TMP = TMPFILE
BASEURL = https://qq542vev.github.io/kigurumi-novels/

.PRECIOUS: docs/src/csv/%.rdf docs/src/csv/%.csv docs/src/html/%.html

.PHONY: all program thread novel

all: program thread novel docs/index.html

program:

thread: ${THREADS}

novel: ${NOVELS}

docs/index.html: docs/sitemap.xml docs/xsl/sitemap2index.xsl
	xmlstarlet tr docs/xsl/sitemap2index.xsl $< >$@

docs/sitemap.xml: $(shell find docs '!' '(' -path 'docs/sitemap.xml' -o -path 'docs/index.html' ')' -a -type f)
	gensitemap -b ${BASEURL} -i index.html docs | xmlstarlet fo -t >$@

docs/novel/%: docs/novel/%/index.rdf docs/xsl/novelrdf.xsl
	xmlstarlet tr docs/xsl/novelrdf.xsl $< | xmlstarlet fo -t - >${TMP}
	mv -f -- ${TMP} $<

docs/novel/%/index.html: docs/novel/%/index.rdf docs/xsl/rdf2html.xsl
	xmlstarlet tr docs/xsl/rdf2html.xsl $< >$@

docs/novel/%/index.txt: docs/novel/%/index.rdf docs/xsl/rdf2text.xsl
	xmlstarlet tr docs/xsl/rdf2text.xsl $< >$@

docs/src/rdf/%.rdf: docs/src/csv/%.csv bin/csv2sioc.sh
	awk -v id=$* -v dep=$< -- '$$1 == id { system(sprintf("bin/csv2sioc.sh \"%s\" \"%s\" \"%s\"", dep, $$2, $$3, $$4)); }' threads.tsv >$@

docs/src/csv/%.csv: docs/src/html/%.html bin/thread2csv.sh
	bin/thread2csv.sh $< >$@

docs/src/html/%.html:
	awk -v id=$* -- '$$1 == id { system(sprintf("wget --no-config -O - \"%s\"", $$2)); }' threads.csv >$@

#bin/%.sh: src/%.sh src/%.awk
#	cuktash $< >$@

#bin/%.awk: src/%.awk
#	cuktash $< >$@
