<?xml version="1.0" encoding="utf-8"?>

<xsl:transform version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xpath-default-namespace="http://docs.oasis-open.org/legaldocml/ns/akn/3.0"
	xmlns="http://www.legislation.gov.uk/namespaces/legislation"
	exclude-result-prefixes="xs">

<xsl:template match="hcontainer[@name='signatures']">
	<SignedSection>
		<xsl:choose>
			<xsl:when test="empty(hcontainer[@name='signatureGroup'])">
				<Signatory>
					<xsl:apply-templates />
				</Signatory>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates />
			</xsl:otherwise>
		</xsl:choose>
	</SignedSection>
</xsl:template>

<xsl:template match="hcontainer[@name='signatureGroup']">
	<Signatory>
		<xsl:apply-templates />
	</Signatory>
</xsl:template>

<xsl:template match="hcontainer[@name='signatureGroup']/intro">
	<Para>
		<xsl:apply-templates />
	</Para>
</xsl:template>

<xsl:template match="hcontainer[@name='signature']">
	<Signee>
		<xsl:apply-templates />
	</Signee>
</xsl:template>

<xsl:template match="block[@name='signee']">
	<PersonName>
		<xsl:apply-templates />
	</PersonName>
</xsl:template>

<xsl:template match="block[@name='jobTitle']">
	<JobTitle>
		<xsl:apply-templates />
	</JobTitle>
</xsl:template>

<xsl:template match="block[@name='department']">
	<Department>
		<xsl:apply-templates />
	</Department>
</xsl:template>

<xsl:template match="blockContainer[@class='address']">
	<Address>
		<xsl:apply-templates />
	</Address>
</xsl:template>

<xsl:template match="blockContainer[@class='address']/p">
	<AddressLine>
		<xsl:apply-templates />
	</AddressLine>
</xsl:template>

<xsl:template match="hcontainer[@name='signature']/content/block[@name='date']">
	<DateSigned>
		<xsl:if test="*[1]/@date castable as xs:date">
			<xsl:attribute name="Date">
				<xsl:value-of select="*[1]/@date" />
			</xsl:attribute>
		</xsl:if>
		<xsl:apply-templates />
	</DateSigned>
</xsl:template>

<xsl:template match="hcontainer[@name='signature']/content/block[@name='date']/date">
	<DateText>
		<xsl:apply-templates />
	</DateText>
</xsl:template>

<xsl:template match="person | role | organization | location">
	<xsl:apply-templates />
</xsl:template>


<!-- seal -->

<xsl:template match="img[@class='seal']">
	<LSseal>
		<xsl:attribute name="ResourceRef">
		</xsl:attribute>
	</LSseal>
</xsl:template>
<xsl:template match="date[@class='seal']">
	<LSseal>
		<xsl:attribute name="Date">
			<xsl:value-of select="@Date" />
		</xsl:attribute>
	</LSseal>
</xsl:template>
<xsl:template match="inline[@name='seal']">
	<LSseal>
		<xsl:apply-templates />
	</LSseal>
</xsl:template>
<xsl:template match="marker[@name='seal']">
	<LSseal />
</xsl:template>

</xsl:transform>
