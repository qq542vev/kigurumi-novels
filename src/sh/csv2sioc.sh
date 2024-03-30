#!/usr/bin/env sh

# @cuktash sh-use cuktash/str/replace * str_

awkScript=$(
	cat <<-'__EOF__'
	# @cuktash use-block begin
	# @cuktash awk-use cuktash/csv/parse * csv_
	# @cuktash awk-use cuktash/str/sanitize * str_
	# @cuktash awk-use cuktash/xml/gen/element *
	# @cuktash use-block end

	BEGIN {
		csv_parse("<" ARGV[1], array)

		for(i = 1; (i, 1) in array; i++) {
			if(array[i, 4] != "") {
				post = element("rdfs:label", "rdf:datatype=\"&xsd;positiveInteger\"", array[i, 1])

				creator = element("foaf:nick", (array[i, 2] == "名無しさん@着ぐるみすと" ? "xml:lang=\"ja\"" : "rdf:datatype=\"&xsd;string\""), str_sanitize(array[i, 2]))

				if(array[i, 3] != "") {
					creator = creator element("dcterms:identifier", "rdf:datatype=\"&xsd;string\"", array[i, 3])
				}

				post = post element("dcterms:creator", "rdf:parseType=\"Resource\"", creator, 0)
				post = post element("sioc:delivered_at", "rdf:datatype=\"&dcterms;W3CDTF\"", array[i, 4])
				post = post element("sioc:content", "xml:lang=\"ja\"", str_sanitize(array[i, 5], "\t\n"))
				printf("%s", element("types:BoardPost", "rdf:about=\"&post;" array[i, 1] "\"", post, 0))
			}
		}
	}
	__EOF__
)
template=$(
	cat <<-__EOF__
	<?xml version="1.0" encoding="UTF-8"?>
	<!DOCTYPE rdf:RDF [
		<!ENTITY dcterms "http://purl.org/dc/terms/">
		<!ENTITY xsd "http://www.w3.org/2001/XML_Schema#">
		<!ENTITY board "${3}">
		<!ENTITY post "&board;${4}">
	]>
	<rdf:RDF
		xmlns:dcterms="http://purl.org/dc/terms/"
		xmlns:foaf="http://xmlns.com/foaf/0.1/"
		xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
		xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
		xmlns:schema="https://schema.org/"
		xmlns:sioc="http://rdfs.org/sioc/ns#"
		xmlns:types="http://rdfs.org/sioc/types#"
	>
		<foaf:Document rdf:about="">
			<dcterms:modified rdf:datatype="&dcterms;W3CDTF">$(date +%Y-%m-%dT%H:%M:%S+09:00)</dcterms:modified>
			<foaf:primaryTopic rdf:nodeID="main"/>
		</foaf:Document>

		<types:MessageBoard rdf:about="&board;">
			<dcterms:title>${2}</dcterms:title>
		</types:MessageBoard>

		<!-- !CONTENT! -->
	</rdf:RDF>
	__EOF__
)

str_replace 'x' "${template}" '<!-- !CONTENT! -->' "$(awk -- "${awkScript}" "${1}")"
printf '%s' "${x}" | xmlstarlet fo -t -
