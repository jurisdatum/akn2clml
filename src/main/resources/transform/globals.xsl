<?xml version="1.0" encoding="utf-8"?>

<xsl:transform version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xpath-default-namespace="http://docs.oasis-open.org/legaldocml/ns/akn/3.0"
	xmlns:ukm="http://www.legislation.gov.uk/namespaces/metadata"
	xmlns:dc="http://purl.org/dc/elements/1.1/"
	xmlns:local="http://www.jurisdatum.com/tna/akn2clml"
	exclude-result-prefixes="xs ukm dc local">


<!-- keys -->

<xsl:key name="id" match="*" use="@eId" />

<xsl:key name="tlc" match="TLCConcept | TLCProcess" use="@eId" />


<!-- functions -->

<xsl:variable name="long-types" as="element()">
	<longTypes
		ukpga = "UnitedKingdomPublicGeneralAct"
		ukla = "UnitedKingdomLocalAct"
		asp = "ScottishAct"
		anaw = "WelshNationalAssemblyAct"
		mwa = "WelshAssemblyMeasure"
		ukcm = "UnitedKingdomChurchMeasure"
		nia = "NorthernIrelandAct"
		aosp = "ScottishOldAct"
		aep = "EnglandAct"
		aip = "IrelandAct"
		apgb = "GreatBritainAct"
		mnia = "NorthernIrelandAssemblyMeasure"
		apni = "NorthernIrelandParliamentAct"
		uksi = "UnitedKingdomStatutoryInstrument"
		wsi = "WelshStatutoryInstrument"
		ssi = "ScottishStatutoryInstrument"
		nisi = "NorthernIrelandOrderInCouncil"
		nisr = "NorthernIrelandStatutoryRule"
		ukci = "UnitedKingdomChurchInstrument"
		ukmd = "UnitedKingdomMinisterialDirection"
		ukmo = "UnitedKingdomMinisterialOrder"
		uksro = "UnitedKingdomStatutoryRuleOrOrder"
		nisro = "NorthernIrelandStatutoryRuleOrOrder"
		ukdpb = "UnitedKingdomDraftPublicBill"
		ukdsi = "UnitedKingdomDraftStatutoryInstrument"
		sdsi = "ScottishDraftStatutoryInstrument"
		nidsr = "NorthernIrelandDraftStatutoryRule"
		eur = "EuropeanUnionRegulation"
		eudn = "EuropeanUnionDecision"
		eudr = "EuropeanUnionDirective"
		eut = "EuropeanUnionTreaty"
	/>
</xsl:variable>

<xsl:variable name="short-types" as="element()">
	<shortTypes
		UnitedKingdomPublicGeneralAct = "ukpga"
		UnitedKingdomLocalAct = "ukla"
		ScottishAct = "asp"
		WelshNationalAssemblyAct = "anaw"
		WelshAssemblyMeasure = "mwa"
		UnitedKingdomChurchMeasure = "ukcm"
		NorthernIrelandAct = "nia"
		ScottishOldAct = "aosp"
		EnglandAct = "aep"
		IrelandAct = "aip"
		GreatBritainAct = "apgb"
		NorthernIrelandAssemblyMeasure = "mnia"
		NorthernIrelandParliamentAct = "apni"
		UnitedKingdomStatutoryInstrument = "uksi"
		WelshStatutoryInstrument = "wsi"
		ScottishStatutoryInstrument = "ssi"
		NorthernIrelandOrderInCouncil = "nisi"
		NorthernIrelandStatutoryRule = "nisr"
		UnitedKingdomChurchInstrument = "ukci"
		UnitedKingdomMinisterialDirection = "ukmd"
		UnitedKingdomMinisterialOrder = "ukmo"
		UnitedKingdomStatutoryRuleOrOrder = "uksro"
		NorthernIrelandStatutoryRuleOrOrder = "nisro"
		UnitedKingdomDraftPublicBill = "ukdpb"
		UnitedKingdomDraftStatutoryInstrument = "ukdsi"
		ScottishDraftStatutoryInstrument = "sdsi"
		NorthernIrelandDraftStatutoryRule = "nidsr"
		EuropeanUnionRegulation = "eur"
		EuropeanUnionDecision = "eudn"
		EuropeanUnionDirective = "eudr"
		EuropeanUnionTreaty = "eut"
	/>
</xsl:variable>

<xsl:variable name="primary-short-types" as="xs:string*" select="
	( 'ukpga', 'ukla', 'asp', 'anaw', 'mwa', 'ukcm', 'nia', 'aosp', 'aep', 'aip', 'apgb', 'mnia', 'apni' )
" />

<xsl:variable name="secondary-short-types" as="xs:string*" select="
	( 'uksi', 'wsi', 'ssi', 'nisi', 'nisr', 'ukci', 'ukmd', 'ukmo', 'uksro', 'nisro', 'ukdpb', 'ukdsi', 'sdsi', 'nidsr' )
" />

<xsl:variable name="eu-short-types" as="xs:string*" select="
	( 'eur', 'eudn', 'eudr', 'eut' )
" />

<xsl:function name="local:long-type-from-short" as="xs:string">
	<xsl:param name="short-type" as="xs:string" />
	<xsl:value-of select="$long-types/@*[name()=$short-type]" />
</xsl:function>

<xsl:function name="local:category-from-short-type" as="xs:string?">
	<xsl:param name="short-type" as="xs:string" />
	<xsl:choose>
		<xsl:when test="$short-type = $primary-short-types">
			<xsl:text>primary</xsl:text>
		</xsl:when>
		<xsl:when test="$short-type = $secondary-short-types">
			<xsl:text>secondary</xsl:text>
		</xsl:when>
		<xsl:when test="$short-type = $eu-short-types">
			<xsl:text>euretained</xsl:text>
		</xsl:when>
	</xsl:choose>
</xsl:function>

<xsl:function name="local:resolve-tlc-show-as" as="xs:string">
	<xsl:param name="showAs" as="attribute()" />
	<xsl:variable name="components" as="xs:string*">
		<xsl:for-each select="tokenize(normalize-space($showAs), ' ')">
			<xsl:choose>
				<xsl:when test="starts-with(., '#')">
					<xsl:variable name="tlc" as="element()" select="key('tlc', substring(., 2), root($showAs))" />
					<xsl:sequence select="local:resolve-tlc-show-as($tlc/@showAs)" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:sequence select="." />
				</xsl:otherwise>
			</xsl:choose>
		</xsl:for-each>
	</xsl:variable>
	<xsl:value-of select="string-join($components, ' ')" />
</xsl:function>


<!-- variables -->

<xsl:variable name="doc-short-type" as="xs:string" select="/akomaNtoso/*/@name" />

<xsl:variable name="doc-long-type" as="xs:string">
	<xsl:value-of select="local:long-type-from-short($doc-short-type)" />
</xsl:variable>

<xsl:variable name="doc-category" as="xs:string">
	<xsl:value-of select="local:category-from-short-type($doc-short-type)" />
</xsl:variable>

<xsl:variable name="doc-subtype" as="xs:string?" select="/akomaNtoso/*/meta/identification/FRBRWork/FRBRsubtype/@value" />

<xsl:variable name="doc-year" as="xs:integer">
	<xsl:choose>
		<xsl:when test="exists(/akomaNtoso/*/meta/proprietary/ukm:Year)">
			<xsl:value-of select="xs:integer(/akomaNtoso/*/meta/proprietary/ukm:Year/@Value)" />
		</xsl:when>
		<xsl:otherwise>
			<xsl:value-of select="xs:integer(key('tlc', 'varActYear')/@showAs)" />
		</xsl:otherwise>
	</xsl:choose>
</xsl:variable>

<xsl:variable name="doc-number" as="xs:string">
	<xsl:variable name="frbr" as="xs:string?" select="/akomaNtoso/*/meta/identification/FRBRWork/FRBRnumber/@value" />
	<xsl:choose>
		<xsl:when test="exists($frbr)">
			<xsl:choose>
				<xsl:when test="$frbr = '#varProjectId'">
					<xsl:value-of select="key('tlc', 'varProjectId')/@showAs" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$frbr" />
				</xsl:otherwise>
			</xsl:choose>
		</xsl:when>
		<xsl:otherwise>
			<xsl:value-of select="key('tlc', 'varActNo')/@showAs" />
		</xsl:otherwise>
	</xsl:choose>
</xsl:variable>

<xsl:variable name="doc-title" as="xs:string">
	<xsl:variable name="dc-title" as="element()" select="/akomaNtoso/*/meta/proprietary/dc:title[1]" />
	<xsl:choose>
		<xsl:when test="exists($dc-title)">
			<xsl:choose>
				<xsl:when test="$dc-title/ref[@class='placeholder']">
					<xsl:variable name="ref" as="xs:string" select="$dc-title/ref[@class='placeholder']/@href" />
					<xsl:value-of select="key('tlc', substring($ref, 2))/@showAs" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$dc-title" />
				</xsl:otherwise>
			</xsl:choose>
		</xsl:when>
		<xsl:otherwise>
			<xsl:variable name="tlc" as="element()" select="key('tlc', 'varActTitle')" />
			<xsl:value-of select="local:resolve-tlc-show-as($tlc/@showAs)" />
		</xsl:otherwise>
	</xsl:choose>
</xsl:variable>

<xsl:variable name="doc-short-id" as="xs:string">
	<xsl:value-of select="concat($doc-short-type, '/', $doc-year, '/', $doc-number)" />
</xsl:variable>

<xsl:variable name="doc-long-id" as="xs:string">
	<xsl:value-of select="concat('http://www.legislation.gov.uk/', $doc-short-id)" />
</xsl:variable>

</xsl:transform>
