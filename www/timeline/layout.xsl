<xsl:stylesheet version="2.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:doc="http://sciencestechniques.fr">
  
  <xsl:function name="doc:transform_ressource_links">
    <xsl:param name="nodes"/>
    <xsl:param name="text"/>
    <xsl:variable name="output" select="$text"/>
    <xsl:for-each select="$nodes/root/ressources/ressource/linkwords/linkword">
      <xsl:value-of select="$text" />
    </xsl:for-each>
  </xsl:function>
  
  <xsl:function name="doc:bold">
    <xsl:param name="text"/>
    <xsl:variable name="replacement">
      <![CDATA[<b>$1</b>]]>
    </xsl:variable>
    <xsl:copy-of select="replace($text, '\\textbf\{(.*)\}', $replacement)"/>
  </xsl:function>
  
<xsl:template match="/">
  <html>
    <head>
      <title>Histoire de la Cosmologie</title>
      <meta charset="utf-8" />
      <link rel="stylesheet" type="text/css" href="style.css" />
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/2.1.3/jquery.min.js"></script>
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
      <div><a href="#" id="show_timeline" style="display: none;">Show timeline</a></div>
      <div id="timeline">
      <h1>Timeline</h1>
        <ul>
          <xsl:for-each select="root/events/event">
            <li><b><xsl:value-of select="./@date" /></b> : <a href="#" data-cid="{./@content-id}"><xsl:value-of select="." /></a></li>
          </xsl:for-each>
        </ul>
      </div>
      
      <div id="content">
        <h2 class="title"></h2>
        <div id="timeline"></div>
        <div class="text"></div>
        <div class="image"></div>
      </div>
      
      <div id="ressource">
        <h2 class="title"></h2>
        <div class="text"></div>
      </div>

    <div class="clear"></div>
     <h1>Contents</h1>
       <div>
         <xsl:for-each select="root/contents/content">
          <h3><xsl:value-of select="./title" /></h3>
           <p><xsl:value-of select="./text" /></p>
        </xsl:for-each>
       </div>

      <h1>Ressources</h1>
       <div>
         <xsl:for-each select="root/ressources/ressource">
          <h3><xsl:value-of select="./title" /></h3>
          <p><xsl:value-of select="./text" /></p>
        </xsl:for-each>
       </div>
    </body>
  </html>

<xsl:for-each select="root/contents/content">
 <xsl:variable name="id" select="./@id"/>
<xsl:result-document method="html" href="contents/content_{./@id}.html">
  <div id="content">
    <div id="horizontal_timeline">
      <ul>
      <xsl:for-each select="/root/events/event[@content-id=$id]">
        <li><b><xsl:value-of select="./@date" /></b> : <xsl:value-of select="." /></li>
      </xsl:for-each>
      </ul>
    </div>
    <h2 id="title"><xsl:value-of select="./title" /></h2>
    <div id="text"><xsl:value-of select="./text" /></div>
    <div id="image"><img src="images/{./image}" /></div>
  </div>
</xsl:result-document>
</xsl:for-each>
  
<xsl:for-each select="root/ressources/ressource">
  <xsl:result-document method="html" href="ressources/ressource_{./@id}.html">
    <div id="ressource">
      <h2 id="title"><xsl:value-of select="./title" /></h2>
      <div id="text"><xsl:value-of select="./text" /></div>
    </div>
  </xsl:result-document>
</xsl:for-each>
</xsl:template>
</xsl:stylesheet>
