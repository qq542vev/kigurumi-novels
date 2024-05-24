<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
	version="1.0"
	exclude-result-prefixes="dcterms foaf rdf rdfs schema sioc sitemap types"
	xmlns="http://www.w3.org/1999/xhtml"
	xmlns:dcterms="http://purl.org/dc/terms/"
	xmlns:foaf="http://xmlns.com/foaf/0.1/"
	xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
	xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
	xmlns:schema="https://schema.org/"
	xmlns:sioc="http://rdfs.org/sioc/ns#"
	xmlns:sitemap="http://www.sitemaps.org/schemas/sitemap/0.9"
	xmlns:types="http://rdfs.org/sioc/types#"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
>
	<xsl:import href="param.xsl"/>
	<xsl:import href="template-html.xsl"/>

	<xsl:template match="/">
		<xsl:call-template name="html-template"/>
	</xsl:template>

	<xsl:template name="html-head">
		<link rel="stylesheet" type="text/css" href="{$base-url}css/index.css"/>
	</xsl:template>

	<xsl:template name="html-main">
		<section id="novels">
			<h1>着ぐるみ小説スレの小説一覧</h1>

			<p><xsl:value-of select="format-number(count(//sitemap:loc[contains(., '/index.rdf')]), '#,###')"/>個の小説があります。タイトル末尾に(仮)と付いているのは仮題です。</p>

			<table>
				<caption>着ぐるみ小説スレの小説一覧</caption>
				<colgroup>
					<col class="title"/>
				</colgroup>
				<colgroup>
					<col class="character-count"/>
					<col class="num-items"/>
				</colgroup>
				<colgroup>
					<col class="first-date"/>
				</colgroup>
				<thead>
					<tr>
						<th scope="col">タイトル</th>
						<th scope="col">状態</th>
						<th scope="col">文字数</th>
						<th scope="col">投稿数</th>
						<th scope="col">投稿日</th>
					</tr>
				</thead>
				<tbody>
					<xsl:apply-templates select="//sitemap:loc[contains(., '/index.rdf')]" mode="novel">
						<xsl:sort order="descending" lang="en"/>
					</xsl:apply-templates>
				</tbody>
			</table>
		</section>

		<section id="about">
			<h1>このサイトについて</h1>

			<p>このサイトは<strong>★着ぐるみ★ゼンタイ★マスク★ BBS</strong>内の<strong>着ぐるみ小説スレ</strong>に掲載された小説をまとめております。歴史の中に埋もれているには惜しいような秀逸な作品が幾つも存在したため、勝手ながら再掲載致しました。</p>

			<p>2024年05月現在、以下のスレッド内に掲載された小説をまとめております。</p>

			<ul>
				<xsl:apply-templates select="//sitemap:loc[contains(., '/src/rdf/')]" mode="board">
						<xsl:sort order="descending" lang="en"/>
				</xsl:apply-templates>
			</ul>
		</section>

		<section id="editorial-policy">
			<h1>編集方針</h1>

			<p>原則、投稿された小説の誤字脱字などを含め、元の文章を一切変更せずに掲載しております。また執筆者による前書き、後書き、補足事項など作品に関するコメントもそのまま掲載しております。執筆者以外のコメントは、執筆者の投稿を掲載する上で、必要としたもののみ掲載致します。</p>

			<p>再掲載した小説のレイアウトは元のしたらば掲示板に似た形式を採用しており、投稿時の番号、名前、トリップ、投稿日時もそのままですが、行間や字幅などの細かいスタイルは、読みやすさを考慮して<abbr title="Cascading Style Sheets">CSS</abbr>で変更しています。</p>
		</section>
	</xsl:template>

	<xsl:template match="sitemap:loc" mode="novel">
		<xsl:variable name="path" select="concat('/', substring-after(substring-after(., '://'), '/'))"/>

		<xsl:apply-templates select="document(substring-after($path, $base-url), .)//sioc:Container[@rdf:about='#main']" mode="novel">
			<xsl:with-param name="path" select="substring($path, 1, string-length($path) - string-length('index.rdf'))"/>
		</xsl:apply-templates>
	</xsl:template>

	<xsl:template match="sioc:Container[@rdf:about='#main']" mode="novel">
		<xsl:param name="path" select="."/>

		<tr>
			<td>
				<xsl:attribute name="class">
					<xsl:choose>
						<xsl:when test="dcterms:title">definitive-title</xsl:when>
						<xsl:when test="dcterms:alternative">provisional-title</xsl:when>
						<xsl:otherwise>untitled</xsl:otherwise>
					</xsl:choose>
				</xsl:attribute>

				<a href="{$path}">
					<xsl:choose>
						<xsl:when test="dcterms:title">
							<xsl:apply-templates select="dcterms:title"/>
						</xsl:when>
						<xsl:when test="dcterms:alternative">
							<xsl:apply-templates select="dcterms:alternative"/>
						</xsl:when>
						<xsl:otherwise>無題</xsl:otherwise>
					</xsl:choose>
				</a>
			</td>
			<td>
				<xsl:apply-templates select="schema:creativeWorkStatus" mode="novel"/>
			</td>
			<td>
				<xsl:apply-templates select="dcterms:extent[@rdf:parseType='Resource']/rdf:value" mode="novel"/>
			</td>
			<td>
				<xsl:apply-templates select="sioc:num_items" mode="novel"/>
			</td>
			<td>
				<xsl:apply-templates select="dcterms:created" mode="novel"/>
			</td>
		</tr>
	</xsl:template>

	<xsl:template match="dcterms:title">
		<xsl:value-of select="."/>
	</xsl:template>

	<xsl:template match="dcterms:alternative">
		<xsl:value-of select="concat(., '(仮)')"/>
	</xsl:template>

	<xsl:template match="schema:creativeWorkStatus" mode="novel">
		<xsl:attribute name="class">
			<xsl:value-of select="translate(., 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz')"/>
		</xsl:attribute>

		<xsl:choose>
			<xsl:when test=". = 'Complete'">完結</xsl:when>
			<xsl:otherwise>未完結</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="dcterms:extent[@rdf:parseType='Resource']/rdf:value | sioc:num_items" mode="novel">
		<xsl:value-of select="format-number(., '#,###')"/>
	</xsl:template>

	<xsl:template match="dcterms:created" mode="novel">
		<xsl:variable name="year" select="substring(., 1, 4)"/>
		<xsl:variable name="month" select="substring(., 6, 2)"/>
		<xsl:variable name="day" select="substring(., 9, 2)"/>

		<time datetime="{.}">
			<xsl:value-of select="concat($year, '/', $month, '/', $day)"/>
		</time>
	</xsl:template>

	<xsl:template match="sitemap:loc" mode="board">
		<xsl:variable name="path" select="concat('/', substring-after(substring-after(., '://'), '/'))"/>

		<xsl:apply-templates select="document(substring-after($path, $base-url), .)//types:MessageBoard" mode="board"/>
	</xsl:template>

	<xsl:template match="types:MessageBoard" mode="board">
		<li>
			<a href="{@rdf:about}">
				<xsl:value-of select="dcterms:title"/>
			</a>

			<xsl:text> (</xsl:text>
			<xsl:apply-templates select="dcterms:created" mode="board"/>
			<xsl:text> - </xsl:text>
			<xsl:apply-templates select="sioc:last_item_date" mode="board"/>
			<xsl:text>)</xsl:text>
		</li>
	</xsl:template>

	<xsl:template match="dcterms:created | sioc:last_item_date" mode="board">
		<xsl:variable name="year" select="substring(., 1, 4)"/>
		<xsl:variable name="month" select="substring(., 6, 2)"/>
		<xsl:variable name="day" select="substring(., 9, 2)"/>

		<time datetime="{.}">
			<xsl:value-of select="concat($year, '/', $month, '/', $day)"/>
		</time>
	</xsl:template>
</xsl:stylesheet>
