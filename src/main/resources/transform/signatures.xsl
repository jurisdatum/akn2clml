<?xml version="1.0" encoding="utf-8"?>

<xsl:transform version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xpath-default-namespace="http://docs.oasis-open.org/legaldocml/ns/akn/3.0"
	xmlns="http://www.legislation.gov.uk/namespaces/legislation"
	xmlns:local="http://www.jurisdatum.com/tna/akn2clml"
	exclude-result-prefixes="xs local">

<xsl:template match="hcontainer[@name='signatures']">
	<xsl:param name="context" as="xs:string*" tunnel="yes" />
	<SignedSection>
		<xsl:choose>
			<xsl:when test="empty(hcontainer[@name='signatureGroup']) and empty(hcontainer[@name='signature'])">
				<xsl:apply-templates>
					<xsl:with-param name="context" select="('SignedSection', $context)" tunnel="yes" />
				</xsl:apply-templates>
			</xsl:when>
			<xsl:when test="empty(hcontainer[@name='signatureGroup'])">
				<xsl:call-template name="signatory">
					<xsl:with-param name="context" select="('SignedSection', $context)" tunnel="yes" />
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates>
					<xsl:with-param name="context" select="('SignedSection', $context)" tunnel="yes" />
				</xsl:apply-templates>
			</xsl:otherwise>
		</xsl:choose>
	</SignedSection>
</xsl:template>

<xsl:template match="hcontainer[@name='signatureGroup']" name="signatory">
	<xsl:param name="context" as="xs:string*" tunnel="yes" />
	<Signatory>
		<xsl:apply-templates>
			<xsl:with-param name="context" select="('Signatory', $context)" tunnel="yes" />
		</xsl:apply-templates>
	</Signatory>
</xsl:template>

<xsl:template match="hcontainer[@name='signature']">
	<xsl:param name="context" as="xs:string*" tunnel="yes" />
	<Signee>
		<xsl:apply-templates>
			<xsl:with-param name="context" select="('Signee', $context)" tunnel="yes" />
		</xsl:apply-templates>
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

<xsl:template match="p[img[@class='seal']] | p[date[@class='seal']] | p[inline[@name='seal']] | p[marker[@name='seal']]">
	<xsl:apply-templates />
</xsl:template>

<xsl:template match="img[@class='seal']">
	<LSseal>
		<xsl:attribute name="ResourceRef">
			<xsl:value-of select="local:make-resource-id(.)" />
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
