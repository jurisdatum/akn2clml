<?xml version="1.0" encoding="utf-8"?>

<xsl:transform version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xpath-default-namespace="http://docs.oasis-open.org/legaldocml/ns/akn/3.0"
	xmlns="http://www.legislation.gov.uk/namespaces/legislation"
	xmlns:ukakn="https://www.legislation.gov.uk/namespaces/UK-AKN"
	xmlns:ukl="http://www.legislation.gov.uk/namespaces/legislation"
	xmlns:ukl2="http://legislation.gov.uk/namespaces/legis"
	xmlns:local="http://www.jurisdatum.com/tna/akn2clml"
	exclude-result-prefixes="xs ukakn ukl ukl2 local">


<xsl:function name="local:get-target-class" as="xs:string?">
	<xsl:param name="qs" as="element(quotedStructure)" />
	<xsl:choose>
		<xsl:when test="exists($qs/@ukl:TargetClass)">
			<xsl:value-of select="$qs/@ukl:TargetClass" />
		</xsl:when>
		<xsl:when test="exists($qs/@ukl2:docName)">
			<xsl:value-of select="local:category-from-short-type($qs/@ukl2:docName)" />
		</xsl:when>
	</xsl:choose>
</xsl:function>

<xsl:function name="local:get-target-subclass" as="xs:string">
	<xsl:param name="qs" as="element(quotedStructure)" />
	<xsl:choose>
		<xsl:when test="exists($qs/@ukl:TargetSubClass)">
			<xsl:value-of select="$qs/@ukl:TargetSubClass" />
		</xsl:when>
		<xsl:otherwise>
			<xsl:text>unknown</xsl:text>
		</xsl:otherwise>
	</xsl:choose>
</xsl:function>

<xsl:function name="local:target-is-schedule" as="xs:boolean?">
	<xsl:param name="qs" as="element(quotedStructure)" />
	<xsl:choose>
		<xsl:when test="exists($qs/@ukl:Context)">
			<xsl:value-of select="$qs/@ukl:Context = 'schedule'" />
		</xsl:when>
		<xsl:when test="exists($qs/descendant::*[@class = ('schProv1', 'schProv2')])">
			<xsl:sequence select="true()" />
		</xsl:when>
		<xsl:otherwise>
			<xsl:sequence select="false()" />
		</xsl:otherwise>
	</xsl:choose>
</xsl:function>

<xsl:function name="local:get-structure-format" as="xs:string">
	<xsl:param name="s" as="element()" /> <!-- quotedStructure or embeddedStructure -->
	<xsl:choose>
		<xsl:when test="$s/@startQuote='“' and $s/@endQuote='”'">
			<xsl:text>double</xsl:text>
		</xsl:when>
		<xsl:when test="$s/@startQuote='‘' and $s/@endQuote='’'">
			<xsl:text>single</xsl:text>
		</xsl:when>
		<xsl:when test="empty($s/@startQuote) and empty($s/@endQuote)">
			<xsl:text>none</xsl:text>
		</xsl:when>
		<xsl:when test="$s/@startQuote='' and $s/@endQuote=''">
			<xsl:text>none</xsl:text>
		</xsl:when>
		<xsl:otherwise>
			<xsl:text>default</xsl:text>
		</xsl:otherwise>
	</xsl:choose>
</xsl:function>

<xsl:template name="block-with-mod">
	<xsl:if test="exists(node()[not(self::mod) and not(self::text()[not(normalize-space())]) and not(self::inline/@name='AppendText')])">
		<xsl:message terminate="yes" />
	</xsl:if>
	<xsl:apply-templates />
</xsl:template>

<xsl:template match="mod">
	<xsl:choose>
		<xsl:when test="empty(quotedStructure)">
			<Text>
				<xsl:apply-templates />
			</Text>
		</xsl:when>
		<xsl:otherwise>
			<xsl:if test="count(quotedStructure) gt 1">
				<xsl:message terminate="yes">
					<xsl:sequence select="." />
				</xsl:message>
			</xsl:if>
			<xsl:variable name="before" as="node()*" select="quotedStructure/preceding-sibling::node()" />
			<xsl:if test="exists($before) and not(every $n in $before satisfies ($n/self::text() and not(normalize-space($n))))">
				<Text>
					<xsl:apply-templates select="$before" />
				</Text>
			</xsl:if>
			<xsl:apply-templates select="quotedStructure" />
			<xsl:apply-templates select="quotedStructure/following-sibling::node()" />
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template match="quotedStructure">
	<xsl:param name="context" as="xs:string*" tunnel="yes" />
	<BlockAmendment>
		<xsl:attribute name="TargetClass">
			<xsl:value-of select="local:get-target-class(.)" />
		</xsl:attribute>
		<xsl:attribute name="TargetSubClass">
			<xsl:value-of select="local:get-target-subclass(.)" />
		</xsl:attribute>
		<xsl:attribute name="Context">
			<xsl:choose>
				<xsl:when test="exists(@ukl:Context)">
					<xsl:value-of select="@ukl:Context" />
				</xsl:when>
				<xsl:when test="local:target-is-schedule(.)">
					<xsl:text>schedule</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>main</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:attribute>
		<xsl:attribute name="Format">
			<xsl:value-of select="local:get-structure-format(.)" />
		</xsl:attribute>
		<xsl:choose>
			<xsl:when test="exists(*) and (every $child in * satisfies $child/self::hcontainer[@name='definition'])">
				<xsl:call-template name="definition-list">
					<xsl:with-param name="definitions" select="*" />
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="exists(hcontainer[@name='definition']) and (every $child in * satisfies ($child/self::p or $child/self::hcontainer[@name='definition']))">
				<xsl:call-template name="group-definitions-for-block-amendment">
					<xsl:with-param name="elements" select="*" />
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates>
					<xsl:with-param name="context" select="('BlockAmendment', $context)" tunnel="yes" />
				</xsl:apply-templates>
			</xsl:otherwise>
		</xsl:choose>
	</BlockAmendment>
</xsl:template>

<xsl:template match="inline[@name='AppendText']">
	<AppendText>
		<xsl:apply-templates />
	</AppendText>
</xsl:template>

<xsl:template match="quotedText">
	<InlineAmendment>
		<xsl:value-of select="@startQuote" />
		<xsl:apply-templates />
		<xsl:value-of select="@endtQuote" />
	</InlineAmendment>
</xsl:template>

<xsl:template match="embeddedStructure">
	<xsl:param name="context" as="xs:string*" tunnel="yes" />
	<BlockExtract>
		<xsl:attribute name="SourceClass">
			<xsl:value-of select="if (exists(@ukl:SourceClass)) then @ukl:SourceClass else 'unknown'" />
		</xsl:attribute>
		<xsl:attribute name="SourceSubClass">
			<xsl:value-of select="if (exists(@ukl:SourceSubClass)) then @ukl:SourceSubClass else 'unknown'" />
		</xsl:attribute>
		<xsl:attribute name="Context">
			<xsl:value-of select="if (exists(@ukl:Context)) then @ukl:Context else 'unknown'" />
		</xsl:attribute>
		<xsl:attribute name="Format">
			<xsl:value-of select="local:get-structure-format(.)" />
		</xsl:attribute>
		<xsl:choose>
			<xsl:when test="exists(*) and (every $child in * satisfies $child/self::hcontainer[@name='definition'])">
				<xsl:call-template name="definition-list">
					<xsl:with-param name="definitions" select="*" />
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="exists(hcontainer[@name='definition']) and (every $child in * satisfies ($child/self::p or $child/self::hcontainer[@name='definition']))">
				<xsl:call-template name="group-definitions-for-block-amendment">
					<xsl:with-param name="elements" select="*" />
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates>
					<xsl:with-param name="context" select="('BlockExtract', $context)" tunnel="yes" />
				</xsl:apply-templates>
			</xsl:otherwise>
		</xsl:choose>
	</BlockExtract>
</xsl:template>

</xsl:transform>
