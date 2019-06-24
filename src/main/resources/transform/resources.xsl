<?xml version="1.0" encoding="utf-8"?>

<xsl:transform version="3.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xpath-default-namespace="http://docs.oasis-open.org/legaldocml/ns/akn/3.0"
	xmlns="http://www.legislation.gov.uk/namespaces/legislation"
	xmlns:math="http://www.w3.org/1998/Math/MathML"
	xmlns:local="http://www.jurisdatum.com/tna/akn2clml"
	exclude-result-prefixes="xs math local">


<xsl:key name="altimg" match="math:math" use="@altimg" />

<xsl:variable name="resources" as="element()*">
	<xsl:sequence select="//math:math[@altimg]" />
</xsl:variable>

<xsl:function name="local:make-version-id">
	<xsl:param name="e" as="element()" />
	<xsl:variable name="index" as="xs:integer*">
		<xsl:for-each select="$resources">
			<xsl:if test=". is $e">
				<xsl:value-of select="position()" />
			</xsl:if>
		</xsl:for-each> 
	</xsl:variable>
	<xsl:variable name="num" as="xs:integer" select="if (exists($index)) then $index[1] else 0" />
	<xsl:value-of select="concat('v', format-number($num,'00000'))" />
</xsl:function>

<xsl:template name="resources">
	<xsl:if test="exists($resources)">
		<Versions>
			<xsl:apply-templates select="$resources" mode="version" />
		</Versions>
		<Resources>
			<xsl:apply-templates select="$resources" mode="resource" />
		</Resources>
	</xsl:if>
</xsl:template>

<xsl:template match="math:math" mode="version">
	<Version id="v{format-number(position(),'00000')}">
		<Figure>
			<Image ResourceRef="r{format-number(position(),'00000')}" Height="auto" Width="auto" />
		</Figure>
	</Version>
</xsl:template>

<xsl:template match="math:math" mode="resource">
	<Resource id="r{format-number(position(),'00000')}">
		<ExternalVersion URI="{ @altimg }" />
	</Resource>
</xsl:template>

</xsl:transform>
