<?xml version="1.0" encoding="utf-8"?>

<xsl:transform version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xpath-default-namespace="http://docs.oasis-open.org/legaldocml/ns/akn/3.0"
	xmlns="http://www.legislation.gov.uk/namespaces/legislation"
	xmlns:local="http://www.jurisdatum.com/tna/akn2clml"
	exclude-result-prefixes="xs local">


<xsl:template match="tblock[@class='form']">
	<xsl:param name="context" as="xs:string*" tunnel="yes" />
	<Form>
		<xsl:apply-templates>
			<xsl:with-param name="context" select="('Form', $context)" tunnel="yes" />
		</xsl:apply-templates>
	</Form>
</xsl:template>

<xsl:template match="tblock[@class='form']/heading">
	<xsl:param name="context" as="xs:string*" tunnel="yes" />
	<TitleBlock>
		<xsl:next-match>
			<xsl:with-param name="context" select="('TitleBlock', $context)" tunnel="yes" />
		</xsl:next-match>
	</TitleBlock>
</xsl:template>

<xsl:template match="tblock[@class='form']/p[exists(img) and (count(*) eq 1)]">
	<IncludedDocument ResourceRef="{ local:make-resource-id(*) }" />
</xsl:template>

</xsl:transform>
