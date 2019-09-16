<?xml version="1.0" encoding="utf-8"?>

<xsl:transform version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xpath-default-namespace="http://docs.oasis-open.org/legaldocml/ns/akn/3.0"
	xmlns="http://www.legislation.gov.uk/namespaces/legislation"
	xmlns:local="http://www.jurisdatum.com/tna/akn2clml"
	exclude-result-prefixes="xs local">


<xsl:template match="noteRef[@class='footnote']">
	<FootnoteRef Ref="{ substring(@href, 2) }" />
</xsl:template>

<xsl:template name="footnotes">
	<xsl:variable name="footnotes" as="element()*" select="/akomaNtoso/*/meta/notes/note[tokenize(@class,' ')='footnote'][not(tokenize(@class,' ')='table')]" />
	<xsl:if test="exists($footnotes)">
		<Footnotes>
			<xsl:apply-templates select="$footnotes" />
		</Footnotes>
	</xsl:if>
</xsl:template>

<xsl:template match="note[tokenize(@class,' ')='footnote']">
	<Footnote id="{ @eId }">
		<xsl:apply-templates select="num">
			<xsl:with-param name="context" select="('Footnote')" tunnel="yes" />
		</xsl:apply-templates>
		<FootnoteText>
			<xsl:apply-templates select="* except num">
				<xsl:with-param name="context" select="('FootnoteText', 'Footnote')" tunnel="yes" />
			</xsl:apply-templates>
		</FootnoteText>
	</Footnote>
</xsl:template>

</xsl:transform>
