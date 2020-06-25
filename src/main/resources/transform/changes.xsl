<?xml version="1.0" encoding="utf-8"?>

<xsl:transform version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xpath-default-namespace="http://docs.oasis-open.org/legaldocml/ns/akn/3.0"
	xmlns="http://www.legislation.gov.uk/namespaces/legislation"
	xmlns:uk="https://www.legislation.gov.uk/namespaces/UK-AKN"
	xmlns:ukl="http://www.legislation.gov.uk/namespaces/legislation"
	xmlns:local="http://www.jurisdatum.com/tna/akn2clml"
	exclude-result-prefixes="xs uk ukl local">


<xsl:template match="ins">
	<Addition>
		<xsl:attribute name="ChangeId">
			<xsl:value-of select="if (exists(@ukl:ChangeId)) then @ukl:ChangeId else generate-id(.)" />
		</xsl:attribute>
		<xsl:apply-templates select="@ukl:CommentaryRef" />
		<xsl:apply-templates />
	</Addition>
</xsl:template>

<xsl:template match="ins[starts-with(@class, 'substitution')]">
	<Substitution>
		<xsl:attribute name="ChangeId">
			<xsl:value-of select="if (exists(@ukl:ChangeId)) then @ukl:ChangeId else generate-id(.)" />
		</xsl:attribute>
		<xsl:apply-templates select="@ukl:CommentaryRef" />
		<xsl:apply-templates />
	</Substitution>
</xsl:template>

<xsl:template match="del">
	<Repeal>
		<xsl:attribute name="ChangeId">
			<xsl:value-of select="if (exists(@ukl:ChangeId)) then @ukl:ChangeId else generate-id(.)" />
		</xsl:attribute>
		<xsl:apply-templates select="@ukl:CommentaryRef" />
		<xsl:apply-templates />
	</Repeal>
</xsl:template>

<xsl:template match="@ukl:CommentaryRef">
	<xsl:attribute name="CommentaryRef">
		<xsl:value-of select="." />
	</xsl:attribute>
</xsl:template>

<xsl:template match="noteRef[starts-with(@class, 'commentary')]">
	<xsl:variable name="ref" as="xs:string" select="substring(@href, 2)" />
	<!-- this is necessary because I add noteRefs for f-notes even though there is no CommentaryRef in the source CLML -->
	<!-- it works only because I include @ukl:CommentaryRef attributes on <ins> and <del> elements -->
	<xsl:if test="not(parent::*/@ukl:CommentaryRef = $ref)">
		<CommentaryRef Ref="{ $ref }">
			<xsl:apply-templates />
		</CommentaryRef>
	</xsl:if>
</xsl:template>

<xsl:template name="commentaries">
	<xsl:variable name="commentaries" as="element()*" select="/akomaNtoso/*/meta/notes/note[@ukl:Name='Commentary' or starts-with(@class,'commentary')]" />
	<xsl:if test="exists($commentaries)">
		<Commentaries>
			<xsl:apply-templates select="$commentaries" />
		</Commentaries>
	</xsl:if> 
</xsl:template>

<xsl:template match="note[@ukl:Name='Commentary' or starts-with(@class,'commentary')]">
	<Commentary id="{ @eId }" Type="{ if (exists(@ukl:Type)) then @ukl:Type else tokenize(@class, ' ')[2] }">
		<xsl:apply-templates>
			<xsl:with-param name="context" select="('Commentary')" tunnel="yes" />
		</xsl:apply-templates>
	</Commentary>
</xsl:template>

<xsl:key name="commentary-references" match="otherAnalysis/uk:commentary" use="substring(@href, 2)" />

<xsl:template name="add-commentary-refs-to-number">
	<xsl:variable name="id" as="xs:string?" select="parent::*/@eId" />
	<xsl:variable name="links" as="element(uk:commentary)*" select="key('commentary-references', $id)" />
	<xsl:variable name="notes" as="element(note)*" select="$links/key('id', substring(@refersTo, 2))" />
	<xsl:variable name="notes-without-reference-markers" as="element(note)*" select="$notes[not(@ukl:Type=('F','M','X'))]" />
	<xsl:apply-templates select="$notes-without-reference-markers" mode="commentary-ref" />
</xsl:template>

<xsl:template match="note" mode="commentary-ref">
	<CommentaryRef Ref="{ @eId }" />
</xsl:template>

</xsl:transform>
