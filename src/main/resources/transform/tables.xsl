<?xml version="1.0" encoding="utf-8"?>

<xsl:transform version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xpath-default-namespace="http://docs.oasis-open.org/legaldocml/ns/akn/3.0"
	xmlns="http://www.legislation.gov.uk/namespaces/legislation"
	xmlns:ukl="http://www.legislation.gov.uk/namespaces/legislation"
	xmlns:html="http://www.w3.org/1999/xhtml"
	xmlns:local="http://www.jurisdatum.com/tna/akn2clml"
	exclude-result-prefixes="xs ukl html local">

<xsl:template match="tblock[@class='tabular']">
	<xsl:param name="context" as="xs:string*" tunnel="yes" />
	<Tabular Orientation="{ @ukl:Orientation }">
		<xsl:apply-templates>
			<xsl:with-param name="context" select="('Tabular', $context)" tunnel="yes" />
		</xsl:apply-templates>
	</Tabular>
</xsl:template>

<xsl:template match="foreign">
	<xsl:apply-templates />
</xsl:template>

<xsl:template match="html:*">
	<xsl:param name="context" as="xs:string*" tunnel="yes" />
	<xsl:copy>
		<xsl:copy-of select="@*" />
		<xsl:apply-templates>
			<xsl:with-param name="context" select="(local-name(.), $context)" tunnel="yes" />
		</xsl:apply-templates>
	</xsl:copy>
</xsl:template>

</xsl:transform>
