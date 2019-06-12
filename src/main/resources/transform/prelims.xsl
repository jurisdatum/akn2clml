<?xml version="1.0" encoding="utf-8"?>

<xsl:transform version="3.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xpath-default-namespace="http://docs.oasis-open.org/legaldocml/ns/akn/3.0"
	xmlns="http://www.legislation.gov.uk/namespaces/legislation"
	xmlns:local="http://www.jurisdatum.com/tna/akn2clml"
	exclude-result-prefixes="xs local">

<xsl:template name="prelims">
	<xsl:param name="context" as="xs:string*" tunnel="yes" />
	<xsl:variable name="name" as="xs:string" select="concat($context[1], 'Prelims')" />
	<xsl:variable name="child-context" as="xs:string*" select="($name, $context)" />
	<xsl:element name="{ $name }">
		<xsl:apply-templates select="preface/block[@name='title']">
			<xsl:with-param name="context" select="$child-context" tunnel="yes" />
		</xsl:apply-templates>
		<xsl:choose>
			<xsl:when test="exists(preface/block[@name='number'])">
				<xsl:apply-templates select="preface/block[@name='number']">
					<xsl:with-param name="context" select="$child-context" tunnel="yes" />
				</xsl:apply-templates>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates select="coverPage/block[@name='number']">
					<xsl:with-param name="context" select="$child-context" tunnel="yes" />
				</xsl:apply-templates>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:apply-templates select="preface/longTitle">
			<xsl:with-param name="context" select="$child-context" tunnel="yes" />
		</xsl:apply-templates>
		<xsl:apply-templates select="preface/block[@name='DateOfEnactment']">
			<xsl:with-param name="context" select="$child-context" tunnel="yes" />
		</xsl:apply-templates>
	</xsl:element>
</xsl:template>

<xsl:template match="preface/block[@name='title']">
	<xsl:param name="context" as="xs:string*" tunnel="yes" />
	<Title>
		<xsl:apply-templates>
			<xsl:with-param name="context" select="('Title', $context)" tunnel="yes" />
		</xsl:apply-templates>
	</Title>
</xsl:template>

<xsl:template match="coverPage/block[@name='number'] | preface/block[@name='number']">
	<xsl:param name="context" as="xs:string*" tunnel="yes" />
	<Number>
		<xsl:apply-templates>
			<xsl:with-param name="context" select="('Number', $context)" tunnel="yes" />
		</xsl:apply-templates>
	</Number>
</xsl:template>

<xsl:template match="preface/block[@name='DateOfEnactment']">
	<xsl:param name="context" as="xs:string*" tunnel="yes" />
	<DateOfEnactment>
		<DateText>
			<xsl:apply-templates>
				<xsl:with-param name="context" select="('DateText', 'DateOfEnactment', $context)" tunnel="yes" />
			</xsl:apply-templates>
		</DateText>
	</DateOfEnactment>
</xsl:template>

<xsl:template match="preface/longTitle">
	<xsl:param name="context" as="xs:string*" tunnel="yes" />
	<LongTitle>
		<xsl:apply-templates select="p/node()">
			<xsl:with-param name="context" select="('LongTitle', $context)" tunnel="yes" />
		</xsl:apply-templates>
	</LongTitle>
	<xsl:if test="count(p) != 1">
		<xsl:message terminate="yes" />
	</xsl:if>
	<xsl:if test="exists(node()[not(self::p or self::text()[not(normalize-space())])])">
		<xsl:message terminate="yes" />
	</xsl:if>
</xsl:template>

<xsl:template match="toc" />

</xsl:transform>
