<?xml version="1.0" encoding="utf-8"?>

<xsl:transform version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xpath-default-namespace="http://docs.oasis-open.org/legaldocml/ns/akn/3.0"
	xmlns:local="http://www.jurisdatum.com/tna/akn2clml"
	exclude-result-prefixes="xs local">

<xsl:template name="metadata">
	<Metadata xmlns="http://www.legislation.gov.uk/namespaces/metadata" xmlns:dc="http://purl.org/dc/elements/1.1/">
		<dc:identifier>
			<xsl:value-of select="$doc-long-id" />
		</dc:identifier>
		<dc:title>
			<xsl:value-of select="$doc-title" />
		</dc:title>
		<dc:modified>
			<xsl:value-of select="adjust-date-to-timezone(current-date(), ())" />
		</dc:modified>
		<xsl:choose>
			<xsl:when test="$doc-category = 'primary'">
				<xsl:call-template name="primary-metadata" />
			</xsl:when>
			<xsl:when test="$doc-category = 'secondary'">
				<xsl:call-template name="secondary-metadata" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:message terminate="yes" />
			</xsl:otherwise>
		</xsl:choose>
	</Metadata>
</xsl:template>

<xsl:template name="primary-metadata">
	<!-- <xsl:variable name="assent-date" as="xs:date?" select="//docDate[@name='assentDate']/@date" /> -->
	<xsl:variable name="work-date" as="xs:date" select="/akomaNtoso/*/meta/identification/FRBRWork/FRBRdate/@date" />
	<PrimaryMetadata xmlns="http://www.legislation.gov.uk/namespaces/metadata">
		<DocumentClassification>
			<DocumentCategory Value="primary" />
			<DocumentMainType Value="{ $doc-long-type }" />
			<DocumentStatus Value="final" />
		</DocumentClassification>
		<Year Value="{ $doc-year }" />
		<Number Value="{ $doc-number }" />
		<EnactmentDate Date="{ $work-date }"/>
	</PrimaryMetadata>
</xsl:template>

<xsl:template name="secondary-metadata">
	<SecondaryMetadata xmlns="http://www.legislation.gov.uk/namespaces/metadata">
		<DocumentClassification>
			<DocumentCategory Value="secondary" />
			<DocumentMainType Value="{ $doc-long-type }" />
			<DocumentStatus Value="final" />
		</DocumentClassification>
		<Year Value="{ $doc-year }" />
		<Number Value="{ $doc-number }" />
	</SecondaryMetadata>
</xsl:template>

</xsl:transform>
