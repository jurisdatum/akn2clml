<?xml version="1.0" encoding="utf-8"?>

<xsl:transform version="3.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xpath-default-namespace="http://docs.oasis-open.org/legaldocml/ns/akn/3.0"
	xmlns="http://www.legislation.gov.uk/namespaces/legislation"
	xmlns:local="http://www.jurisdatum.com/tna/akn2clml"
	exclude-result-prefixes="xs local">

<xsl:function name="local:should-strip-punctuation-from-number" as="xs:boolean">
	<xsl:param name="text" as="text()" />
	<xsl:param name="context" as="xs:string*" />
	<xsl:choose>
		<xsl:when test="empty($text/parent::num)">
			<xsl:value-of select="false()" />
		</xsl:when>
		<xsl:when test="head($context) = ('groupOfParts', 'part', 'chapter', 'schedule')">
			<xsl:value-of select="false()" />
		</xsl:when>
		<xsl:when test="head($context) = 'section'">
			<xsl:value-of select="false()" />
		</xsl:when>
		<xsl:when test="head($context) = 'paragraph' and head(tail($context)) = 'schedule'">
			<xsl:value-of select="false()" />
		</xsl:when>
		<xsl:when test="matches(normalize-space($text), '^\(\d+[A-Z]?\)$')">
			<xsl:value-of select="true()" />
		</xsl:when>
		<xsl:when test="matches(normalize-space($text), '^\([a-z]+\)$')">
			<xsl:value-of select="true()" />
		</xsl:when>
		<xsl:otherwise>
			<xsl:value-of select="false()" />
		</xsl:otherwise>
	</xsl:choose>
</xsl:function>

<xsl:template name="strip-punctuation-from-number">
	<xsl:if test="starts-with(., ' ')">
		<xsl:text> </xsl:text>
	</xsl:if>
	<xsl:value-of select="replace(normalize-space(.), '^\(([\dA-Za-z]+)\)$', '$1')" />
	<xsl:if test="ends-with(., ' ')">
		<xsl:text> </xsl:text>
	</xsl:if>
</xsl:template>

<xsl:function name="local:strip-punctuation-for-number-override" as="xs:string">
	<xsl:param name="num" as="element(num)" />
	<xsl:param name="decor" as="xs:string" />
	<xsl:choose>
		<xsl:when test="$decor = ('parens', 'brackets')">
			<xsl:value-of select="substring($num, 2, string-length($num) - 2)" />
		</xsl:when>
		<xsl:when test="$decor = ('parenRight', 'bracketRight', 'period', 'colon')">
			<xsl:value-of select="substring($num, 1, string-length($num) - 1)" />
		</xsl:when>
		<xsl:when test="$decor = 'none'">
			<xsl:value-of select="$num" />
		</xsl:when>
	</xsl:choose>
</xsl:function>

</xsl:transform>
