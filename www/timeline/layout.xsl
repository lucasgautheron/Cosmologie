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
    <script type="text/javascript">
      
      $(document).ready(function() {
          $("#timeline ul a").click(function() {
              show_content($(this).data('cid'));
              return false;
          });
          $("a.ressource").click(function() {
              show_ressource($(this).data('rid'));
              return false;
          });
          $("#show_timeline").click(function() {
              show_timeline();
              return false;
          });
      });
      
      function show_timeline()
      {
          hide_content();
          hide_ressource();
          $("#show_timeline").hide();
          $("#timeline").show(1000);
      }
      
      function hide_timeline()
      {
          $("#timeline").hide(1000);
          $("#show_timeline").show();
      }
      
      function show_content(id)
      {
          $.ajax({
            url: 'contents/content_' + id + '.html',
            type: 'GET',
            success: function(data) {
              hide_timeline();
              data_object = $($.parseHTML(data)); 
              $('#content #timeline').html(data_object.find('#horizontal_timeline').html());
              $('#content .title').text(data_object.find('#title').text());
              $('#content .text').html(data_object.find('#text').html().replace(/\n/g, "<br />"));
              $('#content .image').html(data_object.find('#image').html());
              $('#content').show();
              MathJax.Hub.Queue(["Typeset",MathJax.Hub]);
            },
            error: function(e) {
              console.log(e.message);
            }
          });
          
          show_ressource("103");
      }
      
      function hide_content(id)
      {
          $("#content").hide();
      }
      
      function show_ressource(id)
      {
          hide_timeline();
        
          $.ajax({
            url: 'ressources/ressource_' + id + '.html',
            type: 'GET',
            success: function(data) {
              data_object = $($.parseHTML(data)); 
              $('#ressource .title').text(data_object.find('#title').text());
              $('#ressource .text').html(data_object.find('#text').html().replace(/\n/g, "<br />"));
              $('#ressource').show();
              MathJax.Hub.Queue(["Typeset",MathJax.Hub]);
            },
            error: function(e) {
              console.log(e.message);
            }
          });
      }
      
      function hide_ressource(id)
      {
          $("#ressource").hide();
      }
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
