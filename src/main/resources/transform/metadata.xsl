<?xml version="1.0" encoding="utf-8"?>

<xsl:transform version="3.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xpath-default-namespace="http://docs.oasis-open.org/legaldocml/ns/akn/3.0"
	xmlns:local="http://www.jurisdatum.com/tna/akn2clml"
	exclude-result-prefixes="xs local">

<xsl:include href="globals.xsl" />

<xsl:template name="metadata">
	<Metadata xmlns="http://www.legislation.gov.uk/namespaces/metadata" xmlns:dc="http://purl.org/dc/elements/1.1/">
		<dc:identifier>
			<xsl:value-of select="$doc-long-id" />
		</dc:identifier>
		<dc:title>
			<xsl:value-of select="$doc-title" />
		</dc:title>
		<dc:publisher>
			<xsl:choose>
				<xsl:when test="$doc-short-type = 'asp'">
					<xsl:text>Queen's Printer for Scotland</xsl:text>
				</xsl:when>
			</xsl:choose>
		</dc:publisher>
		<dc:modified>
			<xsl:value-of select="adjust-date-to-timezone(current-date(), ())" />
		</dc:modified>
		<xsl:choose>
			<xsl:when test="$doc-category = 'primary'">
				<xsl:call-template name="primary-metadata" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:message terminate="yes" />
			</xsl:otherwise>
		</xsl:choose>
	</Metadata>
</xsl:template>

<xsl:template name="primary-metadata">
	<xsl:variable name="assent-date" as="xs:date" select="//docDate[@name='assentDate']/@date" />
	<PrimaryMetadata xmlns="http://www.legislation.gov.uk/namespaces/metadata">
		<DocumentClassification>
			<DocumentCategory Value="primary" />
			<DocumentMainType Value="{ $doc-long-type }" />
			<DocumentStatus Value="final" />
		</DocumentClassification>
		<Year Value="{ $doc-year }" />
		<Number Value="{ $doc-number }" />
		<EnactmentDate Date="{ $assent-date }"/>
	</PrimaryMetadata>
</xsl:template>

</xsl:transform>
