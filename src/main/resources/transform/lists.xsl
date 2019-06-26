<?xml version="1.0" encoding="utf-8"?>

<xsl:transform version="3.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xpath-default-namespace="http://docs.oasis-open.org/legaldocml/ns/akn/3.0"
	xmlns="http://www.legislation.gov.uk/namespaces/legislation"
	xmlns:local="http://www.jurisdatum.com/tna/akn2clml"
	exclude-result-prefixes="xs local">


<xsl:function name="local:is-ordered" as="xs:boolean">
	<xsl:param name="list" as="element(blockList)" />
	<xsl:sequence select="every $item in $list/* satisfies $item/num" />
</xsl:function>

<xsl:function name="local:get-decoration" as="xs:string">
	<xsl:param name="list" as="element(blockList)" />
	<xsl:param name="ordered" as="xs:boolean" />
	<xsl:choose>
		<xsl:when test="$ordered">
			<xsl:choose>
				<xsl:when test="every $num in $list/item/num satisfies (starts-with($num, '(') and ends-with($num, ')'))">
					<xsl:text>parens</xsl:text>
				</xsl:when>
				<xsl:when test="every $num in $list/item/num satisfies ends-with($num, ')')">
					<xsl:text>parenRight</xsl:text>
				</xsl:when>
				<xsl:when test="every $num in $list/item/num satisfies (starts-with($num, '[') and ends-with($num, ']'))">
					<xsl:text>brackets</xsl:text>
				</xsl:when>
				<xsl:when test="every $num in $list/item/num satisfies ends-with($num, ']')">
					<xsl:text>bracketRight</xsl:text>
				</xsl:when>
				<xsl:when test="every $num in $list/item/num satisfies ends-with($num, '.')">
					<xsl:text>period</xsl:text>
				</xsl:when>
				<xsl:when test="every $num in $list/item/num satisfies ends-with($num, ':')">
					<xsl:text>colon</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>none</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:when>
		<xsl:otherwise>
			<xsl:text>none</xsl:text>
		</xsl:otherwise>
	</xsl:choose>
</xsl:function>

<xsl:function name="local:get-type-of-ordered-list" as="xs:string">
	<xsl:param name="list" as="element(blockList)" />
	<xsl:param name="decor" as="xs:string" />
	<xsl:choose>
		<xsl:when test="$decor = 'parens'">
			<xsl:choose>
				<xsl:when test="every $num in $list/item/num satisfies matches($num, '^\(\d+\)$')">
					<xsl:text>arabic</xsl:text>
				</xsl:when>
				<xsl:when test="every $num in $list/item/num satisfies matches($num, '^\([ivx]+\)$')">
					<xsl:text>roman</xsl:text>
				</xsl:when>
				<xsl:when test="every $num in $list/item/num satisfies matches($num, '^\([IVX]+\)$')">
					<xsl:text>romanUpper</xsl:text>
				</xsl:when>
				<xsl:when test="every $num in $list/item/num satisfies matches($num, '^\([a-z]+\)$')">
					<xsl:text>alpha</xsl:text>
				</xsl:when>
				<xsl:when test="every $num in $list/item/num satisfies matches($num, '^\([A-Z]+\)$')">
					<xsl:text>alphaUpper</xsl:text>
				</xsl:when>
			</xsl:choose>
		</xsl:when>
<!-- 		<xsl:when test="$decor = 'parenRight'">
		</xsl:when>
		<xsl:when test="$decor = 'brackets'">
		</xsl:when>
		<xsl:when test="$decor = 'bracketRight'">
		</xsl:when>
		<xsl:when test="$decor = 'period'">
		</xsl:when>
		<xsl:when test="$decor = 'colon'">
		</xsl:when> -->
		<xsl:when test="$decor = 'none'">
			<xsl:choose>
				<xsl:when test="every $num in $list/item/num satisfies matches($num, '^\d+$')">
					<xsl:text>arabic</xsl:text>
				</xsl:when>
				<xsl:when test="every $num in $list/item/num satisfies matches($num, '^[ivx]+$')">
					<xsl:text>roman</xsl:text>
				</xsl:when>
				<xsl:when test="every $num in $list/item/num satisfies matches($num, '^[IVX]+$')">
					<xsl:text>romanUpper</xsl:text>
				</xsl:when>
				<xsl:when test="every $num in $list/item/num satisfies matches($num, '^[a-z]+$')">
					<xsl:text>alpha</xsl:text>
				</xsl:when>
				<xsl:when test="every $num in $list/item/num satisfies matches($num, '^[A-Z]+$')">
					<xsl:text>alphaUpper</xsl:text>
				</xsl:when>
			</xsl:choose>
		</xsl:when>
	</xsl:choose>
</xsl:function>

<xsl:template match="blockList">
	<xsl:param name="context" as="xs:string*" tunnel="yes" />
	<xsl:variable name="ordered" as="xs:boolean" select="local:is-ordered(.)" />
	<xsl:variable name="name" as="xs:string" select="if ($ordered) then 'OrderedList' else 'UnorderedList'" />
	<xsl:variable name="decor" as="xs:string" select="local:get-decoration(., $ordered)" />
	<xsl:element name="{ $name }">
		<xsl:if test="$ordered">
			<xsl:attribute name="Type">
				<xsl:value-of select="local:get-type-of-ordered-list(., $decor)" />
			</xsl:attribute>
		</xsl:if>
		<xsl:attribute name="Decoration">
			<xsl:value-of select="$decor" />
		</xsl:attribute>
		<xsl:apply-templates>
			<xsl:with-param name="decor" select="$decor" />
			<xsl:with-param name="context" select="($name, $context)" tunnel="yes" />
		</xsl:apply-templates>
	</xsl:element>
</xsl:template>

<xsl:template match="item">
	<xsl:param name="decor" as="xs:string" />
	<xsl:param name="context" as="xs:string*" tunnel="yes" />
	<ListItem>
		<xsl:if test="exists(num)">
			<xsl:attribute name="NumberOverride">
				<xsl:value-of select="local:strip-punctuation-for-number-override(num, $decor)" />
			</xsl:attribute>
		</xsl:if>
		<xsl:apply-templates select="*[not(self::num)]">
			<xsl:with-param name="context" select="('ListItem', $context)" tunnel="yes" />
		</xsl:apply-templates>
	</ListItem>
</xsl:template>


<!-- definition lists -->

<xsl:template name="definition-list">
	<xsl:param name="definitions" as="element(hcontainer)+" />
	<xsl:param name="context" as="xs:string*" tunnel="yes" />
	<xsl:param name="decoration" as="xs:string" select="'none'" />
	<xsl:call-template name="wrap-as-necessary">
		<xsl:with-param name="clml" as="element()+">
			<UnorderedList Class="Definition" Decoration="{ $decoration }">
				<xsl:apply-templates select="$definitions">
					<xsl:with-param name="context" select="('UnorderedList', $context)" tunnel="yes" />
				</xsl:apply-templates>
			</UnorderedList>
		</xsl:with-param>
	</xsl:call-template>
</xsl:template>

<xsl:template match="hcontainer[@name='definition']">
	<xsl:param name="context" as="xs:string*" tunnel="yes" />
	<ListItem>
		<xsl:apply-templates>
			<xsl:with-param name="context" select="('ListItem', $context)" tunnel="yes" />
		</xsl:apply-templates>
	</ListItem>
</xsl:template>


</xsl:transform>