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
	<xsl:import href="template.xsl"/>

	<xsl:template match="/">
		<xsl:call-template name="html-template"/>
	</xsl:template>

	<xsl:template name="html-main">
		<section id="novels">
			<h1>着ぐるみ小説の一覧</h1>

			<table>
				<thead>
					<tr>
						<th>タイトル</th>
						<th>状態</th>
						<th>文字数</th>
						<th>投稿日</th>
					</tr>
				</thead>
				<tbody>
					<xsl:apply-templates select="//url"/>
				</tbody>
			</table>
		</section>

		<section id="about">
			<h1>このサイトについて</h1>

			<ul>
				<li><a href="https://web.archive.org/web/20120214160639/http://jbbs.livedoor.jp/anime/846/storage/1067870090.html">【妄想】着ぐるみ小説スレ【連載？】</a></li>
				<li><a href="https://web.archive.org/web/20090803104804/http://jbbs.livedoor.jp/anime/846/storage/1081325649.html">【妄想】着ぐるみ小説スレ第２章【連載？】</a></li>
				<li><a href="https://web.archive.org/web/20090322230543/http://jbbs.livedoor.jp/anime/846/storage/1122950720.html">【妄想】着ぐるみ小説スレ第３章【連載？】</a></li>
				<li><a href="https://web.archive.org/web/20090323011551/http://jbbs.livedoor.jp/anime/846/storage/1184654919.html">【妄想】着ぐるみ小説スレ第４章【連載？】</a></li>
				<li><a href="https://web.archive.org/web/20090730010136/http://jbbs.livedoor.jp/anime/846/storage/1211041119.html">【妄想】着ぐるみ小説スレ第５章【連載？】</a></li>
				<li><a href="https://web.archive.org/web/20150111082648/http://kigurumi.net63.net/kako/1247437212.html">【妄想】着ぐるみ小説スレ第６章【連載？】</a></li>
			</ul>
		</section>
	</xsl:template>

	<xsl:template match="url">
		<xsl:apply-templates select="document(.)//foaf:Document[@rdf:nodeID='main']">
			<xsl:with-param name="url" select="substring-before(., 'index.rdf')"/>
		</xsl:apply-templates>
	</xsl:template>

	<xsl:template match="foaf:Document[@rdf:nodeID='main']">
		<xsl:param name="url" select="."/>

		<tr>
			<td>
				<a href="{$base-url}{$url}">
					<xsl:choose>
						<xsl:when test="dcterms:title">
							<xsl:value-of select="dcterms:title"/>
						</xsl:when>
						<xsl:when test="dcterms:alternative">
							<xsl:value-of select="concat(dcterms:alternative, '(仮)')"/>
						</xsl:when>
						<xsl:otherwise>無題</xsl:otherwise>
					</xsl:choose>
				</a>
			</td>
			<td>
				<xsl:apply-templates select="schema:creativeWorkStatus"/>
			</td>
			<td>
				<xsl:apply-templates select="dcterms:extent[@rdf:parseType='Resource']/rdf:value"/>
			</td>
			<td>
				<xsl:apply-templates select="dcterms:dateSubmitted"/>
			</td>
		</tr>
	</xsl:template>

	<xsl:template match="schema:creativeWorkStatus">
		<xsl:choose>
			<xsl:when test=". = 'Complete'">完結</xsl:when>
			<xsl:otherwise>未完結</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="dcterms:extent[@rdf:parseType='Resource']/rdf:value">
		<xsl:value-of select="format-number(., '#,###')"/>
	</xsl:template>

	<xsl:template match="dcterms:dateSubmitted">
		<xsl:variable name="year" select="substring(., 1, 4)"/>
		<xsl:variable name="month" select="substring(., 6, 2)"/>
		<xsl:variable name="day" select="substring(., 9, 2)"/>

		<time datetime="{.}">
			<xsl:value-of select="concat($year, '/', $month, '/', $day)"/>
		</time>
	</xsl:template>
</xsl:stylesheet>
