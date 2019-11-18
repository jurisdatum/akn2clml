<?xml version="1.0" encoding="utf-8"?>

<xsl:transform version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xpath-default-namespace="http://www.legislation.gov.uk/namespaces/metadata"
	xmlns="http://www.legislation.gov.uk/namespaces/metadata"
	xmlns:ukl="http://www.legislation.gov.uk/namespaces/legislation"
	xmlns:ukm="http://www.legislation.gov.uk/namespaces/metadata"
	xmlns:dc="http://purl.org/dc/elements/1.1/"
	xmlns:local="http://www.jurisdatum.com/tna/clml"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	exclude-result-prefixes="xs ukl ukm dc local">


<xsl:param name="isbn" as="xs:string?" select="()" />
<xsl:param name="default-publisher" as="xs:boolean" select="false()" />
<xsl:param name="schemaLocation" as="xs:string?" select="()" />


<!-- add schemaLocation for eContent -->

<xsl:template match="ukl:Legislation">
	<xsl:copy>
		<xsl:if test="exists($schemaLocation)">
			<xsl:attribute name="xsi:schemaLocation"><xsl:text>http://www.legislation.gov.uk/namespaces/legislation </xsl:text><xsl:value-of select="$schemaLocation"/></xsl:attribute>
		</xsl:if>
		<xsl:apply-templates select="@*[local-name() != 'schemaLocation'] | node()"/>
	</xsl:copy>
</xsl:template>


<!-- add ISBN -->

<xsl:template match="PrimaryMetadata | SecondaryMetadata">
	<xsl:copy>
		<xsl:copy-of select="*" />
		<xsl:if test="exists($isbn)">
			<ISBN Value="{ $isbn }" />
		</xsl:if>
	</xsl:copy>
</xsl:template>


<!-- add default publisher -->

<xsl:variable name="publisher" as="xs:string?">
	<xsl:variable name="doc-type" as="xs:string?" select="/ukl:Legislation/Metadata/*/DocumentClassification/DocumentMainType/@Value" />
	<xsl:choose>
		<xsl:when test="$doc-type = 'ScottishAct'">
			<xsl:text>Queen's Printer for Scotland</xsl:text>
		</xsl:when>
	</xsl:choose>
</xsl:variable>

<xsl:template match="Metadata/ukm:*[1]">
	<xsl:if test="$default-publisher and exists($publisher) and empty(preceding-sibling::dc:publisher)">
		<dc:publisher>
			<xsl:value-of select="$publisher" />
		</dc:publisher>
	</xsl:if>
	<xsl:next-match />
</xsl:template>


<!-- identity transform -->

<xsl:template match="@* | node()">
	<xsl:copy>
		<xsl:apply-templates select="@* | node()"/>
	</xsl:copy>
</xsl:template>

</xsl:transform>
