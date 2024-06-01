#!/usr/bin/env sh



### Function: CUKTASH_cuktash__str_replace
##
## 一致した部分文字列を置換する。
##
## Synopsis:
##
##   > CUKTASH_cuktash__str_replace variable string from [to] [count]
##
## Operands:
##
##   variable - 結果を代入する変数名。'-' で結果を標準出力する。
##   string   - 対象の文字列。
##   from     - 置換前の文字列。
##   to       - 置換後の文字列。
##   count    - 最大置換回数。

CUKTASH_cuktash__str_replace() {
	set -- "${1}" "${2}" "${3}" "${4-}" "${5:--1}" ''

	until [ "${2}" = "${2#*"${3}"}" ] || [ "${5}" -eq '0' ]; do
		set -- "${1}" "${2#*"${3}"}" "${3}" "${4}" "$((${5} - 1))" "${6}${2%%"${3}"*}${4}"
	done

	case "${1}" in
		'-') printf '%s' "${6}${2}";;
		*) eval "${1}=\${6}\${2}";;
	esac
}
if command -v -- 'CUKTASH_cuktash__str_replace' >'/dev/null' 2>&1; then alias 'str_replace=CUKTASH_cuktash__str_replace'; fi
case "${CUKTASH_cuktash__str_replace+1}" in 1) readonly str_replace="${CUKTASH_cuktash__str_replace}";; esac

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
