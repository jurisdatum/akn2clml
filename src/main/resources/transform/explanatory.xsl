<?xml version="1.0" encoding="utf-8"?>

<xsl:transform version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xpath-default-namespace="http://docs.oasis-open.org/legaldocml/ns/akn/3.0"
	xmlns="http://www.legislation.gov.uk/namespaces/legislation"
	xmlns:local="http://www.jurisdatum.com/tna/akn2clml"
	exclude-result-prefixes="xs local">


<xsl:template match="conclusions">
	<xsl:apply-templates />
</xsl:template>

<xsl:template match="blockContainer[tokenize(@class, ' ')=('explanatoryNote','explanatoryNotes')]">
	<xsl:param name="context" as="xs:string*" tunnel="yes" />
	<ExplanatoryNotes>
		<xsl:apply-templates>
			<xsl:with-param name="context" select="('ExplanatoryNotes', $context)" tunnel="yes" />
		</xsl:apply-templates>
	</ExplanatoryNotes>
</xsl:template>

<xsl:template match="blockContainer[tokenize(@class, ' ')=('explanatoryNote','explanatoryNotes')]/subheading" name="en-comment">
	<Comment>
		<Para>
			<Text>
				<xsl:apply-templates />
			</Text>
		</Para>
	</Comment>
</xsl:template>

<xsl:template match="blockContainer[tokenize(@class, ' ')=('explanatoryNote','explanatoryNotes','earlierOrders','commencementHistory')]//tblock | blockContainer[tokenize(@class, ' ')=('explanatoryNote','explanatoryNotes','earlierOrders','commencementHistory')]//blockContainer" priority="1">
	<xsl:param name="context" as="xs:string*" tunnel="yes" />
	<xsl:variable name="class" as="xs:string" select="normalize-space(@class)" />
	<xsl:variable name="classes" as="xs:string*" select="tokenize($class, ' ')" />
	<xsl:choose>
		<xsl:when test="$class = '' or $classes = ('para1','para2','para3','para4','group1')">
			<xsl:variable name="name" as="xs:string">
				<xsl:choose>
					<xsl:when test="$classes = 'para1'">
						<xsl:sequence select="'P3'" />
					</xsl:when>
					<xsl:when test="$classes = 'para2'">
						<xsl:sequence select="'P4'" />
					</xsl:when>
					<xsl:when test="$classes = 'para3'">
						<xsl:sequence select="'P5'" />
					</xsl:when>
					<xsl:when test="$classes = 'para4'">
						<xsl:sequence select="'P6'" />
					</xsl:when>
					<xsl:when test="$classes = 'group1'">
						<xsl:sequence select="'P1group'" />
					</xsl:when>
					<xsl:otherwise>
						<xsl:sequence select="'P'" />
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			<xsl:element name="{ $name }">
				<xsl:apply-templates>
					<xsl:with-param name="context" select="($name, $context)" tunnel="yes" />
				</xsl:apply-templates>
			</xsl:element>
		</xsl:when>
		<xsl:otherwise>
			<xsl:next-match />
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>


<xsl:template match="blockList[@class='definition']">
	<xsl:variable name="decor" as="xs:string" select="local:get-decoration-from-list(., false())" />
	<UnorderedList Decoration="{ $decor }" Class="Definition">
		<xsl:apply-templates>
			<xsl:with-param name="decor" select="$decor" />
		</xsl:apply-templates>
	</UnorderedList>
</xsl:template>


<!-- earlier orders -->

<xsl:template match="blockContainer[tokenize(@class, ' ')=('earlierOrders','commencementHistory')]">
	<xsl:param name="context" as="xs:string*" tunnel="yes" />
	<EarlierOrders>
		<xsl:apply-templates>
			<xsl:with-param name="context" select="('EarlierOrders', $context)" tunnel="yes" />
		</xsl:apply-templates>
	</EarlierOrders>
</xsl:template>

<xsl:template match="blockContainer[tokenize(@class, ' ')=('earlierOrders','commencementHistory')]/subheading">
	<xsl:call-template name="en-comment" />
</xsl:template>

</xsl:transform>
