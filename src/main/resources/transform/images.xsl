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
		<xsl:if test="exists(@width) or exists(@ukl:Width)">
			<xsl:attribute name="Width">
				<xsl:value-of select="if (exists(@ukl:Width)) then @ukl:Width else @width" />
			</xsl:attribute>
		</xsl:if>
		<xsl:if test="exists(@height) or exists(@ukl:Height)">
			<xsl:attribute name="Height">
				<xsl:value-of select="if (exists(@ukl:Height)) then @ukl:Height else @height" />
			</xsl:attribute>
		</xsl:if>
	</Image>
</xsl:template>

</xsl:transform>
