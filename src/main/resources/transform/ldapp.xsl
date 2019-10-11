<?xml version="1.0" encoding="utf-8"?>

<xsl:transform version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xpath-default-namespace="http://docs.oasis-open.org/legaldocml/ns/akn/3.0"
	xmlns="http://www.legislation.gov.uk/namespaces/legislation"
	xmlns:uk="https://www.legislation.gov.uk/namespaces/UK-AKN"
	xmlns:local="http://www.jurisdatum.com/tna/akn2clml"
	exclude-result-prefixes="xs uk local">

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

<xsl:variable name="ldapp-doc-subtype" as="xs:string?">
	<xsl:variable name="frbr" as="xs:string?" select="/akomaNtoso/*/meta/identification/FRBRWork/FRBRsubtype/@value" />
	<xsl:variable name="var-doc-subtype" as="xs:string?" select="key('tlc', 'varDocSubType')/@showAs" />
	<xsl:choose>
		<xsl:when test="$frbr = '#varDocSubType'">
			<xsl:value-of select="$var-doc-subtype" />
		</xsl:when>
		<xsl:when test="normalize-space($frbr)">
			<xsl:value-of select="$frbr" />
		</xsl:when>
		<xsl:when test="exists($var-doc-subtype)">
			<xsl:value-of select="$var-doc-subtype" />
		</xsl:when>
	</xsl:choose>
</xsl:variable>

<xsl:variable name="ldapp-doc-year" as="xs:integer?">
	<xsl:variable name="var-act-year" as="xs:string?" select="key('tlc', 'varActYear')/@showAs" />
	<xsl:variable name="var-passed-date" as="xs:string?" select="key('tlc', 'varPassedDate')/@showAs" />
	<xsl:variable name="var-assent-date" as="xs:string?" select="key('tlc', 'varAssentDate')/@showAs" />
	<xsl:variable name="var-bill-year" as="xs:string?" select="key('tlc', 'varBillYear')/@showAs" />
	<xsl:choose>
		<xsl:when test="$var-act-year castable as xs:integer">
			<xsl:value-of select="xs:integer($var-act-year)" />
		</xsl:when>
		<xsl:when test="$var-passed-date castable as xs:date">
			<xsl:value-of select="xs:integer(substring($var-passed-date, 1, 4))" />
		</xsl:when>
		<xsl:when test="$var-assent-date castable as xs:date">
			<xsl:value-of select="xs:integer(substring($var-assent-date, 1, 4))" />
		</xsl:when>
		<xsl:when test="$var-bill-year castable as xs:integer">
			<xsl:value-of select="xs:integer($var-bill-year)" />
		</xsl:when>
	</xsl:choose>
</xsl:variable>

<xsl:variable name="ldapp-doc-number" as="xs:string?">
	<xsl:variable name="var-act-no" as="xs:string?" select="key('tlc', 'varActNo')/@showAs" />
	<xsl:variable name="frbr" as="xs:string?" select="/akomaNtoso/*/meta/identification/FRBRWork/FRBRnumber/@value" />
	<xsl:variable name="var-project-id" as="xs:string?" select="key('tlc', 'varProjectId')/@showAs" />
	<xsl:choose>
		<xsl:when test="$var-act-no castable as xs:integer">
			<xsl:value-of select="$var-act-no" />
		</xsl:when>
		<xsl:when test="$frbr castable as xs:integer">
			<xsl:value-of select="$frbr" />
		</xsl:when>
		<xsl:when test="$var-project-id castable as xs:integer">
			<xsl:value-of select="$var-project-id" />
		</xsl:when>
	</xsl:choose>
</xsl:variable>

<xsl:variable name="ldapp-doc-title" as="xs:string?">	<xsl:variable name="var-act-no" as="xs:string?" select="key('tlc', 'varActNo')/@showAs" />
	<xsl:variable name="var-act-title" as="attribute()?" select="key('tlc', 'varActTitle')/@showAs" />
	<xsl:variable name="doc-title" as="element(docTitle)?" select="(//docTitle)[1]" />
	<xsl:variable name="var-bill-title" as="attribute()?" select="key('tlc', 'varBillTitle')/@showAs" />
	<xsl:choose>
		<xsl:when test="normalize-space($var-act-title)">
			<xsl:value-of select="local:resolve-tlc-show-as($var-act-title)" />
		</xsl:when>
		<xsl:when test="normalize-space($doc-title)">
			<xsl:value-of select="$doc-title" />
		</xsl:when>
		<xsl:when test="normalize-space($var-bill-title)">
			<xsl:value-of select="local:resolve-tlc-show-as($var-bill-title)" />
		</xsl:when>
	</xsl:choose>
</xsl:variable>


<!-- placeholders -->

<xsl:template match="ref[@class='placeholder']">
	<xsl:variable name="tlc" as="element()" select="key('tlc', substring(@href, 2))" />
	<xsl:value-of select="local:resolve-tlc-show-as($tlc/@showAs)" />
</xsl:template>


<!-- back cover -->

<xsl:template match="conclusions[@eId='backCover']" />
<xsl:template match="conclusions[@eId='backCover']/*" />


<!-- GUIDs -->

<xsl:function name="local:make-internal-id-for-target-guid" as="xs:string?">
	<xsl:param name="guid" as="attribute(uk:targetGuid)" />
	<xsl:variable name="e" as="element()?" select="key('guid', string($guid), root($guid))[1]" />
	<xsl:if test="exists($e)">
		<xsl:sequence select="local:make-internal-id($e)" />
	</xsl:if>
</xsl:function>

<xsl:function name="local:make-internal-id-for-ldapp-ref" as="xs:string?">
	<xsl:param name="ref" as="element(ref)" />
	<xsl:if test="exists($ref/@uk:targetGuid)">
		<xsl:sequence select="local:make-internal-id-for-target-guid($ref/@uk:targetGuid)" />
	</xsl:if>
</xsl:function>

<xsl:function name="local:make-internal-ids-for-ldapp-rref" as="xs:string*">
	<xsl:param name="ref" as="element(rref)" />
	<xsl:variable name="from" as="element()?" select="if (exists($ref/@uk:fromGuid)) then key('guid', string($ref/@uk:fromGuid), root($ref))[1] else ()" />
	<xsl:variable name="up-to" as="element()?" select="if (exists($ref/@uk:upToGuid)) then key('guid', string($ref/@uk:upToGuid), root($ref))[1] else ()" />
	<xsl:if test="exists($from) and exists($up-to)">
		<xsl:sequence select="(local:make-internal-id($from), local:make-internal-id($up-to))" />
	</xsl:if>
</xsl:function>

</xsl:transform>
