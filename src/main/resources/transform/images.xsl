<?xml version="1.0" encoding="utf-8"?>

<xsl:transform version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xpath-default-namespace="http://docs.oasis-open.org/legaldocml/ns/akn/3.0"
	xmlns="http://www.legislation.gov.uk/namespaces/legislation"
	xmlns:ukl="http://www.legislation.gov.uk/namespaces/legislation"
	xmlns:local="http://www.jurisdatum.com/tna/akn2clml"
	exclude-result-prefixes="xs ukl local">


<xsl:template match="tblock[starts-with(@class, 'figure')]">
	<xsl:param name="context" as="xs:string*" tunnel="yes" />
	<xsl:call-template name="wrap-as-necessary">
		<xsl:with-param name="clml" as="element()">
			<Figure>
				<xsl:if test="exists(@ukl:Orientation)">
					<xsl:attribute name="Orientation">
						<xsl:value-of select="@ukl:Orientation" />
					</xsl:attribute>
				</xsl:if>
				<xsl:if test="exists(@ukl:ImageLayout)">
					<xsl:attribute name="ImageLayout">
						<xsl:value-of select="@ukl:ImageLayout" />
					</xsl:attribute>
				</xsl:if>
				<xsl:apply-templates>
					<xsl:with-param name="context" select="('Figure', local:get-block-wrapper($context), $context)" tunnel="yes" />
				</xsl:apply-templates>
			</Figure>
		</xsl:with-param>
	</xsl:call-template>
</xsl:template>

<xsl:template match="tblock[starts-with(@class, 'figure')]/p[exists(img) and count(node()) eq 1]">
	<xsl:apply-templates />
</xsl:template>

<xsl:template match="img">
	<xsl:variable name="res-id" as="xs:string" select="local:make-resource-id(.)" />
	<Image ResourceRef="{ $res-id }">
		<xsl:attribute name="Width">
			<xsl:choose>
				<xsl:when test="exists(@ukl:Width)">
					<xsl:value-of select="@ukl:Width" />
				</xsl:when>
				<xsl:when test="exists(@width)">
					<xsl:value-of select="@width" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>auto</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:attribute>
		<xsl:attribute name="Height">
			<xsl:choose>
				<xsl:when test="exists(@ukl:Height)">
					<xsl:value-of select="@ukl:Height" />
				</xsl:when>
				<xsl:when test="exists(@height)">
					<xsl:value-of select="@height" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>auto</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:attribute>
		<xsl:if test="exists(@title)">
			<xsl:attribute name="Description">
				<xsl:value-of select="@title" />
			</xsl:attribute>
		</xsl:if>
	</Image>
</xsl:template>

</xsl:transform>
