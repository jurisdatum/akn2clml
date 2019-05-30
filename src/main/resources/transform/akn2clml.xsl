<?xml version="1.0" encoding="utf-8"?>

<xsl:transform version="3.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xpath-default-namespace="http://docs.oasis-open.org/legaldocml/ns/akn/3.0"
	xmlns="http://www.legislation.gov.uk/namespaces/legislation"
	xmlns:local="http://www.jurisdatum.com/tna/akn2clml"
	exclude-result-prefixes="xs local">

<xsl:output method="xml" version="1.0" encoding="utf-8" omit-xml-declaration="no" indent="yes" />

<xsl:strip-space elements="*" />

<xsl:include href="metadata.xsl" />
<xsl:include href="prelims.xsl" />
<xsl:include href="context.xsl" />
<xsl:include href="amendments.xsl" />


<xsl:template match="/akomaNtoso">
	<xsl:apply-templates />
</xsl:template>

<xsl:template match="/akomaNtoso/*">
	<Legislation SchemaVersion="2.0">
		<xsl:call-template name="metadata" />
		<xsl:call-template name="main" />
		<xsl:call-template name="footnotes" />
	</Legislation>
</xsl:template>

<xsl:template name="main">
	<xsl:variable name="name" as="xs:string">
		<xsl:choose>
			<xsl:when test="$doc-category = 'primary'">
				<xsl:text>Primary</xsl:text>
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
	</xsl:element>
	<xsl:if test="exists(*[not(self::meta) and not(self::coverPage) and not(self::preface) and not(self::body)])">
		<xsl:message terminate="yes">
		</xsl:message>
	</xsl:if>
</xsl:template>


<!-- body -->

<xsl:template match="body">
	<xsl:param name="context" as="xs:string*" tunnel="yes" />
	<Body>
		<xsl:apply-templates>
			<xsl:with-param name="context" select="('Body', $context)" tunnel="yes" />
		</xsl:apply-templates>
	</Body>
</xsl:template>

<xsl:template match="section">
	<xsl:param name="context" as="xs:string*" tunnel="yes" />
	<P1group>
		<xsl:apply-templates select="heading" />
		<P1>
			<xsl:apply-templates select="*[not(self::heading)]">
				<xsl:with-param name="context" select="('P1', 'P1group', $context)" tunnel="yes" />
			</xsl:apply-templates>
		</P1>
	</P1group>
</xsl:template>

<xsl:template match="subsection">
	<xsl:call-template name="create-element-and-wrap-as-necessary">
		<xsl:with-param name="name" as="xs:string" select="'P2'" />
	</xsl:call-template>
</xsl:template>

<xsl:template match="paragraph">
	<xsl:call-template name="create-element-and-wrap-as-necessary">
		<xsl:with-param name="name" as="xs:string" select="'P3'" />
	</xsl:call-template>
</xsl:template>

<xsl:template match="num">
	<Pnumber>
		<xsl:apply-templates />
	</Pnumber>
</xsl:template>

<xsl:template match="heading">
	<Title>
		<xsl:apply-templates />
	</Title>
</xsl:template>

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
		<xsl:otherwise>
			<xsl:call-template name="create-element-and-wrap-as-necessary">
				<xsl:with-param name="name" as="xs:string" select="'Text'" />
			</xsl:call-template>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>


<!-- inline -->

<xsl:template match="docTitle | docNumber | docStage | docDate">
	<xsl:apply-templates />
</xsl:template>

<xsl:template match="ref[@class='placeholder']">
	<xsl:variable name="tlc" as="element()" select="key('tlc', substring(@href, 2))" />
	<xsl:value-of select="local:resolve-tlc-show-as($tlc/@showAs)" />
</xsl:template>

<xsl:template match="ref | rref">
	<xsl:apply-templates />
</xsl:template>


<!-- text -->

<xsl:template match="text()">
	<xsl:if test="starts-with(., ' ')">
		<xsl:text> </xsl:text>
	</xsl:if>
	<xsl:value-of select="normalize-space(.)" />
	<xsl:if test="ends-with(., ' ')">
		<xsl:text> </xsl:text>
	</xsl:if>
</xsl:template>


<!-- default -->

<xsl:template match="*">
	<xsl:message terminate="yes">
		<xsl:sequence select="." />
	</xsl:message>
</xsl:template>


<!-- footnotes -->

<xsl:template name="footnotes">
</xsl:template>

</xsl:transform>
