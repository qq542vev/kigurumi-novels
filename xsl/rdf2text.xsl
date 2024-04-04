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
		method="text"
		encoding="UTF-8"
		media-type="text/plain"
	/>

	<xsl:param name="nl" select="'&#xD;&#xA;'"/>

	<xsl:template match="/">
		<xsl:apply-templates select="rdf:RDF/sioc:Container[@rdf:about='#main']"/>
	</xsl:template>

	<xsl:template match="sioc:Container[@rdf:about='#main']">
		<xsl:text># </xsl:text>

		<xsl:choose>
			<xsl:when test="dcterms:title">
				<xsl:apply-templates select="dcterms:title"/>
			</xsl:when>
			<xsl:when test="dcterms:alternative">
				<xsl:apply-templates select="dcterms:alternative"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>無題</xsl:text>
			</xsl:otherwise>
		</xsl:choose>

		<xsl:value-of select="concat($nl, $nl)"/>

		<xsl:apply-templates select="schema:creativeWorkStatus"/>
		<xsl:text>, </xsl:text>
		
		<xsl:apply-templates select="dcterms:extent[@rdf:parseType='Resource']/rdf:value"/>
		<xsl:text>, </xsl:text>
		
		<xsl:apply-templates select="sioc:num_items"/>

		<xsl:value-of select="concat($nl, $nl)"/>

		<xsl:apply-templates select="dcterms:hasPart[@rdf:parseType='Collection']/types:BoardPost"/>
	</xsl:template>

	<xsl:template match="dcterms:title">
		<xsl:value-of select="."/>
	</xsl:template>

	<xsl:template match="dcterms:alternative">
		<xsl:value-of select="concat(., '(仮)')"/>
	</xsl:template>

	<xsl:template match="schema:creativeWorkStatus">
		<xsl:text>状態: </xsl:text>
		
		<xsl:choose>
			<xsl:when test=". = 'Complete'">完結</xsl:when>
			<xsl:otherwise>未完結</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="dcterms:extent[@rdf:parseType='Resource']/rdf:value">
		<xsl:value-of select="concat('文字数: ', format-number(., '#,###'))"/>
	</xsl:template>

	<xsl:template match="sioc:num_items">
		<xsl:value-of select="concat('投稿数:', format-number(., '#,###'))"/>
	</xsl:template>

	<xsl:template match="types:BoardPost">
		<xsl:apply-templates select="rdfs:label"/>
		<xsl:text> ：</xsl:text>
		<xsl:apply-templates select="dcterms:creator"/>
		<xsl:text>：</xsl:text>
		<xsl:apply-templates select="sioc:delivered_at"/>

		<xsl:value-of select="$nl"/>

		<xsl:apply-templates select="sioc:content"/>
	</xsl:template>

	<xsl:template match="rdfs:label">
		<xsl:value-of select="."/>
	</xsl:template>

	<xsl:template match="dcterms:creator">
		<xsl:apply-templates select="foaf:nick"/>

		<xsl:if test="foaf:nick and dcterms:identifier">
			<xsl:text> </xsl:text>
		</xsl:if>

		<xsl:apply-templates select="dcterms:identifier"/>
	</xsl:template>

	<xsl:template match="foaf:nick">
		<xsl:value-of select="."/>
	</xsl:template>

	<xsl:template match="dcterms:identifier">
		<xsl:value-of select="concat('◆', .)"/>
	</xsl:template>

	<xsl:template match="sioc:delivered_at">
		<xsl:variable name="year" select="substring(., 1, 4)"/>
		<xsl:variable name="month" select="substring(., 6, 2)"/>
		<xsl:variable name="day" select="substring(., 9, 2)"/>
		<xsl:variable name="time" select="substring(substring-before(., '+'), 12)"/>
		<xsl:variable name="day-number">
			<xsl:call-template name="day-number">
				<xsl:with-param name="year" select="$year"/>
				<xsl:with-param name="month" select="$month"/>
				<xsl:with-param name="day" select="$day"/>
			</xsl:call-template>
		</xsl:variable>

		<xsl:variable name="youbi">
			<xsl:choose>
				<xsl:when test="$day-number = 1">月</xsl:when>
				<xsl:when test="$day-number = 2">火</xsl:when>
				<xsl:when test="$day-number = 3">水</xsl:when>
				<xsl:when test="$day-number = 4">木</xsl:when>
				<xsl:when test="$day-number = 5">金</xsl:when>
				<xsl:when test="$day-number = 6">土</xsl:when>
				<xsl:when test="$day-number = 7">日</xsl:when>
			</xsl:choose>
		</xsl:variable>

		<xsl:value-of select="concat($year, '/', $month, '/', $day, '(', $youbi, ') ', $time)"/>
	</xsl:template>

	<xsl:template match="sioc:content">
		<xsl:if test="string()">
			<xsl:text>    </xsl:text>
		</xsl:if>

		<xsl:call-template name="string.replace">
			<xsl:with-param name="src" select="'&#xA;'"/>
			<xsl:with-param name="dst" select="concat($nl, '    ')"/>
		</xsl:call-template>

		<xsl:value-of select="concat($nl, $nl)"/>
	</xsl:template>

	<xsl:template name="day-number">
		<xsl:param name="year" select="number()"/>
		<xsl:param name="month" select="1"/>
		<xsl:param name="day" select="1"/>
		<xsl:param name="gregorian" select="true()"/>

		<xsl:variable name="C" select="floor($year div 100)"/>
		<xsl:variable name="Y" select="$year mod 100"/>
		<xsl:variable name="G">
			<xsl:choose>
				<xsl:when test="$gregorian">
					<xsl:value-of select="(-2 * $C) + floor($C div 4)"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="(-1 * $C) + 5"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:value-of select="(($day + floor((26 * ($month + 1)) div 10) + $Y + floor($Y div 4) + $G + 5) mod 7) + 1"/>
	</xsl:template>

	<xsl:template name="string.replace">
		<xsl:param name="string" select="."/>
		<xsl:param name="src"/>
		<xsl:param name="dst"/>

		<xsl:choose>
			<xsl:when test="string($src) and contains($string, $src)">
				<xsl:value-of select="concat(substring-before($string, $src), $dst)"/>

				<xsl:call-template name="string.replace">
					<xsl:with-param name="string" select="substring-after($string, $src)"/>
					<xsl:with-param name="src" select="$src"/>
					<xsl:with-param name="dst" select="$dst"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$string"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
</xsl:stylesheet>
