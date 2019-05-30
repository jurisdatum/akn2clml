<?xml version="1.0" encoding="utf-8"?>

<xsl:transform version="3.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xpath-default-namespace="http://docs.oasis-open.org/legaldocml/ns/akn/3.0"
	xmlns:local="http://www.jurisdatum.com/tna/akn2clml"
	exclude-result-prefixes="xs local">


<!-- keys -->

<xsl:key name="tlc" match="TLCConcept | TLCProcess" use="@eId"/>


<!-- functions -->

<xsl:function name="local:long-type-from-short" as="xs:string">
	<xsl:param name="short-type" as="xs:string" />
	<xsl:choose>
		<xsl:when test="$short-type = 'asp'">
			<xsl:text>ScottishAct</xsl:text>
		</xsl:when>
	</xsl:choose>
</xsl:function>

<xsl:function name="local:category-from-short-type" as="xs:string">
	<xsl:param name="short-type" as="xs:string" />
	<xsl:choose>
		<xsl:when test="$short-type = ('asp')">
			<xsl:text>primary</xsl:text>
		</xsl:when>
	</xsl:choose>
</xsl:function>

<xsl:function name="local:resolve-tlc-show-as" as="xs:string">
	<xsl:param name="showAs" as="attribute()" />
	<xsl:variable name="components" as="xs:string*">
		<xsl:for-each select="tokenize(normalize-space($showAs), ' ')">
			<xsl:choose>
				<xsl:when test="starts-with(., '#')">
					<xsl:variable name="tlc" as="element()" select="key('tlc', substring(., 2), root($showAs))" />
					<xsl:sequence select="local:resolve-tlc-show-as($tlc/@showAs)" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:sequence select="." />
				</xsl:otherwise>
			</xsl:choose>
		</xsl:for-each>
	</xsl:variable>
	<xsl:value-of select="string-join($components, ' ')" />
</xsl:function>


<!-- variables -->

<xsl:variable name="doc-short-type" as="xs:string" select="/akomaNtoso/*/@name" />

<xsl:variable name="doc-long-type" as="xs:string">
	<xsl:value-of select="local:long-type-from-short($doc-short-type)" />
</xsl:variable>

<xsl:variable name="doc-category" as="xs:string">
	<xsl:value-of select="local:category-from-short-type($doc-short-type)" />
</xsl:variable>

<xsl:variable name="doc-subtype" as="xs:string" select="/akomaNtoso/*/meta/identification/FRBRWork/FRBRsubtype/@value" />

<xsl:variable name="doc-year" as="xs:integer" select="xs:integer(key('tlc', 'varActYear')/@showAs)" />

<xsl:variable name="doc-number" as="xs:string" select="key('tlc', 'varActNo')/@showAs" />

<xsl:variable name="doc-title" as="xs:string">
	<xsl:variable name="tlc" as="element()" select="key('tlc', 'varActTitle')" />
	<xsl:value-of select="local:resolve-tlc-show-as($tlc/@showAs)" />
</xsl:variable>

<xsl:variable name="doc-short-id" as="xs:string">
	<xsl:value-of select="concat($doc-short-type, '/', $doc-year, '/', $doc-number)" />
</xsl:variable>

<xsl:variable name="doc-long-id" as="xs:string">
	<xsl:value-of select="concat('http://www.legislation.gov.uk/', $doc-short-id)" />
</xsl:variable>

</xsl:transform>
