<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
	version="1.0"
	exclude-result-prefixes="dcterms foaf rdf rdfs schema sioc"
	xmlns="http://www.w3.org/1999/xhtml"
  	xmlns:dcterms="http://purl.org/dc/terms/"
	xmlns:foaf="http://xmlns.com/foaf/0.1/"
	xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
	xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
	xmlns:schema="https://schema.org/"
	xmlns:sioc="http://rdfs.org/sioc/ns#"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:regexp="http://exslt.org/regular-expressions"
	extension-element-prefixes="regexp"
                >
	<xsl:import href="template.xsl"/>

	<xsl:template match="/">
		<xsl:variable name="main" select="rdf:RDF/foaf:Document[@rdf:nodeID='main']"/>

		<xsl:call-template name="html-template">
			<xsl:with-param name="title">
				<xsl:choose>			
					<xsl:when test="$main/dcterms:title">
						<xsl:value-of select="$main/dcterms:title"/>
					</xsl:when>
					<xsl:when test="$main/dcterms:alternative">
						<xsl:value-of select="concat($main/dcterms:alternative, '(仮)')"/>
					</xsl:when>
					<xsl:otherwise>無題</xsl:otherwise>
				</xsl:choose>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:template>

	<xsl:template name="html-head">
		<xsl:apply-templates select="rdf:RDF/foaf:Document[@rdf:about='']/*"/>
	</xsl:template>

	<xsl:template name="html-main">
		<xsl:apply-templates select="rdf:RDF/foaf:Document[@rdf:nodeID='main']"/>
	</xsl:template>

	<xsl:template match="foaf:Document[@rdf:about='']/dcterms:modified">
		<meta name="dcterms.modified" property="dcterms:modified" datatype="dcterms:W3CDTF" content="{.}"/>
	</xsl:template>

	<xsl:template match="foaf:Document[@rdf:nodeID='main']">
		<h1>
			<xsl:choose>			
				<xsl:when test="dcterms:title">
					<xsl:value-of select="dcterms:title"/>
				</xsl:when>
				<xsl:when test="dcterms:alternative">
					<xsl:value-of select="concat(dcterms:alternative, '(仮)')"/>
				</xsl:when>
				<xsl:otherwise>無題</xsl:otherwise>
			</xsl:choose>
		</h1>

		<dl class="info">
			<xsl:apply-templates select="schema:creativeWorkStatus"/>
			<xsl:apply-templates select="dcterms:extent[@rdf:parseType='Resource']/rdf:value"/>
		</dl>

		<dl class="comment">
			<xsl:apply-templates select="dcterms:hasPart[@rdf:parseType='Collection']/sioc:Post"/>
		</dl>
	</xsl:template>

	<xsl:template match="schema:creativeWorkStatus">
		<dt>状態</dt>
		<dd>
			<xsl:choose>
				<xsl:when test=". = 'Complete'">完結</xsl:when>
				<xsl:otherwise>未完結</xsl:otherwise>
			</xsl:choose>
		</dd>
	</xsl:template>

	<xsl:template match="dcterms:extent[@rdf:parseType='Resource']/rdf:value">
		<dt>文字数</dt>
		<dd>
			<xsl:value-of select="format-number(., '#,###')"/>
		</dd>
	</xsl:template>

	<xsl:template match="sioc:Post">
		<dt id="comment-{rdfs:label}">
			<a class="number" href="{@rdf:about}">
				<xsl:value-of select="rdfs:label"/>
			</a>
			<xsl:text> ：</xsl:text>
			<xsl:apply-templates select="dcterms:creator"/>
			<xsl:text>：</xsl:text>
			<xsl:apply-templates select="sioc:delivered_at"/>
		</dt>
		<dd>
			<pre>
				<xsl:apply-templates select="sioc:content"/>
			</pre>
		</dd>
	</xsl:template>

	<xsl:template match="dcterms:creator">
		<span class="name">
			<xsl:value-of select="@foaf:nick"/>
		</span>

		<xsl:if test="@dcterms:identifier">
			<xsl:text> </xsl:text>

			<span class="trip">
				<xsl:value-of select="concat('◆', @dcterms:identifier)"/>
			</span>
		</xsl:if>
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

		<time class="datetime" datetime="{.}">
			<xsl:value-of select="concat($year, '/', $month, '/', $day, '(', $youbi, ') ', $time)"/>
		</time>
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

<!--	<xsl:template name="comment-link">
		<xsl:param name="str" select="."/>
		<xsl:param name="url" select="."/>

		<xsl:choose>
			<xsl:when test="contains($str, '>>')">
				<xsl:variable name="after" select="substring-after($str, '>>')"/>

				<xsl:value-of select="substring-before($str, '>>')"/>
				
				<xsl:choose>
					<xsl:variable name="n" select="$after"/>

					<xsl:when test="match($after, '^[1-9][0-9]*')">
						<a href="{$url}{$n}">
							<xsl:value-of select="substring-before($str, '>>')"/>
						</a>

						<xsl:call-template name="comment-link">
							<xsl:with-param name="str" select="substring-after($after, $n)"/>
							<xsl:with-param name="url" select="$url"/>
						</xsl:call-template>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="$str"/>				
					</xsl:otherwise>
				</xsl:choose>
				
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$str"/>				
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>-->

</xsl:stylesheet>