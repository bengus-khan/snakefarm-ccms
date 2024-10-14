<?xml version="1.0" encoding="UTF-8"?>
<?xml-model href="../docbook_5.0/docbookxi.rng"?>

<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:d="http://docbook.org/ns/docbook"
    xmlns:svg="http://www.w3.org/2000/svg"
    xmlns:fo="http://www.w3.org/1999/XSL/Format"
    xmlns:l="http://docbook.sourceforge.net/xmlns/l10n/1.0"
    xmlns:t="http://nwalsh.com/docbook/xsl/template/1.0">

    <!-- ================================================================================
    link to original docbook stylesheets - figure out which link actually works - here's a hint, it's the sourceforge one

    <xsl:import href="http://docbook.sourceforge.net/release/xsl-ns/current/fo/docbook.xsl"/>
    <xsl:import href="https://cdn.docbook.org/release/xsl/current/fo/docbook.xsl"/>
    <xsl:import href="/usr/share/xml/docbook/stylesheet/docbook-xsl-ns"/>

    ==================================================================================-->

    <xsl:import href="http://docbook.sourceforge.net/release/xsl-ns/current/fo/docbook.xsl"/>

    <!-- ================================================================================
        Customizations to-do list:

        Critical-ish:
        - add customizations for <code/> inline element
        - fix font on second physical page, where doc title/subtitle are listed, above legal notice... ok now the title is ok, but has the annoying line break I had to add for front page. also, the subtitle is gone which feels goofy
        - fix the stupid brackets in table 1.1 link font row
        - go down one weight (to 500 from 700 I think) for bold font... gotta deal with the stupid ass role attribute on the emphasis element, which is a whole thing I gotta figure out - not entirely sure that I want to do this anymore actually

        Ideal:
        - fix number font in ordered lists (already fixed in procedures)
        - create sexy lil title page
        - add revhistory to published output
        - make keep-together=always for glossentry element
        - change header: chapter title on inner column of header (i.e., left on recto page) ONLY on non-first chapter pages, AC logo on outer column

        Keep the DocBook XSL stylesheets and documentation, as well as Apache FOP documentation, within reach.
    ================================================================================= -->

    <!-- ================================================================================
        Brand Color Palette
        White:          #ffffff (thank fkn god)
        Black:       #1c1a17
        Blue:        #1a4d6d
        Malibu:         #7dcef1
        Slate:          #4b4947
        Iceberg:        #ccebf1
        White Smoke:    #edeae8
        Firebrick:      #c32c27

        Bengus Special Color Palette
        Pale yellow     #fbeebb
        Pale green      #d5fbd9
        Pale AC Blue:   #cad9e3
        Pale Firebrick: #f3d4d3

    ================================================================================= -->

    <!-- start customizations -->

    <!-- updatable parameters - try to move these to daps DC files -->
    <xsl:param name="double.sided" select="0"/>
    <xsl:param name="show.comments" select="0"/>
    <xsl:param name="generate.toc">
        book    toc,title
    </xsl:param>

    <!-- pagination parameters -->
    <xsl:param name="page.margin.top">0.5in</xsl:param>
    <xsl:param name="page.margin.bottom">0.5in</xsl:param>
    <xsl:param name="page.margin.inner">
        <xsl:choose>
            <xsl:when test="$double.sided != 0">1.125in</xsl:when>
            <xsl:otherwise>0.5in</xsl:otherwise>
        </xsl:choose>
    </xsl:param>
    <xsl:param name="page.margin.outer">0.5in</xsl:param>
    <xsl:param name="force.blank.pages" select="1"/> <!-- EDITNOTE: study behavior when 90% of formatting is done - figure out if this belongs w/ updatable parameters -->
    
    <!-- body parameters-->
    <xsl:param name="body.start.indent">4pc</xsl:param>
    <xsl:param name="body.font.family">Museo Sans</xsl:param>
    <xsl:param name="body.font.weight">300</xsl:param>
    <xsl:param name="body.font.size">11pt</xsl:param>

    <!-- header parameters -->
    <xsl:attribute-set name="header.content.properties">
        <xsl:attribute name="font-family">Museo Sans</xsl:attribute>
        <xsl:attribute name="font-weight">500</xsl:attribute>
        <xsl:attribute name="color">#1c1a17</xsl:attribute>
    </xsl:attribute-set>

    <!-- footer parameters -->
    <xsl:attribute-set name="footer.content.properties">
        <xsl:attribute name="font-family">Museo Sans</xsl:attribute>
        <xsl:attribute name="font-weight">500</xsl:attribute>
        <xsl:attribute name="color">#1c1a17</xsl:attribute>
    </xsl:attribute-set>

    <!-- front title page parameters -->
    <xsl:attribute-set name="book.titlepage.recto.style">
        <xsl:attribute name="font-family">Museo Sans</xsl:attribute>
        <xsl:attribute name="font-weight">300</xsl:attribute>
        <xsl:attribute name="font-style">normal</xsl:attribute>
        <xsl:attribute name="color">#1c1a17</xsl:attribute>
    </xsl:attribute-set>
    <xsl:template match="d:title" mode="book.titlepage.recto.auto.mode">
        <fo:block xsl:use-attribute-sets="book.titlepage.recto.style" text-align="left" font-size="30pt" space-before="16pt" font-weight="700" font-family="Mont" color="#1c1a17">
            <xsl:call-template name="division.title">
                <xsl:with-param name="node" select="ancestor-or-self::d:book[1]"/>
            </xsl:call-template>
        </fo:block>
    </xsl:template>
    <xsl:template match="d:subtitle" mode="book.titlepage.recto.auto.mode">
        <fo:block xsl:use-attribute-sets="book.titlepage.recto.style" text-align="left" font-size="24pt" space-before="12pt" font-weight="300" font-family="Mont" color="#1c1a17">
            <xsl:apply-templates select="." mode="book.titlepage.recto.mode"/>
        </fo:block>
    </xsl:template>

    <!-- front matter parameters - i.e., legalnotice, ToC, etc. -->
    <xsl:attribute-set name="toc.line.properties">
        <xsl:attribute name="font-family">Museo Sans</xsl:attribute>
        <xsl:attribute name="font-weight">300</xsl:attribute>
        <xsl:attribute name="font-style">normal</xsl:attribute>
        <xsl:attribute name="color">#1c1a17</xsl:attribute>
    </xsl:attribute-set>
    <xsl:template name="table.of.contents.titlepage.recto">
        <fo:block xsl:use-attribute-sets="table.of.contents.titlepage.recto.style" space-before.minimum="1em" space-before.optimum="1.5em" space-before.maximum="2em" space-after="0.5em" start-indent="0pt" font-size="18pt" font-weight="300" font-family="Mont" color="#1c1a17">
            <xsl:call-template name="gentext">
                <xsl:with-param name="key" select="'TableofContents'"/>
            </xsl:call-template>
        </fo:block>
    </xsl:template>
    <xsl:template name="list.of.figures.titlepage.recto">
        <fo:block xsl:use-attribute-sets="list.of.figures.titlepage.recto.style" space-before.minimum="1em" space-before.optimum="1.5em" space-before.maximum="2em" space-after="0.5em" start-indent="0pt" font-size="18pt" font-weight="300" font-family="Mont" color="#1c1a17">
            <xsl:call-template name="gentext">
                <xsl:with-param name="key" select="'ListofFigures'"/>
            </xsl:call-template>
        </fo:block>
    </xsl:template>
    <xsl:template name="list.of.tables.titlepage.recto">
        <fo:block xsl:use-attribute-sets="list.of.tables.titlepage.recto.style" space-before.minimum="1em" space-before.optimum="1.5em" space-before.maximum="2em" space-after="0.5em" start-indent="0pt" font-size="18pt" font-weight="300" font-family="Mont" color="#1c1a17">
            <xsl:call-template name="gentext">
                <xsl:with-param name="key" select="'ListofTables'"/>
            </xsl:call-template>
        </fo:block>
    </xsl:template>
    <xsl:template match="d:copyright" mode="book.titlepage.verso.auto.mode">
        <fo:block xsl:use-attribute-sets="book.titlepage.verso.style" font-family="Museo Sans" font-weight="300" font-size="10pt" color="#1c1a17">
            <xsl:apply-templates select="." mode="book.titlepage.verso.mode"/>
        </fo:block>
    </xsl:template>
    <xsl:template match="d:title|d:subtitle" mode="book.titlepage.verso.auto.mode">
        <fo:block xsl:use-attribute-sets="book.titlepage.verso.style" font-family="Mont" font-weight="300" font-size="18pt" color="#1c1a17">
            <xsl:apply-templates select="." mode="book.titlepage.verso.mode"/>
        </fo:block>
    </xsl:template>

    <!-- miscellaneous parameters-->
    <xsl:param name="fop1.extensions" select="1"/>
    <xsl:param name="hyphenate">false</xsl:param>

    <!-- paragraph parameters -->
    <xsl:attribute-set name="para.properties" use-attribute-sets="normal.para.spacing">
        <xsl:attribute name="font-family">Museo Sans</xsl:attribute>
        <xsl:attribute name="font-weight">
            <xsl:choose>
                <xsl:when test="ancestor::d:thead or ancestor::d:tfoot">700</xsl:when>
                <xsl:otherwise>300</xsl:otherwise>
            </xsl:choose>
        </xsl:attribute>
        <xsl:attribute name="color">
            <xsl:choose>
                <xsl:when test="ancestor::d:thead or ancestor::d:tfoot">#ffffff</xsl:when>
                <xsl:otherwise>#1c1a17</xsl:otherwise>
            </xsl:choose>
        </xsl:attribute>
    </xsl:attribute-set>
    <xsl:attribute-set name="normal.para.spacing">
        <xsl:attribute name="space-before.minimum">0.8em</xsl:attribute>
        <xsl:attribute name="space-before.optimum">1em</xsl:attribute>
        <xsl:attribute name="space-before.maximum">1.2em</xsl:attribute>
    </xsl:attribute-set>

    <!-- inline text element parameters -->
    <xsl:template match="d:guilabel">
        <xsl:call-template name="inline.guilabelseq"/>
    </xsl:template>
    <xsl:template name="inline.guilabelseq">
        <xsl:param name="content">
            <xsl:apply-templates/>
        </xsl:param>
        <xsl:param name="contentwithlink">
            <xsl:call-template name="simple.xlink">
                <xsl:with-param name="content" select="$content"/>
            </xsl:call-template>
        </xsl:param>
        <fo:inline font-family="Museo Sans" font-weight="700" font-style="italic" font-size="11pt" color="#1a4d6d">
            <xsl:if test="@dir">
                <xsl:attribute name="direction">
                    <xsl:choose>
                        <xsl:when test="@dir = 'ltr' or @dir = 'lro'">ltr</xsl:when>
                        <xsl:otherwise>rtl</xsl:otherwise>
                    </xsl:choose>
                </xsl:attribute>
            </xsl:if>
            <xsl:copy-of select="$contentwithlink"/>
        </fo:inline>
    </xsl:template>
    <xsl:template match="d:guibutton">
        <xsl:call-template name="inline.guibuttonseq"/>
    </xsl:template>
    <xsl:template name="inline.guibuttonseq">
        <xsl:param name="content">
            <xsl:apply-templates/>
        </xsl:param>
        <xsl:param name="contentwithlink">
            <xsl:call-template name="simple.xlink">
                <xsl:with-param name="content" select="$content"/>
            </xsl:call-template>
        </xsl:param>
        <fo:inline font-family="Museo Sans" font-weight="700" font-style="normal" font-size="11pt" color="#1a4d6d">
            <xsl:if test="@dir">
                <xsl:attribute name="direction">
                    <xsl:choose>
                        <xsl:when test="@dir = 'ltr' or @dir = 'lro'">ltr</xsl:when>
                        <xsl:otherwise>rtl</xsl:otherwise>
                    </xsl:choose>
                </xsl:attribute>
            </xsl:if>
            <xsl:copy-of select="$contentwithlink"/>
        </fo:inline>
    </xsl:template>

    <!-- forced page breaks - the processing instruction is called at the source level, meaning print & digital PDFs will get same hard breaks. If you want to differentiate, maybe try setting up a print and a digital version of the PI (assuming custom PIs are economical to develop) -->
    <xsl:template match="processing-instruction('hard-pagebreak')">
        <fo:block break-after="page"/>
    </xsl:template>

    <!-- forced line breaks - similar to above -->
    <xsl:template match="processing-instruction('linebreak')">
        <fo:block/>
    </xsl:template>

    <!-- admonition parameters-->
    <xsl:param name="admon.graphics" select="0"/>
    <xsl:param name="admon.textlabel" select="0"/>
    <xsl:attribute-set name="admonition.title.properties">
        <xsl:attribute name="font-size">14pt</xsl:attribute>
        <xsl:attribute name="font-weight">bold</xsl:attribute>
        <xsl:attribute name="keep-with-next.within-column">always</xsl:attribute>
        <xsl:attribute name="padding-bottom">0pt</xsl:attribute>
        <xsl:attribute name="space-before">0pt</xsl:attribute>
        <xsl:attribute name="space-after">0pt</xsl:attribute>
    </xsl:attribute-set>
    <xsl:attribute-set name="admonition.properties">
        <xsl:attribute name="padding-top">0pt</xsl:attribute>
        <xsl:attribute name="space-before">0pt</xsl:attribute>
        <xsl:attribute name="space-after">0pt</xsl:attribute>
    </xsl:attribute-set>
    <xsl:attribute-set name="nongraphical.admonition.properties">
        <xsl:attribute name="margin-left">0pc</xsl:attribute>
        <xsl:attribute name="start-indent">0pc</xsl:attribute>
        <xsl:attribute name="end-indent">1pc</xsl:attribute>
        <xsl:attribute name="padding">1pc</xsl:attribute>
    </xsl:attribute-set>
    <xsl:template name="nongraphical.admonition">
        <xsl:param name="node" select="."/>
        <xsl:variable name="id">
            <xsl:call-template name="object.id"/>
        </xsl:variable>
        <xsl:variable name="keep.together">
            <xsl:call-template name="pi.dbfo_keep-together"/>
        </xsl:variable>
        <fo:block id="{$id}" xsl:use-attribute-sets="nongraphical.admonition.properties" margin-left="0pc">
            <xsl:choose>
                <xsl:when test="$keep.together != ''">
                    <xsl:attribute name="keep-together.within-column">
                        <xsl:value-of select="$keep.together"/>
                    </xsl:attribute>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:attribute name="keep-together.within-column">always</xsl:attribute>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:choose>
                <xsl:when test="local-name($node)='note'"> <!-- color is white smoke -->
                    <xsl:attribute name="background-color">#edeae8</xsl:attribute>
                </xsl:when>
                <xsl:when test="local-name($node)='tip'"> <!-- color is a bengus special -->
                    <xsl:attribute name="background-color">#d5fbd9</xsl:attribute>
                </xsl:when>
                <xsl:when test="local-name($node)='important'"> <!-- color derived from ac blue -->
                    <xsl:attribute name="background-color">#cad9e3</xsl:attribute>
                </xsl:when>
                <xsl:when test="local-name($node)='caution'"> <!-- color is a bengus special -->
                    <xsl:attribute name="background-color">#fbeebb</xsl:attribute>
                </xsl:when>
                <xsl:when test="local-name($node)='warning'"> <!-- color is derived from firebrick -->
                    <xsl:attribute name="background-color">#f3d4d3</xsl:attribute>
                </xsl:when>
            </xsl:choose>
            <xsl:if test="$admon.textlabel != 0 or d:title or d:info/d:title">
                <fo:block keep-with-next.within-column='always' xsl:use-attribute-sets="admonition.title.properties">
                    <xsl:apply-templates select="." mode="object.title.markup">
                        <xsl:with-param name="allow-anchors" select="1"/>
                    </xsl:apply-templates>
                </fo:block>
            </xsl:if>
            <fo:block xsl:use-attribute-sets="admonition.properties">
                <xsl:apply-templates/>
            </fo:block>
        </fo:block>
    </xsl:template>

    <!-- sidebar parameters -->
    <xsl:param name="sidebar.float.type">end</xsl:param>
    <xsl:param name="sidebar.float.width">2in</xsl:param>
    <xsl:attribute-set name="sidebar.properties" use-attribute-sets="formal.object.properties">   
        <xsl:attribute name="border-style">none</xsl:attribute>
        <xsl:attribute name="border-width">0.5pt</xsl:attribute>
        <xsl:attribute name="border-color">#1c1a17</xsl:attribute>
        <xsl:attribute name="background-color"></xsl:attribute>
        <xsl:attribute name="start-indent">0pt</xsl:attribute>
        <xsl:attribute name="end-indent">0pt</xsl:attribute>
        <xsl:attribute name="padding-start">0pt</xsl:attribute>
        <xsl:attribute name="padding-end">0pt</xsl:attribute>
        <xsl:attribute name="padding-top">0pt</xsl:attribute>
        <xsl:attribute name="padding-bottom">0pt</xsl:attribute>
        <xsl:attribute name="margin-left">0pt</xsl:attribute>
        <xsl:attribute name="margin-right">0pt</xsl:attribute>
        <xsl:attribute name="margin-top">0pt</xsl:attribute>
        <xsl:attribute name="margin-bottom">0pt</xsl:attribute>
    </xsl:attribute-set>
    <xsl:template match="d:sidebar" name="sidebar">
        <!-- Also does margin notes -->
        <xsl:variable name="pi-type">
            <xsl:call-template name="pi.dbfo_float-type"/>
        </xsl:variable>
        <xsl:variable name="id">
            <xsl:call-template name="object.id"/>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="$pi-type = 'margin.note'">
                <xsl:call-template name="margin.note"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="content">
                    <fo:block xsl:use-attribute-sets="sidebar.properties" id="{$id}">
                        <xsl:call-template name="sidebar.titlepage"/>
                        <xsl:apply-templates select="node()[not(self::d:title) and not(self::d:info) and not(self::d:sidebarinfo)]"/>
                    </fo:block>
                </xsl:variable>
                <xsl:variable name="pi-width">
                    <xsl:call-template name="pi.dbfo_sidebar-width"/>
                </xsl:variable>
                <xsl:variable name="position">
                    <xsl:choose>
                        <xsl:when test="$pi-type != ''">
                            <xsl:value-of select="$pi-type"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="$sidebar.float.type"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <xsl:call-template name="floater">
                    <xsl:with-param name="content" select="$content"/>
                    <xsl:with-param name="position" select="$position"/>
                    <xsl:with-param name="width">
                        <xsl:choose>
                            <xsl:when test="$pi-width != ''">
                                <xsl:value-of select="$pi-width"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="$sidebar.float.width"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:with-param>
                    <xsl:with-param name="start.indent">
                        <xsl:choose>
                            <xsl:when test="$position = 'start' or $position = 'left'">0pt</xsl:when>
                            <xsl:when test="$position = 'end' or $position = 'right'">1pc</xsl:when>
                            <xsl:otherwise>0pt</xsl:otherwise>
                        </xsl:choose>
                    </xsl:with-param>
                    <xsl:with-param name="end.indent">
                        <xsl:choose>
                            <xsl:when test="$position = 'start' or $position = 'left'">1pc</xsl:when>
                            <xsl:when test="$position = 'end' or $position = 'right'">0pt</xsl:when>
                            <xsl:otherwise>0pt</xsl:otherwise>
                        </xsl:choose>
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- component title parameters - these basically influence chapter titles -->
    <xsl:attribute-set name="component.title.properties">
        <xsl:attribute name="font-size">22pt</xsl:attribute>
        <xsl:attribute name="font-family">Mont</xsl:attribute>
        <xsl:attribute name="font-style">normal</xsl:attribute>
        <xsl:attribute name="font-weight">700</xsl:attribute>
        <xsl:attribute name="color">#1a4d6d</xsl:attribute>
    </xsl:attribute-set>

    <!-- section title parameters -->
    <xsl:attribute-set name="section.title.properties">
        <xsl:attribute name="start-indent">4pc</xsl:attribute>
        <xsl:attribute name="font-family">Mont</xsl:attribute>
        <xsl:attribute name="font-weight">300</xsl:attribute>
        <xsl:attribute name="color">#1c1a17</xsl:attribute>
        <xsl:attribute name="space-before.minimum">1.4em</xsl:attribute>
        <xsl:attribute name="space-before.optimum">1.6em</xsl:attribute>
        <xsl:attribute name="space-before.maximum">1.8em</xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="section.title.level1.properties">
        <xsl:attribute name="start-indent">2pc</xsl:attribute>
        <xsl:attribute name="font-size">20pt</xsl:attribute>
        <xsl:attribute name="font-weight">500</xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="section.title.level2.properties">
        <xsl:attribute name="font-size">18pt</xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="section.title.level3.properties">
        <xsl:attribute name="font-size">16pt</xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="section.title.level4.properties">
        <xsl:attribute name="font-size">14pt</xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="section.title.level5.properties">
        <xsl:attribute name="font-size">12pt</xsl:attribute>
    </xsl:attribute-set>

    <!-- formal title properties for tables, figures, and lists -->
    <xsl:attribute-set name="formal.title.properties" use-attribute-sets="normal.para.spacing">
        <xsl:attribute name="font-size">12pt</xsl:attribute>
        <xsl:attribute name="font-weight">700</xsl:attribute>
        <xsl:attribute name="color">#1a4d6d</xsl:attribute>
    </xsl:attribute-set>

    <!-- itemized list parameters -->
    <xsl:attribute-set name="itemizedlist.label.properties">
        <xsl:attribute name="font-family">Museo Sans</xsl:attribute>
        <xsl:attribute name="font-weight">300</xsl:attribute>
        <xsl:attribute name="font-style">normal</xsl:attribute>
        <xsl:attribute name="color">#1c1a17</xsl:attribute>
    </xsl:attribute-set>
    <xsl:template name="itemizedlist.label.markup">
        <xsl:variable name="itemizedlist.depth" select="count(ancestor::listitem)"/> <!-- no worky -->
        <xsl:choose>
            <xsl:when test="$itemizedlist.depth mod 3 = 0">&#x2022;</xsl:when>
            <xsl:when test="$itemizedlist.depth mod 3 = 1">
            <!-- U+2023 -->
                <svg:svg width="11" height="11" xmlns="http://www.w3.org/2000/svg"> <!-- no worky -->
                    <svg:path d="M1,1 L1,10 L9,5 L1,1 Z" fill="#1c1a17" />
                </svg:svg>
            </xsl:when>
            <xsl:when test="$itemizedlist.depth mod 3 = 2">
                <!-- U+2043 -->
                <svg:svg width="11" height="11" xmlns="http://www.w3.org/2000/svg"> <!-- no worky -->
                    <svg:path d="M1,6 L10,6" stroke="#1c1a17" stroke-width="3"/>
                </svg:svg>
            </xsl:when>
        </xsl:choose>
        <!-- OLD itemizedlist bullet logic
        <xsl:param name="itemsymbol" select="'disc'"/>
        <xsl:choose>
            <xsl:when test="$itemsymbol='none'"></xsl:when>
            <xsl:when test="$itemsymbol='disc'">&#x2022;</xsl:when>
            <xsl:when test="$itemsymbol='bullet'">&#x2022;</xsl:when>
            <xsl:when test="$itemsymbol='endash'">&#x2013;</xsl:when>
            <xsl:when test="$itemsymbol='emdash'">&#x2014;</xsl:when>
            (START COMMENT)
            Some of these may work in your XSL-FO processor and fonts
            <xsl:when test="$itemsymbol='square'">&#x25A0;</xsl:when>
            <xsl:when test="$itemsymbol='box'">&#x25A0;</xsl:when>
            <xsl:when test="$itemsymbol='smallblacksquare'">&#x25AA;</xsl:when>
            <xsl:when test="$itemsymbol='circle'">&#x25CB;</xsl:when>
            <xsl:when test="$itemsymbol='opencircle'">&#x25CB;</xsl:when>
            <xsl:when test="$itemsymbol='whitesquare'">&#x25A1;</xsl:when>
            <xsl:when test="$itemsymbol='smallwhitesquare'">&#x25AB;</xsl:when>
            <xsl:when test="$itemsymbol='round'">&#x25CF;</xsl:when>
            <xsl:when test="$itemsymbol='blackcircle'">&#x25CF;</xsl:when>
            <xsl:when test="$itemsymbol='whitebullet'">&#x25E6;</xsl:when>
            <xsl:when test="$itemsymbol='triangle'">&#x2023;</xsl:when>
            <xsl:when test="$itemsymbol='point'">&#x203A;</xsl:when>
            <xsl:when test="$itemsymbol='hand'"><fo:inline font-family="Wingdings 2">A</fo:inline></xsl:when>
            (END COMMENT)
            <xsl:otherwise>&#x2022;</xsl:otherwise>
        </xsl:choose> -->
    </xsl:template>
    <xsl:template match="d:itemizedlist">
        <xsl:variable name="id">
            <xsl:call-template name="object.id"/>
        </xsl:variable>
        <xsl:variable name="keep.together">
            <xsl:call-template name="pi.dbfo_keep-together"/>
        </xsl:variable>
        <xsl:variable name="pi-label-width">
            <xsl:call-template name="pi.dbfo_label-width"/>
        </xsl:variable>
        <xsl:variable name="label-width">
            <xsl:choose>
                <xsl:when test="$pi-label-width = ''">
                    <xsl:value-of select="$itemizedlist.label.width"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$pi-label-width"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:if test="d:title">
            <xsl:apply-templates select="d:title" mode="list.title.mode"/>
        </xsl:if>
        <!-- Preserve order of PIs and comments -->
        <xsl:apply-templates select="*[not(self::d:listitem or self::d:title or self::d:titleabbrev)]|comment()[not(preceding-sibling::d:listitem)]|processing-instruction()[not(preceding-sibling::d:listitem)]"/>
        <xsl:variable name="content">
            <xsl:apply-templates select="d:listitem|comment()[preceding-sibling::d:listitem]|processing-instruction()[preceding-sibling::d:listitem]"/>
        </xsl:variable>
        <!-- nested lists don't add extra list-block spacing -->
        <xsl:choose>
            <xsl:when test="ancestor::d:listitem">
                <fo:list-block id="{$id}" xsl:use-attribute-sets="itemizedlist.properties">
                    <xsl:attribute name="provisional-distance-between-starts">
                        <xsl:value-of select="$label-width"/>
                    </xsl:attribute>
                    <xsl:choose>
                        <xsl:when test="$keep.together != ''">
                            <xsl:attribute name="keep-together.within-column">
                                <xsl:value-of select="$keep.together"/>
                            </xsl:attribute>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:choose>
                                <xsl:when test="ancestor::d:listitem">
                                    <xsl:attribute name="keep-together.within-column">
                                        <xsl:attribute name="keep-together.within-column">always</xsl:attribute>
                                    </xsl:attribute>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:attribute name="keep-together.within-column">auto</xsl:attribute>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:otherwise>
                    </xsl:choose>
                    <xsl:copy-of select="$content"/>
                </fo:list-block>
            </xsl:when>
            <xsl:otherwise>
                <fo:list-block id="{$id}" xsl:use-attribute-sets="list.block.spacing itemizedlist.properties">
                    <xsl:attribute name="provisional-distance-between-starts">
                        <xsl:value-of select="$label-width"/>
                    </xsl:attribute>
                    <xsl:choose>
                        <xsl:when test="$keep.together != ''">
                            <xsl:attribute name="keep-together.within-column">
                                <xsl:value-of select="$keep.together"/>
                            </xsl:attribute>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:choose>
                                <xsl:when test="ancestor::d:listitem">
                                    <xsl:attribute name="keep-together.within-column">
                                        <xsl:attribute name="keep-together.within-column">always</xsl:attribute>
                                    </xsl:attribute>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:attribute name="keep-together.within-column">auto</xsl:attribute>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:otherwise>
                    </xsl:choose>
                    <xsl:copy-of select="$content"/>
                </fo:list-block>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- procedure parameters -->
    <xsl:template match="d:procedure/d:step|d:substeps/d:step">
        <xsl:variable name="id">
            <xsl:call-template name="object.id"/>
        </xsl:variable>
        <xsl:variable name="keep.together">
            <xsl:call-template name="pi.dbfo_keep-together"/>
        </xsl:variable>
        <fo:list-item xsl:use-attribute-sets="list.item.spacing">
            <xsl:if test="$keep.together != ''">
                <xsl:attribute name="keep-together.within-column"><xsl:value-of
                      select="$keep.together"/></xsl:attribute>
            </xsl:if>
            <fo:list-item-label font-family="Museo Sans" font-weight="300" font-style="normal" color="#1c1a17" end-indent="label-end()">
                <fo:block id="{$id}">
                    <!-- dwc: fix for one step procedures. Use a bullet if there's no step 2 -->
                    <xsl:choose>
                        <xsl:when test="count(../d:step) = 1">
                            <xsl:text>&#x2022;</xsl:text>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:apply-templates select="." mode="number">
                                <xsl:with-param name="recursive" select="0"/>
                            </xsl:apply-templates>.
                        </xsl:otherwise>
                    </xsl:choose>
                </fo:block>
            </fo:list-item-label>
            <fo:list-item-body start-indent="body-start()">
                <fo:block>
                    <xsl:apply-templates/>
                </fo:block>
            </fo:list-item-body>
        </fo:list-item>
    </xsl:template>

    <!-- table parameters -->
    <!-- EDITNOTE: choose-when-otherwise used to set thead & tfoot font properties under para.properties -->
    <xsl:param name="table.frame.border.color">#4b4947</xsl:param>
    <xsl:param name="table.cell.border.color">#4b4947</xsl:param>
    <xsl:attribute-set name="table.cell.padding">
        <xsl:attribute name="padding-start">2pt</xsl:attribute>
        <xsl:attribute name="padding-end">2pt</xsl:attribute>
        <xsl:attribute name="padding-top">4pt</xsl:attribute>
        <xsl:attribute name="padding-bottom">2pt</xsl:attribute>
    </xsl:attribute-set>
    <xsl:template name="table.row.properties">
        <xsl:variable name="keep.together">
            <xsl:call-template name="pi.dbfo_keep-together"/>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="$keep.together != ''">
                <xsl:attribute name="keep-together.within-column">
                    <xsl:value-of select="$keep.together"/>
                </xsl:attribute>
            </xsl:when>
            <xsl:otherwise>
                <xsl:attribute name="keep-together.within-column">always</xsl:attribute>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:choose>
            <xsl:when test="ancestor::d:informaltable">
                <xsl:attribute name="keep-with-next.within-column">auto</xsl:attribute>
            </xsl:when>
            <xsl:otherwise> <!-- EDITNOTE: The code inside this xsl:otherwise was originally the only code defining the keep-with-next.within-column attribute for table rows. I have chosen to override this definition when the row's parent element is an informaltable, allowing page breaks to occur between rows without restriction. The enclosed code has the effect of disabling page breaks within tables unless the page breaks within a row, when the row's keep-together.within-column attribute is set to auto. -->
                <xsl:choose>
                    <xsl:when test="following-sibling::*[1][self::d:row]">
                        <xsl:attribute name="keep-with-next.within-column">always</xsl:attribute>
                    </xsl:when>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:attribute name="text-align">left</xsl:attribute> <!-- EDITNOTE: maybe add conditions for text alignment processing instruction... if that's a thing? -->
        <!-- Row background color stuff -->
        <xsl:if test="ancestor::d:table">
            <xsl:choose>
                <xsl:when test="parent::d:thead or parent::d:tfoot">
                    <xsl:attribute name="background-color">#4b4947</xsl:attribute>
                </xsl:when>
                <xsl:when test="position() mod 2 = 0">
                    <xsl:attribute name="background-color">#edeae8</xsl:attribute>
                </xsl:when>
            </xsl:choose>
        </xsl:if>
        <!-- Row height stuff -->
        <xsl:variable name="row-height">
            <xsl:if test="processing-instruction('dbfo')">
                <xsl:call-template name="pi.dbfo_row-height"/>
            </xsl:if>
        </xsl:variable>
        <xsl:if test="$row-height != ''">
            <xsl:attribute name="block-progression-dimension">
                <xsl:value-of select="$row-height"/>
            </xsl:attribute>
        </xsl:if>
    </xsl:template>
    <xsl:attribute-set name="informaltable.properties">
        <xsl:attribute name="space-before.minimum">0.5em</xsl:attribute>
        <xsl:attribute name="space-before.optimum">0.5em</xsl:attribute>
        <xsl:attribute name="space-before.maximum">1em</xsl:attribute>
    </xsl:attribute-set>

    <!-- glossary parameters -->
    <xsl:attribute-set name="glossterm.list.properties">
        <xsl:attribute name="font-family">Museo Sans</xsl:attribute>
        <xsl:attribute name="font-style">normal</xsl:attribute>
        <xsl:attribute name="font-weight">500</xsl:attribute>
        <xsl:attribute name="color">#1c1a17</xsl:attribute>
    </xsl:attribute-set>
    <xsl:template match="d:glossentry/d:glossdef" mode="glossary.as.list"> <!-- glossseealso block attributes -->
        <xsl:apply-templates select="*[local-name(.) != 'glossseealso']"/>
        <xsl:if test="d:glossseealso">
            <fo:block font-family="Museo Sans" font-weight="100" font-style="italic" color="#1c1a17">
                <xsl:variable name="template">
                    <xsl:call-template name="gentext.template">
                        <xsl:with-param name="context" select="'glossary'"/>
                        <xsl:with-param name="name" select="'seealso'"/>
                    </xsl:call-template>
                </xsl:variable>
                <xsl:variable name="title">
                    <xsl:apply-templates select="d:glossseealso" mode="glossary.as.list"/>
                </xsl:variable>
                <xsl:call-template name="substitute-markup">
                    <xsl:with-param name="template" select="$template"/>
                    <xsl:with-param name="title" select="$title"/>
                </xsl:call-template>
            </fo:block>
        </xsl:if>
    </xsl:template>

    <!-- xref parameters -->
    <xsl:param name="xref.with.number.and.title" select="0"/>
    <xsl:attribute-set name="xref.properties">
        <xsl:attribute name="font-weight">500</xsl:attribute>
        <xsl:attribute name="color">#c32c27</xsl:attribute>
    </xsl:attribute-set>

    <!-- generated text customizations-->
    <xsl:param name="local.l10n.xml" select="document('')"/> 
    <l:i18n xmlns:l="http://docbook.sourceforge.net/xmlns/l10n/1.0">
        <l:l10n language="en">
            <l:context name="xref">
                <l:template name="bridgehead" text="“%t”"/>
                <l:template name="refsection" text="“%t”"/>
                <l:template name="refsect1" text="“%t”"/>
                <l:template name="refsect2" text="“%t”"/>
                <l:template name="refsect3" text="“%t”"/>
                <l:template name="sect1" text="“%t”"/>
                <l:template name="sect2" text="“%t”"/>
                <l:template name="sect3" text="“%t”"/>
                <l:template name="sect4" text="“%t”"/>
                <l:template name="sect5" text="“%t”"/>
                <l:template name="section" text="“%t”"/>
                <l:template name="simplesect" text="“%t”"/>
            </l:context>
        </l:l10n>
    </l:i18n>

    <!-- end customizations -->

    <!-- ============================================================================ -->

</xsl:stylesheet>