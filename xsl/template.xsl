<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
	version="1.0"
	xmlns="http://www.w3.org/1999/xhtml"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
>
	<xsl:import href="param.xsl"/>

	<xsl:output
		version="1.0"
		method="xml"
		indent="yes"
		encoding="UTF-8"
		media-type="application/xhtml+xml"
		doctype-system="about:legacy-compat"
		omit-xml-declaration="yes"
	/>

	<xsl:template name="html-template">
		<xsl:param name="title"/>

		<html lang="ja" xml:lang="ja" about="" typeof="foaf:Document">
			<head>
				<meta charset="UTF-8"/>
				<meta name="robots" content="index,follow"/>

				<title property="dcterms:title">
					<xsl:if test="$title != ''">
						<xsl:value-of select="concat($title, ' | ')"/>
					</xsl:if>

					<xsl:value-of select="$site-name"/>
				</title>

				<link rel="dcterms:publisher" href="https://purl.org/meta/"/>

				<xsl:call-template name="html-head"/>
			</head>
			<body>
				<main id="main">
					<xsl:call-template name="html-main"/>
				</main>
				<footer>
					<nav>
						<ul>
							<li><a href="#top">ページの最上位</a></li>
							<li><a href="{$base-url}#novels">小説一覧</a></li>
							<li><a href="{$base-url}#about">このサイトについて</a></li>
						</ul>
					</nav>
				</footer>
			</body>
		</html>
	</xsl:template>

	<xsl:template name="html-head"/>

	<xsl:template name="html-main"/>
</xsl:stylesheet>
