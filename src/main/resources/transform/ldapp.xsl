<?xml version="1.0" encoding="utf-8"?>

<xsl:transform version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xpath-default-namespace="http://docs.oasis-open.org/legaldocml/ns/akn/3.0"
	xmlns="http://www.legislation.gov.uk/namespaces/legislation"
	xmlns:uk="https://www.legislation.gov.uk/namespaces/UK-AKN"
	xmlns:local="http://www.jurisdatum.com/tna/akn2clml"
	xmlns:ldapp="ldapp"
	exclude-result-prefixes="xs uk local ldapp">

<xsl:function name="ldapp:resolve-tlc-show-as" as="xs:string">
	<xsl:param name="showAs" as="attribute()" />
	<xsl:variable name="components" as="xs:string*">
		<xsl:for-each select="tokenize(normalize-space($showAs), ' ')">
			<xsl:choose>
				<xsl:when test="starts-with(., '#')">
					<xsl:variable name="tlc" as="element()" select="key('tlc', substring(., 2), root($showAs))" />
					<xsl:sequence select="ldapp:resolve-tlc-show-as($tlc/@showAs)" />
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
	<xsl:choose>
		<xsl:when test="$doc-category = 'primary'">
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
		</xsl:when>
		<xsl:when test="$doc-category = 'secondary'">
			<xsl:variable name="var-si-year" as="xs:string?" select="key('tlc', 'varSIYear')/@showAs" />
			<xsl:choose>
				<xsl:when test="$var-si-year castable as xs:integer">
					<xsl:value-of select="xs:integer($var-si-year)" />
				</xsl:when>
			</xsl:choose>
		</xsl:when>
	</xsl:choose>
</xsl:variable>

<xsl:variable name="ldapp-doc-number" as="xs:string?">
	<xsl:choose>
		<xsl:when test="$doc-category = 'primary'">
			<xsl:variable name="var-act-no" as="xs:string?" select="key('tlc', 'varActNo')/@showAs" />
			<xsl:variable name="frbr" as="xs:string?" select="/akomaNtoso/*/meta/identification/FRBRWork/FRBRnumber/@value" />
			<xsl:choose>
				<xsl:when test="$var-act-no castable as xs:integer">
					<xsl:sequence select="$var-act-no" />
				</xsl:when>
				<xsl:when test="$frbr castable as xs:integer">
					<xsl:sequence select="$frbr" />
				</xsl:when>
			</xsl:choose>
		</xsl:when>
		<xsl:when test="$doc-category = 'secondary'">
			<xsl:variable name="var-si-no-comp" as="xs:string?" select="key('tlc', 'varSINoComp')/@showAs" />
			<xsl:variable name="frbr" as="xs:string?" select="/akomaNtoso/*/meta/identification/FRBRWork/FRBRnumber/@value" />
			<xsl:choose>
				<xsl:when test="$var-si-no-comp castable as xs:integer">
					<xsl:sequence select="$var-si-no-comp" />
				</xsl:when>
				<xsl:when test="$frbr castable as xs:integer">
					<xsl:sequence select="$frbr" />
				</xsl:when>
			</xsl:choose>
		</xsl:when>
	</xsl:choose>
</xsl:variable>

<xsl:variable name="ldapp-doc-subsid-numbers" as="xs:string*">
	<xsl:variable name="subsid-nos" as="attribute()?" select="key('tlc', 'varSISubsidiaryNos')/@showAs" />
	<xsl:if test="exists($subsid-nos)">
		<xsl:analyze-string select="$subsid-nos" regex="\((C|W)\. ?(\d+)\)">
			<xsl:matching-substring>
				<xsl:sequence select="concat(regex-group(1), ' ', regex-group(2))" />
			</xsl:matching-substring>
		</xsl:analyze-string>
	</xsl:if>
</xsl:variable>

<xsl:variable name="ldapp-doc-title" as="xs:string?">	<xsl:variable name="var-act-no" as="xs:string?" select="key('tlc', 'varActNo')/@showAs" />
	<xsl:choose>
		<xsl:when test="$doc-category = 'primary'">
			<xsl:variable name="var-act-title" as="attribute()?" select="key('tlc', 'varActTitle')/@showAs" />
			<xsl:variable name="doc-title" as="element(docTitle)?" select="(//docTitle)[1]" />
			<xsl:variable name="var-bill-title" as="attribute()?" select="key('tlc', 'varBillTitle')/@showAs" />
			<xsl:choose>
				<xsl:when test="normalize-space($var-act-title)">
					<xsl:value-of select="ldapp:resolve-tlc-show-as($var-act-title)" />
				</xsl:when>
				<xsl:when test="normalize-space($doc-title)">
					<xsl:value-of select="normalize-space($doc-title)" />
				</xsl:when>
				<xsl:when test="normalize-space($var-bill-title)">
					<xsl:value-of select="ldapp:resolve-tlc-show-as($var-bill-title)" />
				</xsl:when>
			</xsl:choose>
		</xsl:when>
		<xsl:when test="$doc-category = 'secondary'">
			<xsl:variable name="var-si-title" as="attribute()?" select="key('tlc', 'varSITitle')/@showAs" />
			<xsl:variable name="doc-title" as="element(docTitle)?" select="(//docTitle)[1]" />
			<xsl:choose>
				<xsl:when test="normalize-space($var-si-title)">
					<xsl:value-of select="ldapp:resolve-tlc-show-as($var-si-title)" />
				</xsl:when>
				<xsl:when test="normalize-space($doc-title)">
					<xsl:value-of select="normalize-space($doc-title)" />
				</xsl:when>
			</xsl:choose>
		</xsl:when>
	</xsl:choose>
</xsl:variable>


<!-- dates -->

<xsl:variable name="ldapp-made-date" as="xs:date?">
	<xsl:variable name="var-made-date" as="attribute()?" select="key('tlc', 'varMadeDate')/@showAs" />
	<xsl:variable name="substring" as="xs:string" select="substring($var-made-date, 1, 10)" />
	<xsl:if test="$substring castable as xs:date">
		<xsl:sequence select="xs:date($substring)" />
	</xsl:if>
</xsl:variable>


<!-- placeholders -->

<xsl:template match="ref[@class='placeholder']">
	<xsl:variable name="tlc" as="element()" select="key('tlc', substring(@href, 2))" />
	<xsl:choose>
		<xsl:when test="empty(node())">
			<xsl:value-of select="ldapp:resolve-tlc-show-as($tlc/@showAs)" />
		</xsl:when>
		<xsl:otherwise>
			<xsl:apply-templates />
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>


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
