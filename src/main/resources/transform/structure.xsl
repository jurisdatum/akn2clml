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

<xsl:variable name="mapping" as="element()">
	<akn xmlns="">
		<primary>
			<section clml="P1" />
			<subsection clml="P2" />
			<paragraph clml="P3" />
			<subparagraph clml="P4" />
			<clause clml="P5" />
			<subclause clml="P6" />
			<subsubparagraph clml="P5" />
		</primary>
		<secondary>
			<article clml="P1" />
			<regulation clml="P1" />
			<rule clml="P1" />
			<SIParagraph clml="P2" />
			<paragraph clml="P3" />
			<subparagraph clml="P4" />
			<subsubparagraph clml="P5" />
			<subsubsubparagraph clml="P6" />
<!-- 			<order>
				<article clml="P1" />
				<paragraph clml="P2" />
				<subparagraph clml="P3" />
				<clause clml="P4" />
				<subclause clml="P5" />
				<point clml="P6" />
			</order>
			<regulation>
				<regulation clml="P1" />
				<paragraph clml="P2" />
				<subparagraph clml="P3" />
				<clause clml="P4" />
				<subclause clml="P5" />
				<point clml="P6" />
			</regulation>
			<rule>
				<rule clml="P1" />
				<paragraph clml="P2" />
				<subparagraph clml="P3" />
				<clause clml="P4" />
				<subclause clml="P5" />
				<point clml="P6" />
			</rule> -->
		</secondary>
		<schedule>
			<scheduleParagraph clml="P1" />
			<scheduleSubparagraph clml="P2" />
			<paragraph clml="P3" />
			<subparagraph clml="P4" />
<!-- 			<clause clml="P5" />
			<subclause clml="P6" /> -->
			<subsubparagraph clml="P5" />
			<subsubsubparagraph clml="P6" />
			<!-- these should come after those with same name and no @class -->
			<paragraph class="schProv1" clml="P1" />
			<subparagraph class="schProv2" clml="P2" />
		</schedule>
		<euretained>
			<article clml="P1" />
			<paragraph clml="P2" />
			<point clml="P3" />
		</euretained>
	</akn>
</xsl:variable>

<xsl:function name="local:get-structure-name" as="xs:string?">
	<xsl:param name="doc-class" as="xs:string" />
	<xsl:param name="doc-subclass" as="xs:string" />
	<xsl:param name="schedule" as="xs:boolean" />
	<xsl:param name="akn-element-name" as="xs:string" />
	<xsl:param name="akn-element-class" as="xs:string?" />
	<xsl:variable name="doc-subclass" as="xs:string" select="if ($doc-subclass = 'unknown') then 'order' else $doc-subclass" />
	<xsl:choose>
		<xsl:when test="$schedule">
			<xsl:choose>
				<xsl:when test="exists($akn-element-class)">
					<xsl:variable name="match" as="element()?" select="$mapping/*:schedule/*[local-name()=$akn-element-name][@class=$akn-element-class]" />
					<xsl:choose>
						<xsl:when test="exists($match)">
							<xsl:sequence select="$match/@clml/string()" />
						</xsl:when>
						<xsl:otherwise>
							<xsl:sequence select="$mapping/*:schedule/*[local-name()=$akn-element-name][1]/@clml/string()" />
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<xsl:otherwise>
					<xsl:sequence select="$mapping/*:schedule/*[local-name()=$akn-element-name][1]/@clml/string()" />
				</xsl:otherwise>
			</xsl:choose>
		</xsl:when>
		<xsl:when test="$doc-class = 'secondary'">
			<xsl:sequence select="$mapping/*:secondary/*[local-name()=$akn-element-name]/@clml/string()" />
		</xsl:when>
		<xsl:when test="$doc-class = 'euretained'">
			<xsl:sequence select="$mapping/*:euretained/*[local-name()=$akn-element-name]/@clml/string()" />
		</xsl:when>
		<xsl:otherwise>
			<xsl:sequence select="$mapping/*:primary/*[local-name()=$akn-element-name]/@clml/string()" />
		</xsl:otherwise>
	</xsl:choose>
</xsl:function>

<xsl:function name="local:akn-is-within-schedule" as="xs:boolean">
	<xsl:param name="akn" as="element()" />
	<xsl:choose>
		<xsl:when test="empty($akn/parent::*)">
			<xsl:value-of select="false()" />
		</xsl:when>
		<xsl:when test="$akn/parent::hcontainer[@name='schedule']">
			<xsl:value-of select="true()" />
		</xsl:when>
		<xsl:when test="$akn/parent::quotedStructure">
			<xsl:value-of select="local:target-is-schedule($akn/parent::*)" />
		</xsl:when>
		<xsl:when test="$akn/parent::html:td">
			<xsl:value-of select="false()" />
		</xsl:when>
		<xsl:otherwise>
			<xsl:sequence select="local:akn-is-within-schedule($akn/parent::*)" />
		</xsl:otherwise>
	</xsl:choose>
</xsl:function>

<xsl:function name="local:get-applicable-doc-class" as="xs:string">
	<xsl:param name="e" as="element()" />
	<xsl:variable name="qs" as="element()?" select="$e/ancestor::quotedStructure[1]" />
	<xsl:choose>
		<xsl:when test="exists($qs)">
			<xsl:sequence select="local:get-target-class($qs)" />
		</xsl:when>
		<xsl:otherwise>
			<xsl:sequence select="$doc-category" />
		</xsl:otherwise>
	</xsl:choose>
</xsl:function>

<xsl:function name="local:get-structure-name" as="xs:string">
	<xsl:param name="akn" as="element()" />
	<xsl:param name="context" as="xs:string*" />
	<xsl:variable name="qs" as="element()?" select="$akn/ancestor::quotedStructure[1]" />
	<xsl:variable name="doc-class" as="xs:string">
		<!-- use local:get-applicable-doc-class -->
		<xsl:choose>
			<xsl:when test="exists($qs)">
				<xsl:value-of select="local:get-target-class($qs)" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$doc-category" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	<xsl:variable name="doc-subclass" as="xs:string?">
		<xsl:choose>
			<xsl:when test="exists($qs)">
				<xsl:value-of select="local:get-target-subclass($qs)" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$doc-subtype" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	<xsl:variable name="within-schedule" as="xs:boolean">
		<xsl:choose>
			<xsl:when test="local:akn-is-within-schedule($akn)">
				<xsl:sequence select="true()" />
			</xsl:when>
			<xsl:when test="exists($qs)">
				<xsl:sequence select="local:target-is-schedule($qs)" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:sequence select="false()" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	<xsl:variable name="akn-element-name" as="xs:string" select="if ($akn/self::hcontainer) then $akn/@name else local-name($akn)" />
	<xsl:variable name="akn-class" as="xs:string?">
		<xsl:choose>
			<xsl:when test="exists($akn/@class)">
				<xsl:value-of select="$akn/@class" />
			</xsl:when>
			<xsl:when test="not(local:akn-is-within-schedule($akn))" />
			<xsl:when test="$akn/self::paragraph and ($akn/parent::paragraph or $akn/parent::subparagraph)">
				<xsl:text>para1</xsl:text>
			</xsl:when>
			<xsl:when test="$akn/self::paragraph and ($akn/parent::hcontainer[@name=('wrapper1','wrapper2')]/parent::paragraph or $akn/parent::hcontainer[@name=('wrapper1','wrapper2')]/parent::subparagraph)">
				<xsl:text>para1</xsl:text>
			</xsl:when>
			<xsl:when test="$akn/self::subparagraph and ($akn/parent::paragraph/parent::paragraph or $akn/parent::paragraph/parent::subparagraph) ">
				<xsl:text>para2</xsl:text>
			</xsl:when>
			<xsl:when test="$akn/self::subparagraph and ($akn/parent::hcontainer[@name=('wrapper1','wrapper2')]/parent::paragraph/parent::paragraph or $akn/parent::hcontainer[@name=('wrapper1','wrapper2')]/parent::paragraph/parent::subparagraph) ">
				<xsl:text>para2</xsl:text>
			</xsl:when>
			<xsl:when test="$akn/self::subparagraph and ($akn/parent::paragraph/parent::hcontainer[@name=('wrapper1','wrapper2')]/parent::paragraph or $akn/parent::paragraph/parent::hcontainer[@name=('wrapper1','wrapper2')]/parent::subparagraph) ">
				<xsl:text>para2</xsl:text>
			</xsl:when>
			<xsl:when test="$akn/self::subparagraph and $akn/parent::subparagraph "> <!-- asp/2013/15 -->
				<xsl:text>para2</xsl:text>
			</xsl:when>
			<xsl:when test="$akn/self::subparagraph and ($akn/parent::hcontainer[@name=('wrapper1','wrapper2')]/parent::subparagraph) "> <!-- asp/2013/15 -->
				<xsl:text>para2</xsl:text>
			</xsl:when>
		</xsl:choose>
	</xsl:variable>
	<xsl:variable name="name" as="xs:string?">
		<xsl:choose>
			<xsl:when test="$akn/self::hcontainer[@name='subsubparagraph']">
				<xsl:sequence select="local:one-more-than-context($context)" />
			</xsl:when>
			<xsl:when test="$akn/ancestor-or-self::hcontainer[@name='step']">
				<xsl:sequence select="local:one-more-than-context($context)" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:sequence select="local:get-structure-name($doc-class, $doc-subclass, $within-schedule, $akn-element-name, $akn-class)" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	<xsl:if test="empty($name)">
		<xsl:message>
			<xsl:sequence select="$akn" />
		</xsl:message>
		<xsl:message>
			<xsl:text>doc-class </xsl:text>
			<xsl:sequence select="$doc-class" />
		</xsl:message>
		<xsl:message>
			<xsl:text>doc-subclass </xsl:text>
			<xsl:sequence select="$doc-subclass" />
		</xsl:message>
		<xsl:message>
			<xsl:text>within-schedule </xsl:text>
			<xsl:sequence select="$within-schedule" />
		</xsl:message>
		<xsl:message>
			<xsl:text>akn-element-name </xsl:text>
			<xsl:sequence select="$akn-element-name" />
		</xsl:message>
		<xsl:message>
			<xsl:text>akn-class </xsl:text>
			<xsl:sequence select="$akn-class" />
		</xsl:message>
		<xsl:message terminate="yes">
		</xsl:message>
	</xsl:if>
	<xsl:sequence select="$name" />
</xsl:function>

<xsl:template name="add-structure-attributes">
	<xsl:call-template name="alt-version-refs" />
	<xsl:call-template name="add-fragment-attributes" />
</xsl:template>

<xsl:template name="big-level">
	<xsl:param name="name" as="xs:string" />
	<xsl:param name="context" as="xs:string*" tunnel="yes" />
	<xsl:element name="{ $name }">
		<xsl:call-template name="add-structure-attributes" />
		<xsl:apply-templates>
			<xsl:with-param name="context" select="($name, $context)" tunnel="yes" />
		</xsl:apply-templates>
	</xsl:element>
</xsl:template>

<xsl:template match="part">
	<xsl:call-template name="big-level">
		<xsl:with-param name="name" select="'Part'" />
	</xsl:call-template>
</xsl:template>

<xsl:template match="chapter">
	<xsl:call-template name="big-level">
		<xsl:with-param name="name" select="'Chapter'" />
	</xsl:call-template>
</xsl:template>

<xsl:template match="section[local:get-applicable-doc-class(.)='secondary']">
	<xsl:call-template name="big-level">
		<xsl:with-param name="name" select="'Pblock'" />
	</xsl:call-template>
</xsl:template>

<xsl:template match="subsection[local:get-applicable-doc-class(.)='secondary']">
	<xsl:call-template name="big-level">
		<xsl:with-param name="name" select="'PsubBlock'" />
	</xsl:call-template>
</xsl:template>

<xsl:template match="hcontainer[@name='crossheading']">
	<xsl:call-template name="big-level">
		<xsl:with-param name="name">
			<xsl:choose>
				<xsl:when test="exists(@ukl:Name)">
					<xsl:value-of select="@ukl:Name" />
				</xsl:when>
				<!-- LDAPP uses crossheadings for certain schedule paragraphs -->
				<xsl:when test="false() and local:akn-is-within-schedule(.) and exists(child::paragraph) and empty(child::paragraph/heading) and (exists(preceding-sibling::paragraph) or exists(following-sibling::paragraph))">
					<xsl:text>P1group</xsl:text>
				</xsl:when>
				<xsl:when test="parent::hcontainer[@name='schedule'] and exists(child::paragraph) and empty(child::paragraph/heading) and empty(preceding-sibling::hcontainer[@name='crossheading']/paragraph/heading) and empty(following-sibling::hcontainer[@name='crossheading']/paragraph/heading) and empty(preceding-sibling::paragraph)">
				<!-- last condition is for asp/2000/5/schedule/5 -->
					<xsl:text>P1group</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>Pblock</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:with-param>
	</xsl:call-template>
</xsl:template>

<xsl:template match="hcontainer[@name='subheading']">
	<xsl:call-template name="big-level">
		<xsl:with-param name="name">
			<xsl:choose>
				<xsl:when test="exists(@ukl:Name)">
					<xsl:value-of select="@ukl:Name" />
				</xsl:when>
				<!-- LDAPP uses crossheadings for certain schedule paragraphs -->
				<xsl:when test="false()">
					<xsl:text>P1group</xsl:text>
				</xsl:when>
				<xsl:when test="parent::hcontainer[@name='crossheading'] and local:akn-is-within-schedule(.) and exists(child::paragraph) and empty(child::paragraph/heading) and empty(preceding-sibling::hcontainer[@name='subheading']/paragraph/heading) and empty(following-sibling::hcontainer[@name='subheading']/paragraph/heading)">
					<xsl:text>P1group</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>PsubBlock</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:with-param>
	</xsl:call-template>
</xsl:template>


<!-- numbered paragraphs -->

<xsl:template name="small-level-content">
	<xsl:param name="context" as="xs:string*" tunnel="yes" />
	<xsl:variable name="content" as="element()*" select="*[not(self::num) and not(self::heading) and not(self::subheading)]" />
	<xsl:variable name="children" as="element()*" select="$content[not(self::intro) and not(self::content) and not(self::wrapUp)]" />
	<xsl:choose>
		<xsl:when test="local:should-merge-intro-and-definitions(.)">
			<xsl:call-template name="merge-intro-and-definitions" />
			<xsl:apply-templates select="wrapUp" />
		</xsl:when>
		<xsl:when test="exists($children) and (every $child in $children satisfies $child/self::hcontainer[@name='definition'])">
			<xsl:apply-templates select="intro" />
			<xsl:call-template name="definition-list">
				<xsl:with-param name="definitions" select="$children" />
			</xsl:call-template>
			<xsl:apply-templates select="wrapUp" />
		</xsl:when>
		<xsl:when test="some $child in $children satisfies $child/self::hcontainer[@name='definition']">
			<xsl:apply-templates select="intro" />
			<xsl:call-template name="group-definitions-for-block-amendment">
				<xsl:with-param name="elements" select="$children" />
			</xsl:call-template>
			<xsl:apply-templates select="wrapUp" />
		</xsl:when>
		<xsl:when test="not($context[1] = 'P') and empty($children[self::hcontainer[@name='wrapper1']])">
			<xsl:variable name="name" as="xs:string" select="concat($context[1], 'para')" />
			<xsl:element name="{ $name }">
				<xsl:apply-templates select="$content">
						<xsl:with-param name="context" select="($name, $context)" tunnel="yes" />
				</xsl:apply-templates>
			</xsl:element>
		</xsl:when>
		<xsl:otherwise>
			<xsl:apply-templates select="$content" />
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template match="section | article | rule | hcontainer[@name='regulation'] | hcontainer[@name='scheduleParagraph'] | hcontainer[@name='direction']">
	<xsl:param name="context" as="xs:string*" tunnel="yes" />
	<xsl:choose>
		<xsl:when test="exists(heading) and exists(num)">
			<P1group>
				<xsl:call-template name="add-structure-attributes" />
				<xsl:apply-templates select="heading | subheading">
					<xsl:with-param name="context" select="('P1group', $context)" tunnel="yes" />
				</xsl:apply-templates>
				<P1>
					<xsl:apply-templates select="num">
						<xsl:with-param name="context" select="('P1', 'P1group', $context)" tunnel="yes" />
					</xsl:apply-templates>
					<xsl:call-template name="small-level-content">
						<xsl:with-param name="context" select="('P1', 'P1group', $context)" tunnel="yes" />
					</xsl:call-template>
				</P1>
			</P1group>
		</xsl:when>
		<xsl:when test="exists(num)">
			<P1>
				<xsl:call-template name="add-structure-attributes" />
				<xsl:apply-templates select="num">
					<xsl:with-param name="context" select="('P1', $context)" tunnel="yes" />
				</xsl:apply-templates>
				<xsl:call-template name="small-level-content">
					<xsl:with-param name="context" select="('P1', $context)" tunnel="yes" />
				</xsl:call-template>
			</P1>
		</xsl:when>
		<xsl:when test="exists(heading)">
			<P1group>
				<xsl:call-template name="add-structure-attributes" />
				<xsl:apply-templates select="heading | subheading">
					<xsl:with-param name="context" select="('P1group', $context)" tunnel="yes" />
				</xsl:apply-templates>
				<P>
					<xsl:call-template name="small-level-content">
						<xsl:with-param name="context" select="('P', 'P1group', $context)" tunnel="yes" />
					</xsl:call-template>
				</P>
			</P1group>
		</xsl:when>
		<xsl:otherwise>
			<P>
				<xsl:call-template name="add-structure-attributes" />
				<xsl:call-template name="small-level-content">
					<xsl:with-param name="context" select="('P', $context)" tunnel="yes" />
				</xsl:call-template>
			</P>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template match="subsection | hcontainer[@name='SIParagraph']">
	<xsl:param name="context" as="xs:string*" tunnel="yes" />
	<xsl:variable name="clml" as="element()">
		<xsl:choose>
			<xsl:when test="exists(heading)">
				<P2group>
					<xsl:call-template name="add-structure-attributes" />
					<xsl:apply-templates select="heading | subheading">
						<xsl:with-param name="context" select="('P2group', $context)" tunnel="yes" />
					</xsl:apply-templates>
					<P2>
						<xsl:apply-templates select="num">
							<xsl:with-param name="context" select="('P2', 'P2group', $context)" tunnel="yes" />
						</xsl:apply-templates>
						<xsl:call-template name="small-level-content">
							<xsl:with-param name="context" select="('P2', P2group, $context)" tunnel="yes" />
						</xsl:call-template>
					</P2>
				</P2group>
			</xsl:when>
			<xsl:otherwise>
				<P2>
					<xsl:call-template name="add-structure-attributes" />
					<xsl:apply-templates select="num">
						<xsl:with-param name="context" select="('P2', $context)" tunnel="yes" />
					</xsl:apply-templates>
					<xsl:call-template name="small-level-content">
						<xsl:with-param name="context" select="('P2', $context)" tunnel="yes" />
					</xsl:call-template>
				</P2>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	<xsl:call-template name="wrap-as-necessary">
		<xsl:with-param name="clml" select="$clml" />
	</xsl:call-template>
</xsl:template>

<xsl:function name="local:one-more-than-context" as="xs:string">
	<xsl:param name="context" as="xs:string*" />
	<xsl:variable name="head" as="xs:string" select="$context[1]" />
	<xsl:choose>
		<xsl:when test="$head = ('Body', 'Part', 'Chapter', 'Pblock', 'PsubBlock', 'ScheduleBody')">
			<xsl:text>P1</xsl:text>
		</xsl:when>
		<xsl:when test="$head = ('P1', 'P1para')">
			<xsl:text>P2</xsl:text>
		</xsl:when>
		<xsl:when test="$head = ('P2', 'P2para')">
			<xsl:text>P3</xsl:text>
		</xsl:when>
		<xsl:when test="$head = ('P3', 'P3para')">
			<xsl:text>P4</xsl:text>
		</xsl:when>
		<xsl:when test="$head = ('P4', 'P4para')">
			<xsl:text>P5</xsl:text>
		</xsl:when>
		<xsl:when test="$head = ('P5', 'P5para')">
			<xsl:text>P6</xsl:text>
		</xsl:when>
		<xsl:when test="$head = ('P6', 'P6para')">
			<xsl:text>P7</xsl:text>
		</xsl:when>
		<xsl:when test="$head = ('P7', 'P7para')">
			<xsl:text>P7</xsl:text>
		</xsl:when>
		<xsl:otherwise>
			<xsl:message terminate="yes">
				<xsl:sequence select="$context" />
			</xsl:message>
		</xsl:otherwise>
	</xsl:choose>
</xsl:function>

<xsl:template match="paragraph | subparagraph | clause | subclause | hcontainer[@name=('subsubparagraph','step')] | point">
	<xsl:param name="context" as="xs:string*" tunnel="yes" />
	<xsl:variable name="name" as="xs:string" select="local:get-structure-name(., $context)" />
	<xsl:if test="$name = ''">
		<xsl:message>
			<xsl:sequence select="." />
		</xsl:message>
	</xsl:if>
	<xsl:variable name="name2" as="xs:string" select="if (exists(num)) then $name else 'P'" />
	<xsl:call-template name="wrap-as-necessary">
		<xsl:with-param name="clml" as="element()">
			<xsl:choose>
				<xsl:when test="exists(heading)">
					<xsl:element name="{ concat($name, 'group') }">
						<xsl:call-template name="add-structure-attributes" />
						<xsl:apply-templates select="heading | subheading">
							<xsl:with-param name="context" select="(concat($name, 'group'), $context)" tunnel="yes" />
						</xsl:apply-templates>
						<xsl:element name="{ $name2 }">
							<xsl:apply-templates select="num">
								<xsl:with-param name="context" select="($name2, $context)" tunnel="yes" />
							</xsl:apply-templates>
							<xsl:call-template name="small-level-content">
								<xsl:with-param name="context" select="($name2, $context)" tunnel="yes" />
							</xsl:call-template>
						</xsl:element>
					</xsl:element>
				</xsl:when>
				<xsl:otherwise>
					<xsl:element name="{ $name2 }">
						<xsl:call-template name="add-structure-attributes" />
						<xsl:apply-templates select="num | heading | subheading">
							<xsl:with-param name="context" select="($name2, $context)" tunnel="yes" />
						</xsl:apply-templates>
						<xsl:call-template name="small-level-content">
							<xsl:with-param name="context" select="($name2, $context)" tunnel="yes" />
						</xsl:call-template>
					</xsl:element>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:with-param>
	</xsl:call-template>
</xsl:template>

<xsl:template match="level">
	<xsl:call-template name="create-element-and-wrap-as-necessary">
		<xsl:with-param name="name" select="'P2group'" />
	</xsl:call-template>
</xsl:template>

<!-- hcontainer[@name='wrapper1'] maps P?paras where more than one sibling contain structural children -->

<xsl:template match="hcontainer[@name='wrapper1']">
	<xsl:param name="context" as="xs:string*" tunnel="yes" />
	<xsl:variable name="name" as="xs:string" select="concat($context[1], 'para')" />
	<xsl:element name="{ $name }">
		<xsl:apply-templates>
				<xsl:with-param name="context" select="($name, $context)" tunnel="yes" />
		</xsl:apply-templates>
	</xsl:element>
</xsl:template>

<!-- hcontainer[@name='wrapper2'] wraps groups of numbered paragraphs that are siblings but separated by content -->

<xsl:template match="hcontainer[@name='wrapper2']">
	<xsl:apply-templates />
</xsl:template>


<!-- schedules -->

<xsl:template match="hcontainer[@name='schedules']">
	<xsl:param name="context" as="xs:string*" tunnel="yes" />
	<Schedules>
		<xsl:call-template name="add-fragment-attributes" />
		<xsl:apply-templates>
			<xsl:with-param name="context" select="('Schedules', $context)" tunnel="yes" />
		</xsl:apply-templates>
	</Schedules>
</xsl:template>

<xsl:template name="schedule-body">
	<xsl:param name="context" as="xs:string*" tunnel="yes" />
	<xsl:variable name="content" as="element()*" select="*[not(self::num or self::heading or self::subheading)]" />
	<xsl:variable name="children" as="element()*" select="$content[not(self::intro) and not(self::content) and not(self::wrapUp)]" />
	<xsl:choose>
		<xsl:when test="exists($children) and (every $child in $children satisfies $child/self::paragraph[@class='para1'])">
			<P>
				<xsl:apply-templates select="$content">
					<xsl:with-param name="context" select="('P', $context)" tunnel="yes" />
				</xsl:apply-templates>
			</P>
		</xsl:when>
		<xsl:when test="exists($children) and (every $child in $children satisfies $child/self::hcontainer[@name='definition'])">
			<P>
				<xsl:apply-templates select="intro">
					<xsl:with-param name="context" select="('P', $context)" tunnel="yes" />
				</xsl:apply-templates>
				<xsl:call-template name="definition-list">
					<xsl:with-param name="definitions" select="$children" />
					<xsl:with-param name="context" select="('P', $context)" tunnel="yes" />
				</xsl:call-template>
				<xsl:apply-templates select="wrapUp">
					<xsl:with-param name="context" select="('P', $context)" tunnel="yes" />
				</xsl:apply-templates>
			</P>
		</xsl:when>
		<xsl:otherwise>
			<xsl:apply-templates select="$content">
				<xsl:with-param name="context" select="($context)" tunnel="yes" />
			</xsl:apply-templates>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template match="hcontainer[@name='schedule']">
	<xsl:param name="context" as="xs:string*" tunnel="yes" />
	<xsl:variable name="child-context" as="xs:string*" select="('Schedule', $context)" />
	<Schedule>
		<xsl:call-template name="add-structure-attributes" />
		<xsl:apply-templates select="num">
			<xsl:with-param name="context" select="$child-context" tunnel="yes" />
		</xsl:apply-templates>
		<xsl:if test="exists(heading)">
			<TitleBlock>
				<xsl:apply-templates select="heading">
					<xsl:with-param name="context" select="('TitleBlock', $child-context)" tunnel="yes" />
				</xsl:apply-templates>
			</TitleBlock>
		</xsl:if>
		<xsl:apply-templates select="num/authorialNote[@class='referenceNote']" mode="reference">
			<xsl:with-param name="context" select="$child-context" tunnel="yes" />
		</xsl:apply-templates>
		<ScheduleBody>
			<xsl:call-template name="schedule-body">
				<xsl:with-param name="context" select="('ScheduleBody', $child-context)" tunnel="yes" />
			</xsl:call-template>
		</ScheduleBody>
	</Schedule>
</xsl:template>

<xsl:template match="hcontainer[@name='schedule']/num/authorialNote[@class='referenceNote']" />

<xsl:template match="authorialNote" mode="reference">
	<xsl:param name="context" as="xs:string*" tunnel="yes" />
	<Reference>
		<xsl:apply-templates mode="reference">
			<xsl:with-param name="context" select="('Reference', $context)" tunnel="yes" />
		</xsl:apply-templates>
	</Reference>
</xsl:template>

<xsl:template match="p" mode="reference">
	<xsl:apply-templates />
</xsl:template>

<xsl:template match="hcontainer[@name='schedule']/part">
	<xsl:param name="context" as="xs:string*" tunnel="yes" />
	<Part>
		<xsl:call-template name="add-structure-attributes" />
		<xsl:apply-templates select="num | heading | subheading">
			<xsl:with-param name="context" select="('Part', $context)" tunnel="yes" />
		</xsl:apply-templates>
		<xsl:apply-templates select="num/authorialNote[@class='referenceNote']" mode="reference">
			<xsl:with-param name="context" select="('Part', $context)" tunnel="yes" />
		</xsl:apply-templates>
		<xsl:call-template name="schedule-body">
			<xsl:with-param name="context" select="('Part', $context)" tunnel="yes" />
		</xsl:call-template>
	</Part>
</xsl:template>

<xsl:template match="hcontainer[@name='schedule']/part/num/authorialNote[@class='referenceNote']" />


<!-- structure in prelims, explanatory notes, earlier orders, etc. -->

<xsl:template match="blockContainer[@class=('P1group', 'P3', 'P4', 'P')]">
	<xsl:param name="context" as="xs:string*" tunnel="yes" />
	<xsl:variable name="name" as="xs:string" select="@class" />
	<xsl:variable name="clml" as="element()">
		<xsl:element name="{ $name }">
			<xsl:apply-templates>
				<xsl:with-param name="context" select="($name, $context)" tunnel="yes" />
			</xsl:apply-templates>
		</xsl:element>
	</xsl:variable>
	<xsl:call-template name="wrap-as-necessary">
		<xsl:with-param name="clml" select="$clml" />
		<xsl:with-param name="context" select="$context" />
	</xsl:call-template>
</xsl:template>

<xsl:template match="blockContainer[@class=('P3', 'P4')]/num">
	<xsl:param name="context" as="xs:string*" tunnel="yes" />
	<Pnumber>
		<xsl:apply-templates>
			<xsl:with-param name="context" select="('Pnumber', $context)" tunnel="yes" />
		</xsl:apply-templates>
	</Pnumber>
</xsl:template>


<!-- numbers and headings -->

<xsl:template match="num">
	<xsl:param name="context" as="xs:string*" tunnel="yes" />
	<xsl:variable name="head" as="xs:string" select="$context[1]" />
	<xsl:variable name="name" as="xs:string">
		<xsl:choose>
			<xsl:when test="$head = ('Part', 'Chapter', 'Pblock', 'PsubBlock')">
				<xsl:text>Number</xsl:text>
			</xsl:when>
			<xsl:when test="$head = ('P1', 'P2', 'P3', 'P4', 'P5', 'P6', 'P7')">
				<xsl:text>Pnumber</xsl:text>
			</xsl:when>
			<xsl:when test="$head = 'Schedule'">
				<xsl:text>Number</xsl:text>
			</xsl:when>
			<xsl:when test="$head = ('Tabular', 'Form', 'Footnote')">
				<xsl:text>Number</xsl:text>
			</xsl:when>
			<xsl:when test="@ukl:Context = ('Part', 'Chapter', 'Pblock')"> <!-- see asp/2000/5 FragmentNumber -->
				<xsl:text>Number</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:message>
					<xsl:text>can't find context for num</xsl:text>
				</xsl:message>
				<xsl:message>
					<xsl:text>context = </xsl:text>
					<xsl:sequence select="$context" />
				</xsl:message>
				<xsl:message terminate="yes">
					<xsl:sequence select=".." />
				</xsl:message>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	<xsl:choose>
		<xsl:when test="exists(@ukl:Context)">
			<FragmentNumber Context="{ @ukl:Context }">
				<xsl:element name="{ $name }">
					<xsl:if test="($name = 'Pnumber') and local:should-add-punc-before-and-punc-after-attributes(., $context)">
						<xsl:call-template name="add-punc-before-and-punc-after-attributes" />
					</xsl:if>
					<xsl:apply-templates>
						<xsl:with-param name="context" select="($name, $context)" tunnel="yes" />
					</xsl:apply-templates>
				</xsl:element>
			</FragmentNumber>
		</xsl:when>
		<xsl:otherwise>
			<xsl:element name="{ $name }">
				<xsl:if test="($name = 'Pnumber') and local:should-add-punc-before-and-punc-after-attributes(., $context)">
					<xsl:call-template name="add-punc-before-and-punc-after-attributes" />
				</xsl:if>
				<xsl:apply-templates>
					<xsl:with-param name="context" select="($name, $context)" tunnel="yes" />
				</xsl:apply-templates>
			</xsl:element>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template match="heading">
	<xsl:choose>
		<xsl:when test="exists(@ukl:Context)">
			<FragmentTitle Context="{ @ukl:Context }">
				<Title>
					<xsl:apply-templates />
				</Title>
			</FragmentTitle>
		</xsl:when>
		<xsl:otherwise>
			<Title>
				<xsl:apply-templates />
			</Title>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template match="subheading">
	<Subtitle>
		<xsl:apply-templates />
	</Subtitle>
</xsl:template>

</xsl:transform>
