<?xml version="1.0" encoding="utf-8"?>

<xsl:transform version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xpath-default-namespace="http://docs.oasis-open.org/legaldocml/ns/akn/3.0"
	xmlns="http://www.legislation.gov.uk/namespaces/legislation"
	xmlns:ukl="http://www.legislation.gov.uk/namespaces/legislation"
	xmlns:html="http://www.w3.org/1999/xhtml"
	xmlns:local="http://www.jurisdatum.com/tna/akn2clml"
	exclude-result-prefixes="xs ukl html local">

<xsl:template match="tblock[@class='tabular']">
	<xsl:param name="context" as="xs:string*" tunnel="yes" />
	<Tabular Orientation="{ @ukl:Orientation }">
		<xsl:variable name="table-text" as="element(p)*" select="if (exists(*[not(self::p)])) then *[not(self::p)]/preceding-sibling::p else *" />
		<xsl:if test="exists($table-text)">
			<TableText>
				<xsl:apply-templates select="$table-text">
					<xsl:with-param name="context" select="('TableText', 'Tabular', $context)" tunnel="yes" />
				</xsl:apply-templates>
			</TableText>
		</xsl:if>
		<xsl:apply-templates select="* except $table-text">
			<xsl:with-param name="context" select="('Tabular', $context)" tunnel="yes" />
		</xsl:apply-templates>
	</Tabular>
</xsl:template>

<xsl:template match="foreign">
	<xsl:apply-templates />
</xsl:template>

<xsl:template match="html:*">
	<xsl:param name="context" as="xs:string*" tunnel="yes" />
	<xsl:copy>
		<xsl:apply-templates select="@*" />
		<xsl:apply-templates>
			<xsl:with-param name="context" select="(local-name(.), $context)" tunnel="yes" />
		</xsl:apply-templates>
	</xsl:copy>
</xsl:template>

<xsl:template match="html:tbody[1]">
	<xsl:param name="context" as="xs:string*" tunnel="yes" />
	<xsl:call-template name="table-footnotes">
		<xsl:with-param name="table" select="ancestor::html:table" />
	</xsl:call-template>
	<xsl:copy>
		<xsl:apply-templates select="@*" />
		<xsl:apply-templates>
			<xsl:with-param name="context" select="(local-name(.), $context)" tunnel="yes" />
		</xsl:apply-templates>
	</xsl:copy>
</xsl:template>

<xsl:template name="table-footnotes">
	<xsl:param name="table" as="element(html:table)" />
<!-- 	<xsl:variable name="refs-to-table-footnotes" as="element(noteRef)*">
		<xsl:for-each select="$table/descendant::noteRef[@class='footnote']">
			<xsl:variable name="id" as="xs:string" select="substring(@href, 2)" />
			<xsl:variable name="note" as="element()?" select="key('id', $id)" />
			<xsl:if test="tokenize($note/@class,' ') = 'table'">
				<xsl:sequence select="." />
			</xsl:if>
		</xsl:for-each>
	</xsl:variable> -->
	<xsl:variable name="footnotes-in-table" as="element(note)*">
		<xsl:for-each-group select="$table/descendant::noteRef[@class='footnote']" group-by="@href">
			<xsl:variable name="id" as="xs:string" select="substring(@href, 2)" />
			<xsl:variable name="note" as="element(note)?" select="key('id', $id)" />
			<xsl:if test="tokenize($note/@class,' ') = 'table'">
				<xsl:sequence select="$note" />
			</xsl:if>
		</xsl:for-each-group>
	</xsl:variable>
	<xsl:variable name="colspan" as="xs:integer" select="if (exists($table/html:colgroup)) then count($table/html:colgroup/html:col) else max($table/descendant::html:tr/count(html:td))" />
	<xsl:if test="exists($footnotes-in-table)">
		<tfoot xmlns="http://www.w3.org/1999/xhtml">
			<xsl:for-each select="$footnotes-in-table" >
				<tr>
					<td colspan="{ $colspan }">
						<xsl:apply-templates select="." />
					</td>
				</tr>
			</xsl:for-each>
		</tfoot>
	</xsl:if>
</xsl:template>

<xsl:template match="html:th/@width | html:th/@height | html:td/@width | html:td/@height" priority="1">
	<xsl:attribute name="{ name() }">
		<xsl:choose>
			<xsl:when test="matches(., '^\d+$')">
				<xsl:value-of select="." />
				<xsl:text>px</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="." />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:attribute>
</xsl:template>

<xsl:template match="html:*/@*">
	<xsl:copy-of select="." />
</xsl:template>

</xsl:transform>
