<?xml version="1.0" encoding="utf-8"?>

<xsl:transform version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xpath-default-namespace="http://docs.oasis-open.org/legaldocml/ns/akn/3.0"
	xmlns="http://www.legislation.gov.uk/namespaces/legislation"
	xmlns:html="http://www.w3.org/1999/xhtml"
	xmlns:local="http://www.jurisdatum.com/tna/akn2clml"
	exclude-result-prefixes="xs html local">


<xsl:template match="part">
	<xsl:call-template name="create-element-and-wrap-as-necessary">
		<xsl:with-param name="name" as="xs:string" select="'Part'" />
	</xsl:call-template>
</xsl:template>

<xsl:template match="chapter">
	<xsl:call-template name="create-element-and-wrap-as-necessary">
		<xsl:with-param name="name" as="xs:string" select="'Chapter'" />
	</xsl:call-template>
</xsl:template>

<xsl:template match="hcontainer[@name='crossheading']">
	<xsl:param name="context" as="xs:string*" tunnel="yes" />
	<xsl:variable name="name" as="xs:string">
		<xsl:choose>
			<xsl:when test="local:is-within-schedule($context) and exists(child::paragraph) and (exists(preceding-sibling::paragraph) or exists(following-sibling::paragraph))">
				<xsl:text>P1group</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>Pblock</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	<xsl:call-template name="create-element-and-wrap-as-necessary">
		<xsl:with-param name="name" as="xs:string" select="$name" />
	</xsl:call-template>
</xsl:template>

<xsl:template match="hcontainer[@name='subheading']">
	<xsl:call-template name="create-element-and-wrap-as-necessary">
		<xsl:with-param name="name" as="xs:string" select="'PsubBlock'" />
	</xsl:call-template>
</xsl:template>


<!-- numbered paragraphs -->

<xsl:template name="small-level-content">
	<xsl:variable name="content" as="element()*" select="*[not(self::num) and not(self::heading) and not(self::subheading)]" />
	<xsl:variable name="children" as="element()*" select="$content[not(self::intro) and not(self::content) and not(self::wrapUp)]" />
	<xsl:choose>
		<xsl:when test="exists($children) and (every $child in $children satisfies $child/self::hcontainer[@name='definition'])">
			<xsl:apply-templates select="intro" />
			<xsl:call-template name="definition-list">
				<xsl:with-param name="definitions" select="$children" />
			</xsl:call-template>
			<xsl:apply-templates select="wrapUp" />
		</xsl:when>
		<xsl:otherwise>
			<xsl:apply-templates select="$content" />
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template match="section">
	<xsl:param name="context" as="xs:string*" tunnel="yes" />
	<xsl:choose>
		<xsl:when test="exists(heading)">
			<P1group>
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
		<xsl:otherwise>
			<P1>
				<xsl:apply-templates select="num">
					<xsl:with-param name="context" select="('P1', $context)" tunnel="yes" />
				</xsl:apply-templates>
				<xsl:call-template name="small-level-content">
					<xsl:with-param name="context" select="('P1', $context)" tunnel="yes" />
				</xsl:call-template>
			</P1>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template match="subsection">
	<xsl:param name="context" as="xs:string*" tunnel="yes" />
	<xsl:variable name="clml" as="element()">
		<xsl:choose>
			<xsl:when test="exists(heading)">
				<P2group>
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

<xsl:function name="local:is-within-schedule" as="xs:boolean">
	<xsl:param name="context" as="xs:string*" />
	<xsl:variable name="head" as="xs:string" select="$context[1]" />
	<xsl:choose>
		<xsl:when test="empty($context)">
			<xsl:message terminate="yes" />
		</xsl:when>
		<xsl:when test="$head = 'Schedule'">
			<xsl:sequence select="true()" />
		</xsl:when>
		<xsl:when test="$head = ('Body', 'BlockAmendment', 'td')">
			<xsl:sequence select="false()" />
		</xsl:when>
		<xsl:otherwise>
			<xsl:sequence select="local:is-within-schedule(subsequence($context, 2))" />
		</xsl:otherwise>
	</xsl:choose>
</xsl:function>

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

<xsl:function name="local:get-structure-name" as="xs:string?">
	<xsl:param name="hcontainer" as="element()" />
	<xsl:param name="context" as="xs:string*" />
	<xsl:choose>
		<xsl:when test="$hcontainer/self::paragraph">
			<xsl:choose>
				<xsl:when test="local:is-within-schedule($context)">
					<xsl:choose>
						<xsl:when test="$context[1] = ('ScheduleBody', 'Part', 'Chapter', 'Pblock', 'PsubBlock', 'P1group')">
							<xsl:text>P1</xsl:text>
						</xsl:when>
						<xsl:when test="$hcontainer/parent::hcontainer[@name='step']">
							<xsl:value-of select="local:one-more-than-context($context)" />
						</xsl:when>
						<xsl:otherwise>
							<xsl:text>P3</xsl:text>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<xsl:when test="$hcontainer/parent::quotedStructure">
					<xsl:choose>
						<xsl:when test="local:get-target-class($hcontainer/parent::*) = ('primary', 'unknown')">
							<xsl:text>P3</xsl:text>
						</xsl:when>
						<xsl:otherwise>
							<xsl:message>
								<xsl:sequence select="$hcontainer/parent::quotedStructure" />
							</xsl:message>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<xsl:when test="$hcontainer/parent::html:td">
					<xsl:text>P3</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:choose>
						<xsl:when test="$doc-category = 'primary'">
							<xsl:choose>
								<xsl:when test="$hcontainer/parent::section or $hcontainer/parent::subsection">
									<xsl:text>P3</xsl:text>
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="local:one-more-than-context($context)" />
								</xsl:otherwise>
							</xsl:choose>
						</xsl:when>
					</xsl:choose>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:when>
		<xsl:when test="$hcontainer/self::subparagraph">
			<xsl:choose>
				<xsl:when test="$hcontainer/parent::quotedStructure">
					<xsl:choose>
						<xsl:when test="local:get-target-class($hcontainer/parent::*) = ('primary', 'unknown')">
							<xsl:text>P4</xsl:text>
						</xsl:when>
					</xsl:choose>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="local:one-more-than-context($context)" />
				</xsl:otherwise>
			</xsl:choose>
		</xsl:when>
		<xsl:when test="$hcontainer/self::clause">
			<xsl:choose>
				<xsl:when test="$hcontainer/parent::quotedStructure">
					<xsl:choose>
						<xsl:when test="local:get-target-class($hcontainer/parent::*) = ('primary', 'unknown')">
							<xsl:text>P5</xsl:text>
						</xsl:when>
					</xsl:choose>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="local:one-more-than-context($context)" />
				</xsl:otherwise>
			</xsl:choose>
		</xsl:when>
		<xsl:when test="$hcontainer/self::hcontainer/@name='subsubparagraph'">
			<xsl:value-of select="local:one-more-than-context($context)" />
		</xsl:when>
		<xsl:when test="$hcontainer/self::hcontainer/@name='step'">
			<xsl:value-of select="local:one-more-than-context($context)" />
		</xsl:when>
		<xsl:otherwise>
			<xsl:value-of select="local:one-more-than-context($context)" />
		</xsl:otherwise>
	</xsl:choose>
</xsl:function>

<xsl:template match="paragraph | subparagraph | clause | hcontainer[@name=('subsubparagraph','step')]">
	<xsl:param name="context" as="xs:string*" tunnel="yes" />
	<xsl:variable name="name" as="xs:string" select="local:get-structure-name(., $context)" />
	<xsl:variable name="name2" as="xs:string" select="if (exists(num)) then $name else 'P'" />
	<xsl:call-template name="wrap-as-necessary">
		<xsl:with-param name="clml" as="element()">
			<xsl:choose>
				<xsl:when test="exists(heading)">
					<xsl:element name="{ concat($name, 'group') }">
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


<!-- schedules -->

<xsl:template match="hcontainer[@name='schedules']">
	<xsl:param name="context" as="xs:string*" tunnel="yes" />
	<Schedules>
		<xsl:apply-templates>
			<xsl:with-param name="context" select="('Schedules', $context)" tunnel="yes" />
		</xsl:apply-templates>
	</Schedules>
</xsl:template>

<xsl:template match="hcontainer[@name='schedule']">
	<xsl:param name="context" as="xs:string*" tunnel="yes" />
	<xsl:variable name="child-context" as="xs:string*" select="('Schedule', $context)" />
	<Schedule>
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
			<xsl:apply-templates select="*[not(self::num or self::heading)]">
				<xsl:with-param name="context" select="('ScheduleBody', $child-context)" tunnel="yes" />
			</xsl:apply-templates>
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


<!-- numbers and headings -->

<xsl:template match="num">
	<xsl:param name="context" as="xs:string*" tunnel="yes" />
	<xsl:variable name="head" as="xs:string" select="$context[1]" />
	<xsl:variable name="name" as="xs:string">
		<xsl:choose>
			<xsl:when test="$head = ('Part', 'Chapter')">
				<xsl:text>Number</xsl:text>
			</xsl:when>
			<xsl:when test="$head = ('P1', 'P2', 'P3', 'P4', 'P5', 'P6', 'P7')">
				<xsl:text>Pnumber</xsl:text>
			</xsl:when>
			<xsl:when test="$head = 'Schedule'">
				<xsl:text>Number</xsl:text>
			</xsl:when>
			<xsl:when test="$head = ('Tabular')">
				<xsl:text>Number</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:message terminate="yes">
					<xsl:sequence select=".." />
				</xsl:message>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	<xsl:element name="{ $name }">
		<xsl:apply-templates>
			<xsl:with-param name="context" select="($name, $context)" tunnel="yes" />
		</xsl:apply-templates>
	</xsl:element>
</xsl:template>

<xsl:template match="heading">
	<Title>
		<xsl:apply-templates />
	</Title>
</xsl:template>

</xsl:transform>
