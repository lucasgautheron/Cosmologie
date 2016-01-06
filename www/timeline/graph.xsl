<xsl:stylesheet version="2.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:doc="http://sciencestechniques.fr"
    exclude-result-prefixes="xs doc">

    <xsl:template match="/">
        <html>
            <head>
                <title>Structure</title>
                <meta charset="utf-8" />
            </head>
            <body>
                <ul>
                    <xsl:for-each select="root/contents/content">
                        <xsl:variable name="id" select="./@id"/>
                        <xsl:variable name="text" select="./text"/>
                        <li><h3><a href="index.html#/content/{$id}"><xsl:value-of select="./title" /></a></h3><br />
                            <h4>Evènements</h4>
                            <ul>
                                <xsl:for-each select="//root/events/event[@content-id=$id]">
                                    <li><xsl:value-of select="."/></li>
                                </xsl:for-each>
                            </ul>
                            <h4>Ressources</h4>
                            <ul>
                                <xsl:for-each select="//ressources/ressource/linkwords/linkword[contains($text, .)]">
                                    <li><a href="index.html#/html/content/{$id}/ressource/{../../@id}"><xsl:value-of select="."/></a></li>
                                </xsl:for-each>
                            </ul>
                            <h4>Références</h4>
                            <ul>
                                <xsl:for-each select="//root/references/reference[@content-id=$id]">
                                    <li><xsl:value-of select="./title"/></li>
                                </xsl:for-each>
                            </ul>
                        </li>
                    </xsl:for-each>
                </ul>
            </body>
        </html>
    </xsl:template>
</xsl:stylesheet>
