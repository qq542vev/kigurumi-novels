<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE xsl:stylesheet [
	<!ENTITY dir "../thread">
	<!ENTITY file "index.rdf">
]>
<xsl:stylesheet
	version="1.0"
	xmlns:dcterms="http://purl.org/dc/terms/"
	xmlns:foaf="http://xmlns.com/foaf/0.1/"
	xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
	xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
	xmlns:schema="https://schema.org/"
	xmlns:sioc="http://rdfs.org/sioc/ns#"
	xmlns:types="http://rdfs.org/sioc/types#"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
>
	<xsl:import href="param.xsl"/>

	<xsl:output
		version="1.0"
		method="xml"
		indent="no"
		encoding="UTF-8"
		media-type="application/rdf+xml"
	/>

	<rdfs:Container rdf:about="#threads">
		<rdfs:member rdf:resource="&dir;/1067870090/&file;"/>
		<rdfs:member rdf:resource="&dir;/1081325649/&file;"/>
		<rdfs:member rdf:resource="&dir;/1122950720/&file;"/>
		<rdfs:member rdf:resource="&dir;/1184654919/&file;"/>
		<rdfs:member rdf:resource="&dir;/1211041119/&file;"/>
		<rdfs:member rdf:resource="&dir;/1247437212/&file;"/>
		<rdfs:member rdf:resource="&dir;/1359121685/&file;"/>
		<rdfs:member rdf:resource="&dir;/1360227486/&file;"/>
	</rdfs:Container>

	<xsl:variable name="xsd">http://www.w3.org/2001/XML_Schema#</xsl:variable>

	<xsl:param name="threads" select="document(document('')/xsl:stylesheet/rdfs:Container[@rdf:about='#threads']/rdfs:member/@rdf:resource)"/>
	<xsl:param name="posts" select="$threads/rdf:RDF/*[@rdf:about]"/>

	<xsl:template match="/">
		<xsl:processing-instruction name="xml-stylesheet">href="<xsl:value-of select="$base-url"/>xsl/rdf2html.xsl" type="application/xslt+xml" title="XHTML" alternate="yes"</xsl:processing-instruction>
		<xsl:processing-instruction name="xml-stylesheet">href="<xsl:value-of select="$base-url"/>xsl/rdf2text.xsl" type="application/xslt+xml" title="Plain Text" alternate="yes"</xsl:processing-instruction>

		<xsl:apply-templates select="*"/>
	</xsl:template>

	<xsl:template match="sioc:Container[@rdf:about='#main']">
		<xsl:variable name="first-item" select="$posts[@rdf:about=current()/dcterms:hasPart/*[1]/@rdf:about]"/>
		<xsl:variable name="last-item" select="$posts[@rdf:about=current()/dcterms:hasPart/*[last()]/@rdf:about]"/>
		<xsl:variable name="content">
			<xsl:for-each select="dcterms:hasPart/*/@rdf:about">
				<xsl:value-of select="$posts[@rdf:about=current()]/sioc:content"/>
			</xsl:for-each>
		</xsl:variable>

		<xsl:copy>
			<xsl:apply-templates select="@* | dcterms:identifier | dcterms:title | dcterms:alternative | schema:creativeWorkStatus | dcterms:hasPart"/>

			<dcterms:created>
				<xsl:apply-templates select="$first-item/sioc:delivered_at/@* | $first-item/sioc:delivered_at/node()"/>
			</dcterms:created>

			<sioc:last_activity_date>
				<xsl:apply-templates select="$last-item/sioc:delivered_at/@* | $last-item/sioc:delivered_at/node()"/>
			</sioc:last_activity_date>

			<dcterms:extent rdf:parseType="Resource">
				<rdfs:label xml:lang="ja">非空白文字数</rdfs:label>
				<rdf:value rdf:datatype="{$xsd}nonNegativeInteger">
					<xsl:value-of select="string-length(translate($content, '&#x9;&#xA;&#xD; 　', ''))"/>
				</rdf:value>
			</dcterms:extent>

			<sioc:num_items rdf:datatype="{$xsd}nonNegativeInteger">
				<xsl:value-of select="count(dcterms:hasPart/*[@rdf:about])"/>
			</sioc:num_items>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="dcterms:hasPart[@rdf:parseType='Collection']/*[@rdf:about]">
		<xsl:apply-templates select="$posts[@rdf:about=current()/@rdf:about]"/>
	</xsl:template>

	<xsl:template match="@* | node()">
		<xsl:copy>
			<xsl:apply-templates select="@* | node()"/>
		</xsl:copy>
	</xsl:template>
</xsl:stylesheet>
