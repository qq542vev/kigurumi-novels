#!/usr/bin/env sh

# @cuktash sh-use cuktash/str/replace * str_

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
			<foaf:primaryTopic rdf:nodeID="&board;"/>
		</foaf:Document>

		<!-- !CONTENT! -->
	</rdf:RDF>
	__EOF__
)

str_replace - "${template}" '<!-- !CONTENT! -->' "$(awk -f "${0%/*}/csv2sioc.awk" -- "${1}" "${2}")" | xmlstarlet fo -t -
