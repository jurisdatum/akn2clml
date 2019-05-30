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
		<xsl:apply-templates select="*[not(self::hcontainer[@name='schedules'])]">
			<xsl:with-param name="context" select="('Body', $context)" tunnel="yes" />
		</xsl:apply-templates>
	</Body>
	<xsl:if test="exists(hcontainer[@name='schedules']/following-sibling::node())">
		<xsl:message terminate="yes" />
	</xsl:if>
	<xsl:apply-templates select="hcontainer[@name='schedules']" />
</xsl:template>

<xsl:template match="part">
	<xsl:call-template name="create-element-and-wrap-as-necessary">
		<xsl:with-param name="name" as="xs:string" select="'Part'" />
	</xsl:call-template>
</xsl:template>

<xsl:template match="chapter">
	<xsl:call-template name="create-element-and-wrap-as-necessary">
		<xsl:with-param name="name" as="xs:string" select="'Chapter'" />
	</xsl:call-template>
</xsl:template>

<xsl:template match="hcontainer[@name='crossheading']">
	<xsl:call-template name="create-element-and-wrap-as-necessary">
		<xsl:with-param name="name" as="xs:string" select="'Pblock'" />
	</xsl:call-template>
</xsl:template>

<xsl:template match="hcontainer[@name='subheading']">
	<xsl:call-template name="create-element-and-wrap-as-necessary">
		<xsl:with-param name="name" as="xs:string" select="'PsubBlock'" />
	</xsl:call-template>
</xsl:template>


<!-- numbered paragraphs -->

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

<xsl:template match="paragraph | subparagraph | hcontainer[@name=('subsubparagraph','step')]">
	<xsl:param name="context" as="xs:string*" tunnel="yes" />
	<xsl:variable name="name" as="xs:string">
		<xsl:choose>
			<xsl:when test="head($context) = ('Pblock', 'PsubBlock', 'ScheduleBody')">
				<xsl:text>P1</xsl:text>
			</xsl:when>
			<xsl:when test="head($context) = ('P1')">
				<xsl:text>P2</xsl:text>
			</xsl:when>
			<xsl:when test="head($context) = ('P2')">
				<xsl:text>P3</xsl:text>
			</xsl:when>
			<xsl:when test="head($context) = ('P3')">
				<xsl:text>P4</xsl:text>
			</xsl:when>
			<xsl:when test="head($context) = ('P4')">
				<xsl:text>P5</xsl:text>
			</xsl:when>
			<xsl:when test="head($context) = ('P5')">
				<xsl:text>P6</xsl:text>
			</xsl:when>
			<xsl:when test="head($context) = ('P6')">
				<xsl:text>P7</xsl:text>
			</xsl:when>
			<xsl:when test="head($context) = ('P7')">
				<xsl:text>P7</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:message terminate="yes">
					<xsl:sequence select="$context" />
				</xsl:message>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	<xsl:call-template name="create-element-and-wrap-as-necessary">
		<xsl:with-param name="name" as="xs:string" select="$name" />
	</xsl:call-template>
</xsl:template>

<xsl:template match="hcontainer[@name='definition']">
	<xsl:apply-templates />
</xsl:template>


<!-- schedules -->

<xsl:template match="hcontainer[@name='schedules']">
	<xsl:param name="context" as="xs:string*" tunnel="yes" />
	<Schedules>
		<xsl:apply-templates>
			<xsl:with-param name="context" select="('Schedules', $context)" tunnel="yes" />
		</xsl:apply-templates>
	</Schedules>
</xsl:template>

<xsl:template match="hcontainer[@name='schedule']">
	<xsl:param name="context" as="xs:string*" tunnel="yes" />
	<xsl:variable name="child-context" as="xs:string*" select="('Schedule', $context)" />
	<Schedule>
		<xsl:apply-templates select="num">
			<xsl:with-param name="context" select="$child-context" tunnel="yes" />
		</xsl:apply-templates>
		<xsl:if test="exists(heading)">
			<TitleBlock>
				<xsl:apply-templates select="heading">
					<xsl:with-param name="context" select="('TitleBlock', $child-context)" tunnel="yes" />
				</xsl:apply-templates>
			</TitleBlock>
		</xsl:if>
		<xsl:apply-templates select="num/authorialNote[@class='referenceNote']" mode="reference">
			<xsl:with-param name="context" select="$child-context" tunnel="yes" />
		</xsl:apply-templates>
		<ScheduleBody>
			<xsl:apply-templates select="*[not(self::num or self::heading)]">
				<xsl:with-param name="context" select="('ScheduleBody', $child-context)" tunnel="yes" />
			</xsl:apply-templates>
		</ScheduleBody>
	</Schedule>
</xsl:template>

<xsl:template match="hcontainer[@name='schedule']/num/authorialNote[@class='referenceNote']" />

<xsl:template match="authorialNote" mode="reference">
	<xsl:param name="context" as="xs:string*" tunnel="yes" />
	<Reference>
		<xsl:apply-templates mode="reference">
			<xsl:with-param name="context" select="('Reference', $context)" tunnel="yes" />
		</xsl:apply-templates>
	</Reference>
</xsl:template>

<xsl:template match="p" mode="reference">
	<xsl:apply-templates />
</xsl:template>


<!-- numbers and headings -->

<xsl:template match="num">
	<xsl:param name="context" as="xs:string*" tunnel="yes" />
	<xsl:variable name="name" as="xs:string">
		<xsl:choose>
			<xsl:when test="head($context) = ('Part', 'Chapter')">
				<xsl:text>Number</xsl:text>
			</xsl:when>
			<xsl:when test="head($context) = ('P1', 'P2', 'P3', 'P4', 'P5', 'P6', 'P7')">
				<xsl:text>Pnumber</xsl:text>
			</xsl:when>
			<xsl:when test="head($context) = ('Schedule')">
				<xsl:text>Number</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:message terminate="yes">
					<xsl:sequence select=".." />
				</xsl:message>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	<xsl:element name="{ $name }">
		<xsl:apply-templates>
			<xsl:with-param name="context" select="($name, $context)" tunnel="yes" />
		</xsl:apply-templates>
	</xsl:element>
</xsl:template>

<xsl:template match="heading">
	<Title>
		<xsl:apply-templates />
	</Title>
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

<xsl:template match="def">
	<Definition>
		<xsl:apply-templates />
	</Definition>
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

<xsl:key name="footnote" match="note[@class='footnote']" use="@eId" />

<xsl:template match="noteRef[@class='footnote']">
	<FootnoteRef Ref="{ substring(@href, 2) }" />
</xsl:template>

<xsl:template name="footnotes">
	<xsl:variable name="footnotes" as="element()*" select="/akomaNtoso/*/meta/notes/note[@class='footnote']" />
	<xsl:if test="exists($footnotes)">
		<Footnotes>
			<xsl:apply-templates select="$footnotes" />
		</Footnotes>
	</xsl:if>
</xsl:template>

<xsl:template match="note[@class='footnote']">
	<Footnote id="{ @eId }">
		<FootnoteText>
			<xsl:apply-templates>
				<xsl:with-param name="context" select="('FootnoteText', 'Footnote')" tunnel="yes" />
			</xsl:apply-templates>
		</FootnoteText>
	</Footnote>
</xsl:template>

</xsl:transform>
