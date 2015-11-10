<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:template match="/">
  <html>
    <head>
      <title>Histoire de la Cosmologie</title>
      <meta charset="utf-8" />
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
    </head>
    <body>
      <h1>Timeline</h1>
      <ul>
        <xsl:for-each select="root/events/event">
          <li><b><xsl:value-of select="./@date" /></b> : <xsl:value-of select="." /></li>
        </xsl:for-each>
      </ul>

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

<xsl:for-each select="root/ressources/ressource">
<xsl:result-document method="html" href="ressources/ressource_{./@id}.html">
<html>
    <head>
      <title><xsl:value-of select="./title" /></title>
      <meta charset="utf-8" />
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
    </head>
    <body>
<xsl:value-of select="./title" />
<xsl:value-of select="./text" />
</body>
</html>
</xsl:result-document>
</xsl:for-each>
</xsl:template>
</xsl:stylesheet>
