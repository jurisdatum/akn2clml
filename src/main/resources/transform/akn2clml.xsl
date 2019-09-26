<?xml version="1.0" encoding="utf-8"?>

<xsl:transform version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xpath-default-namespace="http://docs.oasis-open.org/legaldocml/ns/akn/3.0"
	xmlns="http://www.legislation.gov.uk/namespaces/legislation"
	xmlns:ukl="http://www.legislation.gov.uk/namespaces/legislation"
	xmlns:local="http://www.jurisdatum.com/tna/akn2clml"
	exclude-result-prefixes="xs ukl local">

<xsl:output method="xml" version="1.0" encoding="utf-8" omit-xml-declaration="no" indent="yes" xmlns:ukl="http://www.legislation.gov.uk/namespaces/legislation" />

<xsl:strip-space elements="*" />

<xsl:include href="ldapp.xsl" />
<xsl:include href="globals.xsl" />
<xsl:include href="metadata.xsl" />
<xsl:include href="context.xsl" />
<xsl:include href="prelims.xsl" />
<xsl:include href="structure.xsl" />
<xsl:include href="numbers.xsl" />
<xsl:include href="lists.xsl" />
<xsl:include href="tables.xsl" />
<xsl:include href="images.xsl" />
<xsl:include href="amendments.xsl" />
<xsl:include href="citations.xsl" />
<xsl:include href="forms.xsl" />
<xsl:include href="footnotes.xsl" />
<xsl:include href="signatures.xsl" />
<xsl:include href="explanatory.xsl" />
<xsl:include href="changes.xsl" />
<xsl:include href="math.xsl" />
<xsl:include href="resources.xsl" />


<xsl:template match="/akomaNtoso">
	<xsl:apply-templates />
</xsl:template>

<xsl:template match="/akomaNtoso/*">
	<Legislation SchemaVersion="2.0">
		<xsl:call-template name="add-fragment-attributes" />
		<xsl:call-template name="metadata" />
		<xsl:if test="exists(body)">
			<xsl:call-template name="main" />
		</xsl:if>
		<xsl:call-template name="footnotes" />
		<xsl:call-template name="resources" />
		<xsl:call-template name="commentaries" />
	</Legislation>
</xsl:template>

<xsl:template name="main">
	<xsl:variable name="name" as="xs:string?">
		<xsl:choose>
			<xsl:when test="$doc-category = 'primary'">
				<xsl:text>Primary</xsl:text>
			</xsl:when>
			<xsl:when test="$doc-category = 'secondary'">
				<xsl:text>Secondary</xsl:text>
			</xsl:when>
		</xsl:choose>
	</xsl:variable>
	<xsl:element name="{ $name }">
		<xsl:call-template name="prelims">
			<xsl:with-param name="context" select="$name" tunnel="yes" />
		</xsl:call-template>
		<xsl:apply-templates select="body">
			<xsl:with-param name="context" select="$name" tunnel="yes" />
		</xsl:apply-templates>
		<xsl:apply-templates select="conclusions">
			<xsl:with-param name="context" select="$name" tunnel="yes" />
		</xsl:apply-templates>
	</xsl:element>
	<xsl:if test="exists(*[not(self::meta) and not(self::coverPage) and not(self::preface) and not(self::preamble) and not(self::body) and not(self::conclusions)])">
		<xsl:message terminate="yes">
		</xsl:message>
	</xsl:if>
</xsl:template>


<!-- body -->

<xsl:template match="body">
	<xsl:param name="context" as="xs:string*" tunnel="yes" />
	<Body>
		<xsl:call-template name="add-fragment-attributes" />
		<xsl:apply-templates select="*[not(self::hcontainer[@name='schedules'])]">
			<xsl:with-param name="context" select="('Body', $context)" tunnel="yes" />
		</xsl:apply-templates>
	</Body>
	<xsl:if test="exists(hcontainer[@name='schedules']/following-sibling::node())">
		<xsl:message terminate="yes" />
	</xsl:if>
	<xsl:apply-templates select="hcontainer[@name='schedules']" />
</xsl:template>


<!-- blocks -->

<xsl:template match="intro | content | wrapUp">
	<xsl:apply-templates />
</xsl:template>

<xsl:template match="p">
	<xsl:param name="context" as="xs:string*" tunnel="yes" />
	<xsl:choose>
		<xsl:when test="exists(mod)">
			<xsl:call-template name="wrap-as-necessary">
				<xsl:with-param name="clml" as="element()+">
					<xsl:call-template name="block-with-mod">
						<xsl:with-param name="context" select="(local:get-block-wrapper($context), $context)" tunnel="yes" />
					</xsl:call-template>
				</xsl:with-param>
			</xsl:call-template>
		</xsl:when>
		<xsl:when test="exists(embeddedStructure)">
			<xsl:apply-templates />
		</xsl:when>
		<xsl:otherwise>
			<xsl:call-template name="create-element-and-wrap-as-necessary">
				<xsl:with-param name="name" as="xs:string" select="'Text'" />
			</xsl:call-template>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template match="blockContainer">
	<xsl:call-template name="create-element-and-wrap-as-necessary">
		<xsl:with-param name="name" as="xs:string" select="'BlockText'" />
	</xsl:call-template>
</xsl:template>


<!-- inline -->

<xsl:template match="i">
	<Emphasis>
		<xsl:apply-templates />
	</Emphasis>
</xsl:template>

<xsl:template match="b">
	<Strong>
		<xsl:apply-templates />
	</Strong>
</xsl:template>

<xsl:template match="u">
	<Underline>
		<xsl:apply-templates />
	</Underline>
</xsl:template>

<xsl:template match="inline[@name='smallCaps']">
	<SmallCaps>
		<xsl:apply-templates />
	</SmallCaps>
</xsl:template>

<xsl:template match="sup">
	<Superior>
		<xsl:apply-templates />
	</Superior>
</xsl:template>

<xsl:template match="sub">
	<Inferior>
		<xsl:apply-templates />
	</Inferior>
</xsl:template>

<xsl:template match="docTitle | shortTitle | docNumber | docStage | docDate">
	<xsl:apply-templates />
</xsl:template>

<xsl:template match="abbr">
	<xsl:element name="{ if (@class = 'acronym') then 'Acronym' else 'Abbreviation' }">
		<xsl:if test="exists(@title)">
			<xsl:attribute name="Expansion">
				<xsl:value-of select="@title" />
			</xsl:attribute>
		</xsl:if>
		<xsl:copy-of select="@xml:lang" />
		<xsl:apply-templates />
	</xsl:element>
</xsl:template>

<xsl:template match="def">
	<Definition>
		<xsl:apply-templates />
	</Definition>
</xsl:template>

<xsl:template match="term">
	<Term>
		<xsl:apply-templates />
	</Term>
</xsl:template>

<xsl:template match="span">
	<Span>
		<xsl:apply-templates />
	</Span>
</xsl:template>

<xsl:template match="span[@ukl:Name]">
	<Character Name="{ @ukl:Name }" />
</xsl:template>


<!-- text -->

<xsl:template match="text()">
	<xsl:param name="context" as="xs:string*" tunnel="yes" />
	<xsl:choose>
		<xsl:when test="local:should-strip-punctuation-from-number(., $context)">
			<xsl:call-template name="strip-punctuation-from-number" />
		</xsl:when>
		<xsl:otherwise>
			<xsl:if test="starts-with(., ' ')">
				<xsl:text> </xsl:text>
			</xsl:if>
			<xsl:value-of select="normalize-space(.)" />
			<xsl:if test="ends-with(., ' ')">
				<xsl:text> </xsl:text>
			</xsl:if>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>


<!-- default -->

<xsl:template match="*">
	<xsl:message terminate="yes">
		<xsl:sequence select="." />
	</xsl:message>
</xsl:template>

</xsl:transform>
