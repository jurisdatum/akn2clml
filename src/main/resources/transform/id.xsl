<?xml version="1.0" encoding="utf-8"?>

<xsl:transform version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xpath-default-namespace="http://docs.oasis-open.org/legaldocml/ns/akn/3.0"
	xmlns="http://www.legislation.gov.uk/namespaces/legislation"
	xmlns:uk="https://www.legislation.gov.uk/namespaces/UK-AKN"
	xmlns:local="http://www.jurisdatum.com/tna/akn2clml"
	exclude-result-prefixes="xs uk local">

<xsl:key name="internal-refs" match="ref[starts-with(@href,'#')]" use="substring(@href, 2)" />
<xsl:key name="internal-refs-by-guid" match="ref[exists(@uk:targetGuid)]" use="@uk:targetGuid" />

<xsl:function name="local:element-id-is-necessary" as="xs:boolean">
	<xsl:param name="e" as="element()" />
	<xsl:variable name="ref-to-id-exists" as="xs:boolean" select="exists($e/@eId) and exists(key('internal-refs', $e/@eId, root($e)))" />
	<xsl:variable name="ref-to-guid-exists" as="xs:boolean" select="exists($e/@GUID) and exists(key('internal-refs-by-guid', $e/@GUID, root($e)))" />
	<xsl:sequence select="$ref-to-id-exists or $ref-to-guid-exists" />
</xsl:function>

<xsl:template match="authorialNote[@class='referenceNote']" mode="remove-schedule-reference" />
<xsl:template match="@*|*|processing-instruction()|comment()" mode="remove-schedule-reference">
	<xsl:copy>
		<xsl:apply-templates select="*|@*|text()|processing-instruction()|comment()" mode="remove-schedule-reference" />
	</xsl:copy>
</xsl:template>

<xsl:function name="local:make-id-from-number-1" as="xs:string">
	<xsl:param name="num" as="element(num)" />
	<xsl:variable name="num" as="element(num)">
		<xsl:apply-templates select="$num" mode="remove-schedule-reference" />
	</xsl:variable>
	<xsl:sequence select="translate(lower-case(normalize-space(string($num))), ' ', '-')" />
</xsl:function>

<xsl:function name="local:make-id-from-number-2" as="xs:string">
	<xsl:param name="prefix" as="xs:string" />
	<xsl:param name="num" as="element(num)" />
	<xsl:sequence select="concat($prefix, '-', local:strip-punctuation-from-number(string($num)))" />
</xsl:function>

<xsl:function name="local:make-internal-id" as="xs:string">
	<xsl:param name="e" as="element()" />
	<xsl:choose>
		<xsl:when test="exists($e/ancestor::quotedStructure)">
			<xsl:sequence select="generate-id($e)" />
		</xsl:when>
		<xsl:when test="$e/self::part">
			<xsl:sequence select="local:make-id-from-number-1($e/num)" />
		</xsl:when>
		<xsl:when test="$e/self::chapter">
			<xsl:sequence select="local:make-id-from-number-1($e/num)" />
		</xsl:when>
		<xsl:when test="$e/self::hcontainer[@name=('crossheading','subheading')]">
			<xsl:sequence select="translate(lower-case(normalize-space($e/heading)), ' ', '-')" />
		</xsl:when>
		<xsl:when test="$e/self::section or $e/self::article or $e/self::rule">
			<xsl:sequence select="concat(local-name($e), '-', local:strip-punctuation-from-number(string($e/num)))" />
		</xsl:when>
		<xsl:when test="$e/self::hcontainer[@name='regulation']">
			<xsl:sequence select="concat($e/@name, '-', local:strip-punctuation-from-number(string($e/num)))" />
		</xsl:when>
		<xsl:when test="$e/self::paragraph and exists($e/ancestor::hcontainer[@name='schedule']) and empty($e/ancestor::paragraph)">
			<xsl:sequence select="concat(local:make-internal-id($e/ancestor::hcontainer[@name='schedule']), '-paragraph-', local:strip-punctuation-from-number(string($e/num)))" />
		</xsl:when>
		<xsl:when test="$e/self::subsection or $e/self::paragraph or $e/self::subparagraph or $e/self::clause or $e/self::subclause">
			<xsl:sequence select="concat(local:make-internal-id($e/..), '-', local:strip-punctuation-from-number(string($e/num)))" />
		</xsl:when>
		<xsl:when test="$e/self::hcontainer[@name='schedule']">
			<xsl:sequence select="local:make-id-from-number-1($e/num)" />
		</xsl:when>
		<xsl:otherwise>
			<xsl:sequence select="generate-id($e)" />
		</xsl:otherwise>
	</xsl:choose>
</xsl:function>

<xsl:template name="add-id-if-necessary">
	<xsl:param name="e" as="element()" select="." />
	<xsl:if test="local:element-id-is-necessary($e)">
		<xsl:attribute name="id">
			<xsl:sequence select="local:make-internal-id($e)" />
		</xsl:attribute>
	</xsl:if>
</xsl:template>

<xsl:function name="local:make-internal-id-for-href" as="xs:string?">
	<xsl:param name="href" as="attribute()" />
	<xsl:if test="starts-with($href, '#')">
		<xsl:variable name="ref-id" as="xs:string" select="substring($href, 2)" />
		<xsl:variable name="e" as="element()?" select="key('id', $ref-id, root($href))[1]" />
		<xsl:if test="exists($e)">
			<xsl:sequence select="local:make-internal-id($e)" />
		</xsl:if>
	</xsl:if>
</xsl:function>

</xsl:transform>
