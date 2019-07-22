<?xml version="1.0" encoding="utf-8"?>

<xsl:transform version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xpath-default-namespace="http://docs.oasis-open.org/legaldocml/ns/akn/3.0"
	xmlns="http://www.legislation.gov.uk/namespaces/legislation"
	xmlns:local="http://www.jurisdatum.com/tna/akn2clml"
	exclude-result-prefixes="xs local">


<xsl:template match="ins">
	<Addition ChangeId="{ tokenize(@class, ' ')[1] }">
		<xsl:apply-templates />
	</Addition>
</xsl:template>

<xsl:template match="ins[starts-with(@class, 'substitution')]">
	<Substitution ChangeId="{ tokenize(@class, ' ')[2] }">
		<xsl:apply-templates />
	</Substitution>
</xsl:template>

<xsl:template match="del">
	<Repeal ChangeId="{ tokenize(@class, ' ')[1] }">
		<xsl:apply-templates />
	</Repeal>
</xsl:template>

<xsl:template match="noteRef[starts-with(@class, 'commentary')]">
	<CommentaryRef Ref="{ substring(@href, 2) }">
		<xsl:apply-templates />
	</CommentaryRef>
</xsl:template>

<xsl:template name="commentaries">
	<xsl:variable name="commentaries" as="element()*" select="/akomaNtoso/*/meta/notes/note[starts-with(@class, 'commentary')]" />
	<xsl:if test="exists($commentaries)">
		<Commentaries>
			<xsl:apply-templates select="$commentaries" />
		</Commentaries>
	</xsl:if> 
</xsl:template>

<xsl:template match="note[starts-with(@class, 'commentary')]">
	<Commentary id="{ @eId }" Type="{ tokenize(@class, ' ')[2] }">
		<xsl:apply-templates>
			<xsl:with-param name="context" select="('Commentary')" tunnel="yes" />
		</xsl:apply-templates>
	</Commentary>
</xsl:template>

</xsl:transform>
