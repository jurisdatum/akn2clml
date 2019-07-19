<?xml version="1.0" encoding="utf-8"?>

<xsl:transform version="3.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xpath-default-namespace="http://docs.oasis-open.org/legaldocml/ns/akn/3.0"
	xmlns="http://www.legislation.gov.uk/namespaces/legislation"
	xmlns:ukl="http://www.legislation.gov.uk/namespaces/legislation"
	xmlns:local="http://www.jurisdatum.com/tna/akn2clml"
	exclude-result-prefixes="xs ukl local">


<xsl:function name="local:parse-lgu-uri" as="element(Q{}components)?">
	<xsl:param name="uri" as="xs:string" />
	<xsl:analyze-string select="$uri" regex="^https?://www.legislation.gov.uk/(id/)?([a-z]{{3,5}})/(\d{{4}})/(\d+)(/.+)?$">
		<xsl:matching-substring>
			<components xmlns="">
				<xsl:attribute name="Class">
					<xsl:value-of select="local:long-type-from-short(regex-group(2))" />
				</xsl:attribute>
				<xsl:attribute name="Year">
					<xsl:value-of select="regex-group(3)" />
				</xsl:attribute>
				<xsl:attribute name="Number">
					<xsl:value-of select="regex-group(4)" />
				</xsl:attribute>
				<xsl:if test="normalize-space(regex-group(5))">
					<xsl:attribute name="Section">
						<xsl:value-of select="translate(substring(regex-group(5), 2), '/', '-')" />
					</xsl:attribute>
				</xsl:if>
			</components>
		</xsl:matching-substring>
	</xsl:analyze-string>
</xsl:function>

<xsl:variable name="citations" as="element()*" select="//ref[not(@class='placeholder')] | //rref" />

<xsl:function name="local:make-citation-id" as="xs:string?">
	<xsl:param name="cite" as="element()" />
	<xsl:variable name="index" as="xs:integer?" select="local:get-first-index-of-node($cite, $citations)" />
	<xsl:if test="exists($index)">
		<xsl:value-of select="concat('c', format-number($index, '00000'))" />
	</xsl:if>
</xsl:function>

<xsl:template match="ref[@class='placeholder']">
	<xsl:variable name="tlc" as="element()" select="key('tlc', substring(@href, 2))" />
	<xsl:value-of select="local:resolve-tlc-show-as($tlc/@showAs)" />
</xsl:template>

<xsl:template match="ref">
	<xsl:param name="context" as="xs:string*" tunnel="yes" />
	<xsl:variable name="components" as="element(Q{}components)?" select="local:parse-lgu-uri(@href)" />
	<Citation>
		<xsl:attribute name="id">
			<xsl:value-of select="local:make-citation-id(.)" />
		</xsl:attribute>
		<xsl:attribute name="Class">
			<xsl:choose>
				<xsl:when test="exists($components)">
					<xsl:value-of select="$components/@Class" />
				</xsl:when>
				<xsl:when test="exists(@ukl:Class)">
					<xsl:value-of select="@ukl:Class" />
				</xsl:when>
			</xsl:choose>
		</xsl:attribute>
		<xsl:attribute name="Year">
			<xsl:choose>
				<xsl:when test="exists($components)">
					<xsl:value-of select="$components/@Year" />
				</xsl:when>
				<xsl:when test="exists(@ukl:Year)">
					<xsl:value-of select="@ukl:Year" />
				</xsl:when>
			</xsl:choose>
		</xsl:attribute>
		<xsl:if test="exists($components) or exists(@ukl:Number)">
			<xsl:attribute name="Number">
				<xsl:choose>
					<xsl:when test="exists($components)">
						<xsl:value-of select="$components/@Number" />
					</xsl:when>
					<xsl:when test="exists(exists(@ukl:Number))">
						<xsl:value-of select="@ukl:Number" />
					</xsl:when>
				</xsl:choose>
			</xsl:attribute>
		</xsl:if>
		<xsl:if test="exists($components/@Section)">
			<xsl:attribute name="SectionRef">
				<xsl:value-of select="$components/@Section" />
			</xsl:attribute>
		</xsl:if>
		<xsl:apply-templates>
			<xsl:with-param name="context" select="('Citation', $context)" tunnel="yes" />
		</xsl:apply-templates>
	</Citation>
</xsl:template>

<xsl:template match="ref[@class='subref']">
	<xsl:param name="context" as="xs:string*" tunnel="yes" />
	<xsl:variable name="components" as="element(Q{}components)?" select="local:parse-lgu-uri(@href)" />
	<CitationSubRef>
		<xsl:attribute name="id">
			<xsl:value-of select="local:make-citation-id(.)" />
		</xsl:attribute>
		<xsl:if test="exists(parent::ref)">
			<xsl:attribute name="CitationRef">
				<xsl:value-of select="local:make-citation-id(..)" />
			</xsl:attribute>
		</xsl:if>
		<xsl:if test="exists($components/@Section)">
			<xsl:attribute name="SectionRef">
				<xsl:value-of select="$components/@Section" />
			</xsl:attribute>
		</xsl:if>
		<xsl:apply-templates>
			<xsl:with-param name="context" select="('CitationSubRef', $context)" tunnel="yes" />
		</xsl:apply-templates>
	</CitationSubRef>
</xsl:template>

<xsl:template match="rref">
	<xsl:param name="context" as="xs:string*" tunnel="yes" />
	<xsl:variable name="components" as="element(Q{}components)?" select="local:parse-lgu-uri(@from)" />
	<xsl:variable name="components2" as="element(Q{}components)?" select="local:parse-lgu-uri(@upTo)" />
	<Citation>
		<xsl:attribute name="id">
			<xsl:value-of select="local:make-citation-id(.)" />
		</xsl:attribute>
		<xsl:attribute name="Class">
			<xsl:value-of select="$components/@Class" />
		</xsl:attribute>
		<xsl:attribute name="Year">
			<xsl:value-of select="$components/@Year" />
		</xsl:attribute>
		<xsl:attribute name="Number">
			<xsl:value-of select="$components/Number" />
		</xsl:attribute>
		<xsl:attribute name="StartSectionRef">
			<xsl:value-of select="$components/@Section" />
		</xsl:attribute>
		<xsl:attribute name="EndSectionRef">
			<xsl:value-of select="$components2/@Section" />
		</xsl:attribute>
		<xsl:apply-templates>
			<xsl:with-param name="context" select="('Citation', $context)" tunnel="yes" />
		</xsl:apply-templates>
	</Citation>
</xsl:template>

<xsl:template match="rref[@class='subref']">
	<xsl:param name="context" as="xs:string*" tunnel="yes" />
	<xsl:variable name="components" as="element(Q{}components)?" select="local:parse-lgu-uri(@from)" />
	<xsl:variable name="components2" as="element(Q{}components)?" select="local:parse-lgu-uri(@upTo)" />
	<CitationSubRef>
		<xsl:attribute name="id">
			<xsl:value-of select="local:make-citation-id(.)" />
		</xsl:attribute>
		<xsl:if test="exists(parent::ref)">
			<xsl:attribute name="CitationRef">
				<xsl:value-of select="local:make-citation-id(..)" />
			</xsl:attribute>
		</xsl:if>
		<xsl:attribute name="StartSectionRef">
			<xsl:value-of select="$components/@Section" />
		</xsl:attribute>
		<xsl:attribute name="EndSectionRef">
			<xsl:value-of select="$components2/@Section" />
		</xsl:attribute>
		<xsl:apply-templates>
			<xsl:with-param name="context" select="('Citation', $context)" tunnel="yes" />
		</xsl:apply-templates>
	</CitationSubRef>
</xsl:template>

</xsl:transform>
