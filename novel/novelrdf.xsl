<?xml version="1.0" encoding="UTF-8"?>
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
	<xsl:output
		version="1.0"
		method="xml"
		indent="yes"
		encoding="UTF-8"
		media-type="application/rdf+xml"
	/>

	<xsl:variable name="xsd">http://www.w3.org/2001/XML_Schema#</xsl:variable>

	<xsl:variable name="t1" select="document('../src/rdf/1067870090.rdf')"/>
	<xsl:variable name="t2" select="document('../src/rdf/1081325649.rdf')"/>
	<xsl:variable name="t3" select="document('../src/rdf/1122950720.rdf')"/>
	<xsl:variable name="t4" select="document('../src/rdf/1184654919.rdf')"/>
	<xsl:variable name="t5" select="document('../src/rdf/1211041119.rdf')"/>
	<xsl:variable name="t6" select="document('../src/rdf/1247437212.rdf')"/>
	<xsl:variable name="posts" select="($t1 | $t2 | $t3 | $t4 | $t5 | $t6)/rdf:RDF/*[@rdf:about]"/>

	<xsl:template match="foaf:Document[@rdf:nodeID='main']">
			<xsl:variable name="first-item" select="$posts[@rdf:about=current()/dcterms:hasPart/*[1]/@rdf:about]"/>
			<xsl:variable name="last-item" select="$posts[@rdf:about=current()/dcterms:hasPart/*[last()]/@rdf:about]"/>
		<xsl:variable name="content">
			<xsl:for-each select="dcterms:hasPart/*/@rdf:about">
				<xsl:value-of select="$posts[@rdf:about=current()]/sioc:content"/>
			</xsl:for-each>
		</xsl:variable>

		<xsl:copy>
			<xsl:apply-templates select="@* | dcterms:title | dcterms:alternative | schema:creativeWorkStatus | dcterms:hasPart"/>

			<dcterms:created>
				<xsl:apply-templates select="$first-item/sioc:delivered_at/@* | $first-item/sioc:delivered_at/node()"/>
			</dcterms:created>

			<sioc:last_activity_date>
				<xsl:apply-templates select="$last-item/sioc:delivered_at/@* | $last-item/sioc:delivered_at/node()"/>
			</sioc:last_activity_date>
			
			<dcterms:extent rdf:parsetype="Resource">
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
		<xsl:copy-of select="$posts[@rdf:about=current()/@rdf:about]"/>
	</xsl:template>

	<xsl:template match="@* | node()">
		<xsl:copy>
			<xsl:apply-templates select="@* | node()"/>
		</xsl:copy>
	</xsl:template>
</xsl:stylesheet>
