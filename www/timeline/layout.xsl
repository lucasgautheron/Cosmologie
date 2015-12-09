<xsl:stylesheet version="2.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:doc="http://sciencestechniques.fr"
  exclude-result-prefixes="xs doc">
  
  <xsl:variable name="linkwords" select="//ressources/ressource/linkwords/linkword"/>
  <xsl:function name="doc:find-matching-linkword">
    <xsl:param name="text"/>
    <xsl:copy-of select="(data(($linkwords[contains($text, .)])[1]/../../@id), ($linkwords[contains($text, .)])[1], data(($linkwords[contains($text, .)])[1]/../../title))"/>
  </xsl:function>
  <xsl:function name="doc:add-links" as="item()*">
    <xsl:param name="text"/>
    <xsl:variable name="linkword" select="doc:find-matching-linkword($text)"/>
    <xsl:choose>
      <xsl:when test="$linkword[1]">
        <xsl:value-of select="substring-before($text, $linkword[2])"/>
        <a href="ressources/ressource_{$linkword[1]}.html" class="ressource" data-rid="{$linkword[1]}" title="{$linkword[3]}"><xsl:value-of select="$linkword[2]"/></a>
        <xsl:copy-of select="doc:add-links(substring-after($text, $linkword[2]))"/>
      </xsl:when>
      <xsl:otherwise><xsl:value-of select="$text"/></xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  <xsl:template match="text//text()">
    <xsl:copy-of select="doc:add-links(.)"/>
  </xsl:template>
  <xsl:template match="node()|@*">
    <xsl:copy><xsl:apply-templates select="node()|@*"/></xsl:copy>
  </xsl:template>
  
  <xsl:template match="text">
    <xsl:apply-templates />
  </xsl:template>
  
 <xsl:template match="b">
    <span style="font-weight:bold;">
      <xsl:apply-templates />
    </span>  
  </xsl:template>
  
  <xsl:template match="i">
    <span style="font-style:italic;">
      <xsl:apply-templates />
    </span>  
  </xsl:template>
  
  <xsl:template match="p">
    <p>
      <xsl:apply-templates />
    </p>  
  </xsl:template>
  
  <xsl:template match="figure">
    <div class="figure">
      <a href="../images/{./@src}" target="_blank">
        <xsl:choose>
          <xsl:when test="string(./@width)">
            <img src="../images/{./@src}" title="{.}" width="{./@width}" />
          </xsl:when>
          <xsl:otherwise>
            <img src="../images/{./@src}" title="{.}" />
          </xsl:otherwise>
        </xsl:choose>
      </a>
      <div class="label">
        <xsl:value-of select="./@title" />
      </div>
      <div class="caption">
        <xsl:apply-templates />
      </div></div>
  </xsl:template>
  
  <xsl:template match="feynman">
    <div class="feynman" data-fid="{./@id}"><div class="diagram"></div><span class="caption"><b><xsl:value-of select="./@title" /> </b></span></div>
    <script>
      $('.feynman[data-fid="<xsl:value-of select="./@id" />"] .diagram').feyn({<xsl:value-of select="." />});
    </script>
  </xsl:template>
  
  <xsl:template match="spoiler">
    <div class="spoiler"><span><a href="#" class="spoiler_toggle" >Afficher/Masquer</a></span><div><xsl:apply-templates /></div></div>
  </xsl:template>
  
  <xsl:template match="quote">
    <div class="quote"><div><xsl:apply-templates /></div><span class="quote"><xsl:value-of select="./@author" />, <xsl:value-of select="./@date" /></span></div>
  </xsl:template>
  
  <xsl:template match="note">
    <div class="note_container"><a class="note_indicator" href="#"><sup>[?]</sup></a><div class="note"><xsl:apply-templates /></div></div>
  </xsl:template>
  
<xsl:template match="/">
  <html>
    <head>
      <title>Histoire de la Cosmologie</title>
      <meta charset="utf-8" />
      <link rel="stylesheet" type="text/css" href="style.css" />
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/2.1.3/jquery.min.js"></script>
    <script src="feynman.js"></script>
    <script type="text/x-mathjax-config">
    MathJax.Hub.Config({
      config: ["MMLorHTML.js"],
      jax: ["input/TeX","input/MathML","input/AsciiMath","output/HTML-CSS","output/NativeMML", "output/CommonHTML"],
      extensions: ["tex2jax.js","mml2jax.js","asciimath2jax.js","MathMenu.js","MathZoom.js", "CHTML-preview.js"],
      TeX: {
        extensions: ["AMSmath.js","AMSsymbols.js","noErrors.js","noUndefined.js"]
      },
      tex2jax: {
          inlineMath: [ ['$','$'], ["\\(","\\)"] ],
          displayMath: [ ['$$','$$'], ["\\[","\\]"] ],
          processEscapes: true
      },
      "HTML-CSS": {
          availableFonts: ["TeX"]
      }
    });
    </script>
    <script type="text/javascript"
      src="https://cdn.mathjax.org/mathjax/latest/MathJax.js?config=TeX-AMS-MML_HTMLorMML"> 
    </script>
    <script type="text/javascript" src="navigation.js">
    </script>
    </head>
    <body>
      <div id="navigation"><a href="#" id="show_timeline">Frise</a> | <a href="#" id="show_previous">Précédent</a> | <a href="#" id="show_next">Suivant</a></div>
      <div id="timeline">
      <h1>Timeline</h1>
        <ul>
          <xsl:for-each select="root/events/event[not(@hidden=1)]">
            <xsl:sort select="./@date" />
            <li><b><xsl:value-of select="./@date" /></b> : <a href="contents/content_{./@content-id}.html" data-cid="{./@content-id}"><xsl:value-of select="." /></a></li>
          </xsl:for-each>
        </ul>
        <div>Les conventions suivantes sont utilisées :
          <ul>
            <li>Signature métrique $(+,-,-,-)$</li>
            <li>$c$ apparait explicitement dans les équations (les distances sont donc exprimées en mètres et les temps en secondes) sauf mention contraire</li>
            <li>L'origine du temps cosmologique $t=0$ correspond au temps actuel (la coordonnée $t$ du big bang est donc égale à l'opposé de l'âge de l'Univers)</li>
            <li>Pour un univers homogène et isotrope, $R$ est le rayon de courbure de l'Univers, et $k$ un entier relatif pouvant valoir $-1$ (géométrie sphérique), $0$ (géométrie euclidienne), $1$ (géométrie hyperbolique)</li>
          </ul>
        </div>
        <div>
          Le site fait appel aux technologies et programmes suivants :
          <ul>
            <li><a href="http://www.w3schools.com/xml/xml_xsl.asp">XML/XSLT</a> pour le contenu et sa traduction en HTML</li>
            <li><a href="https://www.mathjax.org/">MathJax</a> pour les équations LaTeX</li>
            <li><a href="http://photino.github.io/jquery-feyn">JQuery Feyn</a> pour les diagrammes de Feynman</li>
            <li><a href="http://gnuplot.sourceforge.net/">Gnuplot</a> pour les plots</li>
            <li><a href="https://root.cern.ch/">ROOT</a> et le langage C pour les simulations</li>
            <li><a href="http://github.com/">github</a> pour la gestion du projet</li>
          </ul>
        </div>
      </div>
      
      <div id="content">
        <h2 class="title"></h2>
        <div id="timeline"></div>
        <div class="text"></div>
        <div class="references"></div>
        <div class="image"></div>
      </div>
      
      <div id="ressource">
        <h2 class="title"></h2>
        <div class="text"></div>
        <div class="references"></div>
      </div>

    <div class="clear"></div>
    </body>
  </html>

<xsl:for-each select="root/contents/content">
 <xsl:variable name="id" select="./@id"/>
<xsl:result-document method="html" href="contents/content_{./@id}.html">
  <div id="content">
    <div id="horizontal_timeline">
      <ul>
      <xsl:for-each select="/root/events/event[@content-id=$id]">
        <xsl:sort select="./@date" />
        <li><b><xsl:value-of select="./@date" /></b> : <xsl:value-of select="." /></li>
      </xsl:for-each>
      </ul>
    </div>
    <h2 id="title"><xsl:value-of select="./title" /></h2>
    <div id="text"><xsl:apply-templates select="text" /></div>
    <div id="references">
      <ul>
        <xsl:for-each select="/root/references/reference[@content-id=$id]">
          <xsl:sort select="./date" />
          <li><i><a href="../references/{./file}" target="_blank" title="{./text}"><xsl:value-of select="./title" /></a></i>, <xsl:value-of select="./author" /> (<xsl:value-of select="./date" />)</li>
        </xsl:for-each>
      </ul>
    </div>
    <div id="image"><img src="images/{./image}" /></div>
  </div>
</xsl:result-document>
</xsl:for-each>
  
<xsl:for-each select="root/ressources/ressource">
  <xsl:variable name="id" select="./@id"/>
  <xsl:result-document method="html" href="ressources/ressource_{./@id}.html">
    <div id="ressource">
      <h2 id="title"><xsl:value-of select="./title" /></h2>
      <div id="text"><xsl:apply-templates select="text" /></div>
      <div id="references">
        <ul>
          <xsl:for-each select="/root/references/reference[@ressource-id=$id]">
            <xsl:sort select="./date" />
            <li><i><a href="../references/{./file}" target="_blank"><xsl:value-of select="./title" /></a></i>, <xsl:value-of select="./author" /> (<xsl:value-of select="./date" />)</li>
          </xsl:for-each>
        </ul>
      </div>
    </div>
  </xsl:result-document>
</xsl:for-each>
</xsl:template>
</xsl:stylesheet>
