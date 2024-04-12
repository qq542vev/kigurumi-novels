<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
	version="1.0"
	exclude-result-prefixes="dcterms foaf rdf rdfs schema sioc types"
	xmlns="http://www.w3.org/1999/xhtml"
	xmlns:dcterms="http://purl.org/dc/terms/"
	xmlns:foaf="http://xmlns.com/foaf/0.1/"
	xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
	xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
	xmlns:schema="https://schema.org/"
	xmlns:sioc="http://rdfs.org/sioc/ns#"
	xmlns:types="http://rdfs.org/sioc/types#"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
>
	<xsl:import href="template-html.xsl"/>

	<xsl:template match="/">
		<xsl:variable name="main" select="rdf:RDF/sioc:Container[@rdf:about='#main']"/>

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
		<link rel="stylesheet" type="text/css" href="{$base-url}css/novel.css"/>

		<xsl:apply-templates select="rdf:RDF/foaf:Document[@rdf:about='']/*"/>
	</xsl:template>

	<xsl:template name="html-main">
		<xsl:apply-templates select="rdf:RDF/sioc:Container[@rdf:about='#main']"/>
	</xsl:template>

	<xsl:template match="foaf:Document[@rdf:about='']/dcterms:created">
		<meta name="dcterms.created" property="dcterms:created" datatype="dcterms:W3CDTF" content="{.}"/>
	</xsl:template>

	<xsl:template match="foaf:Document[@rdf:about='']/dcterms:modified">
		<meta name="dcterms.modified" property="dcterms:modified" datatype="dcterms:W3CDTF" content="{.}"/>
	</xsl:template>

	<xsl:template match="sioc:Container[@rdf:about='#main']">
		<article>
			<h1>
				<xsl:choose>
					<xsl:when test="dcterms:title">
						<xsl:apply-templates select="dcterms:title"/>
					</xsl:when>
					<xsl:when test="dcterms:alternative">
						<xsl:apply-templates select="dcterms:alternative"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:attribute name="class">untitled</xsl:attribute>

						<xsl:text>無題</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</h1>

			<dl class="info">
				<xsl:apply-templates select="schema:creativeWorkStatus"/>
				<xsl:apply-templates select="dcterms:extent[@rdf:parseType='Resource']/rdf:value"/>
				<xsl:apply-templates select="sioc:num_items"/>

				<dt class="alternative">他の形式</dt>
				<dd class="alternative"><a rel="alternate" type="text/plain" href="index.txt">Plain Text</a></dd>
				<dd class="alternative"><a rel="alternate" type="application/rdf+xml" href="index.rdf">RDF</a></dd>
			</dl>

			<blockquote id="comment">
				<dl>
					<xsl:apply-templates select="dcterms:hasPart[@rdf:parseType='Collection']/types:BoardPost"/>
				</dl>
			</blockquote>
		</article>
	</xsl:template>

	<xsl:template match="dcterms:title">
		<xsl:attribute name="class">definitive-title</xsl:attribute>

		<xsl:value-of select="."/>
	</xsl:template>

	<xsl:template match="dcterms:alternative">
		<xsl:attribute name="class">provisional-title</xsl:attribute>

		<xsl:value-of select="concat(., '(仮)')"/>
	</xsl:template>

	<xsl:template match="schema:creativeWorkStatus">
		<dt class="status">状態</dt>
		<dd class="status {translate(., 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz')}">
			<xsl:choose>
				<xsl:when test=". = 'Complete'">完結</xsl:when>
				<xsl:otherwise>未完結</xsl:otherwise>
			</xsl:choose>
		</dd>
	</xsl:template>

	<xsl:template match="dcterms:extent[@rdf:parseType='Resource']/rdf:value">
		<dt class="character-count">文字数</dt>
		<dd class="character-count">
			<xsl:value-of select="format-number(., '#,###')"/>
		</dd>
	</xsl:template>

	<xsl:template match="sioc:num_items">
		<dt class="num-items">投稿数</dt>
		<dd class="num-items">
			<xsl:value-of select="format-number(., '#,###')"/>
		</dd>
	</xsl:template>

	<xsl:template match="types:BoardPost">
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
		<xsl:apply-templates select="foaf:nick"/>

		<xsl:if test="foaf:nick and dcterms:identifier">
			<xsl:text> </xsl:text>
		</xsl:if>

		<xsl:apply-templates select="dcterms:identifier"/>
	</xsl:template>

	<xsl:template match="foaf:nick">
		<span class="name">
			<xsl:value-of select="."/>
		</span>
	</xsl:template>

	<xsl:template match="dcterms:identifier">
		<span class="trip">
			<xsl:value-of select="concat('◆', .)"/>
		</span>
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

	<xsl:template match="sioc:content">
		<xsl:call-template name="anchor-link">
			<xsl:with-param name="url">
				<xsl:call-template name="rtrim">
					<xsl:with-param name="str" select="../@rdf:about"/>
					<xsl:with-param name="chars" select="'0123456789'"/>
				</xsl:call-template>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:template>

	<xsl:template name="day-number">
		<xsl:param name="year" select="number()"/>
		<xsl:param name="month" select="1"/>
		<xsl:param name="day" select="1"/>
		<xsl:param name="gregorian" select="true()"/>

		<xsl:variable name="year-month">
			<xsl:choose>
				<xsl:when test="$month &lt;= 2">
					<xsl:value-of select="concat($year - 1, '-', $month + 12)"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="concat($year, '-', $month)"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="_year" select="substring-before($year-month, '-')"/>
		<xsl:variable name="_month" select="substring-after($year-month, '-')"/>
		<xsl:variable name="C" select="floor($_year div 100)"/>
		<xsl:variable name="Y" select="$_year mod 100"/>
		<xsl:variable name="G">
			<xsl:choose>
				<xsl:when test="$gregorian">
					<xsl:value-of select="(5 * $C) + floor($C div 4)"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="(6 * $C) + 5"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:value-of select="(($day + floor((26 * ($_month + 1)) div 10) + $Y + floor($Y div 4) + $G + 5) mod 7) + 1"/>
	</xsl:template>

	<xsl:template name="ltrim">
		<xsl:param name="str" select="."/>
		<xsl:param name="chars" select="'&#x9;&#xA;&#xD; '"/>

		<xsl:variable name="left" select="substring($str, 1, 1)"/>

		<xsl:choose>
			<xsl:when test="string($str) and translate($left, $chars, '') = ''">
				<xsl:call-template name="ltrim">
					<xsl:with-param name="str" select="substring($str, 2)"/>
					<xsl:with-param name="chars" select="$chars"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$str"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="rtrim">
		<xsl:param name="str" select="."/>
		<xsl:param name="chars" select="'&#x9;&#xA;&#xD; '"/>

		<xsl:variable name="right" select="substring($str, string-length($str))"/>

		<xsl:choose>
			<xsl:when test="string($str) and translate($right, $chars, '') = ''">
				<xsl:call-template name="rtrim">
					<xsl:with-param name="str" select="substring($str, 1, string-length($str) - 1)"/>
					<xsl:with-param name="chars" select="$chars"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$str"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="anchor-link">
		<xsl:param name="str" select="."/>
		<xsl:param name="url"/>

		<xsl:choose>
			<xsl:when test="contains($str, '&gt;&gt;')">
				<xsl:variable name="after" select="substring-after($str, '&gt;&gt;')"/>

				<xsl:value-of select="substring-before($str, '&gt;&gt;')"/>

				<xsl:choose>
					<xsl:when test="$after and translate(substring($after, 1, 1), '123456789', '') = ''">
						<xsl:variable name="trimed">
							<xsl:call-template name="ltrim">
								<xsl:with-param name="str" select="$after"/>
								<xsl:with-param name="chars" select="'0123456789'"/>
							</xsl:call-template>
						</xsl:variable>
						<xsl:variable name="number" select="substring-before($after, $trimed)"/>

						<a href="{$url}{$number}">
							<xsl:value-of select="concat('&gt;&gt;', $number)"/>
						</a>

						<xsl:call-template name="anchor-link-end">
							<xsl:with-param name="str" select="$trimed"/>
							<xsl:with-param name="url" select="$url"/>
						</xsl:call-template>
					</xsl:when>
					<xsl:otherwise>
						<xsl:call-template name="anchor-link-end">
							<xsl:with-param name="str" select="$after"/>
							<xsl:with-param name="url" select="$url"/>
						</xsl:call-template>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$str"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="anchor-link-end">
		<xsl:param name="str" select="."/>
		<xsl:param name="url"/>

		<xsl:variable name="after" select="substring($str, 2)"/>

		<xsl:choose>
			<xsl:when test="starts-with($str, '-') and $after and translate(substring($after, 1, 1), '123456789', '') = ''">
				<xsl:variable name="trimed">
					<xsl:call-template name="ltrim">
						<xsl:with-param name="str" select="$after"/>
						<xsl:with-param name="chars" select="'0123456789'"/>
					</xsl:call-template>
				</xsl:variable>
				<xsl:variable name="number" select="substring-before($after, $trimed)"/>

				<xsl:text>-</xsl:text>

				<a href="{$url}{$number}">
					<xsl:value-of select="$number"/>
				</a>

				<xsl:call-template name="anchor-link">
					<xsl:with-param name="str" select="$trimed"/>
					<xsl:with-param name="url" select="$url"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="anchor-link">
					<xsl:with-param name="str" select="$str"/>
					<xsl:with-param name="url" select="$url"/>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
</xsl:stylesheet>
