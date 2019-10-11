<?xml version="1.0" encoding="utf-8"?>

<xsl:transform version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xpath-default-namespace="http://docs.oasis-open.org/legaldocml/ns/akn/3.0"
	xmlns="http://www.legislation.gov.uk/namespaces/legislation"
	xmlns:local="http://www.jurisdatum.com/tna/akn2clml"
	exclude-result-prefixes="xs local">


<xsl:template match="conclusions">
	<xsl:apply-templates />
</xsl:template>

<xsl:template match="blockContainer[@class='explanatoryNotes']">
	<xsl:param name="context" as="xs:string*" tunnel="yes" />
	<ExplanatoryNotes>
		<xsl:apply-templates>
			<xsl:with-param name="context" select="('ExplanatoryNotes', $context)" tunnel="yes" />
		</xsl:apply-templates>
	</ExplanatoryNotes>
</xsl:template>

<xsl:template match="block[@name='comment']">
	<Comment>
		<Para>
			<Text>
				<xsl:apply-templates />
			</Text>
		</Para>
	</Comment>
</xsl:template>

<xsl:template match="blockList[@class='definition']">
	<xsl:variable name="decor" as="xs:string" select="local:get-decoration-from-list(., false())" />
	<UnorderedList Decoration="{ $decor }" Class="Definition">
		<xsl:apply-templates>
			<xsl:with-param name="decor" select="$decor" />
		</xsl:apply-templates>
	</UnorderedList>
</xsl:template>


<!-- earlier orders -->

<xsl:template match="blockContainer[@class='earlierOrders']">
	<xsl:param name="context" as="xs:string*" tunnel="yes" />
	<EarlierOrders>
		<xsl:apply-templates>
			<xsl:with-param name="context" select="('EarlierOrders', $context)" tunnel="yes" />
		</xsl:apply-templates>
	</EarlierOrders>
</xsl:template>


</xsl:transform>
