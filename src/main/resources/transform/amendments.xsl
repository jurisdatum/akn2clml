<?xml version="1.0" encoding="utf-8"?>

<xsl:transform version="3.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xpath-default-namespace="http://docs.oasis-open.org/legaldocml/ns/akn/3.0"
	xmlns="http://www.legislation.gov.uk/namespaces/legislation"
	xmlns:ukl2="http://legislation.gov.uk/namespaces/legis"
	xmlns:local="http://www.jurisdatum.com/tna/akn2clml"
	exclude-result-prefixes="xs ukl2 local">

<xsl:template name="block-with-mod">
	<xsl:if test="exists(node()[not(self::mod) and not(self::text()[not(normalize-space())]) and not(self::inline/@name='AppendText')])">
		<xsl:message terminate="yes" />
	</xsl:if>
	<xsl:apply-templates />
</xsl:template>

<xsl:template match="mod">
	<xsl:if test="count(quotedStructure) != 1">
		<xsl:message terminate="yes" />
	</xsl:if>
	<Text>
		<xsl:apply-templates select="quotedStructure/preceding-sibling::node()" />
	</Text>
	<xsl:apply-templates select="quotedStructure" />
	<xsl:apply-templates select="quotedStructure/following-sibling::node()" />
</xsl:template>

<xsl:template match="quotedStructure">
	<xsl:param name="context" as="xs:string*" tunnel="yes" />
	<xsl:variable name="target-class" as="xs:string">
		<xsl:choose>
			<xsl:when test="exists(@ukl2:docName)">
				<xsl:value-of select="local:category-from-short-type(@ukl2:docName)" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>unknown</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	<xsl:variable name="amendment-context" as="xs:string">
		<xsl:choose>
			<xsl:when test="false()">
				<xsl:text>main</xsl:text>
			</xsl:when>
			<xsl:when test="false()">
				<xsl:text>schedule</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>unknown</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	<BlockAmendment>
		<xsl:attribute name="TargetClass">
			<xsl:value-of select="$target-class" />
		</xsl:attribute>
		<xsl:attribute name="TargetSubClass">
			<xsl:text>unknown</xsl:text>
		</xsl:attribute>
		<xsl:attribute name="Context">
			<xsl:value-of select="$amendment-context" />
		</xsl:attribute>
		<xsl:attribute name="Format">
			<xsl:choose>
				<xsl:when test="@startQuote='“' and @endQuote='”'">
					<xsl:text>double</xsl:text>
				</xsl:when>
				<xsl:when test="@startQuote='‘' and @endQuote='’'">
					<xsl:text>single</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>default</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:attribute>
		<xsl:apply-templates>
			<xsl:with-param name="context" select="('BlockAmendment', $context)" tunnel="yes" />
		</xsl:apply-templates>
	</BlockAmendment>
</xsl:template>

<xsl:template match="inline[@name='AppendText']">
	<AppendText>
		<xsl:apply-templates />
	</AppendText>
</xsl:template>

</xsl:transform>
