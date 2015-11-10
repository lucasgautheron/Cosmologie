<?php
function strip_decl($str)
{
    return str_replace("<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n", '', $str);
}
// XML
$files[0] = strip_decl(file_get_contents("data/events.xml"));
$files[1] = strip_decl(file_get_contents("data/contents.xml"));
$files[2] = strip_decl(file_get_contents("data/ressources.xml"));

file_put_contents('data/cache', "<?xml version=\"1.0\" encoding=\"UTF-8\"?><root>{$files[0]}{$files[1]}{$files[2]}</root>");
exec('saxonb-xslt -s:data/cache -xsl:layout.xsl -o:output/index.html -ext:on');
/*
$xml_doc = new DOMDocument();
$xml_doc->loadXML("<?xml version=\"1.0\" encoding=\"UTF-8\"?><root>{$files[0]}{$files[1]}{$files[2]}</root>");

// XSL
$xsl_doc = new DOMDocument();
$xsl_doc->load("layout.xsl");

// Proc
$proc = new XSLTProcessor();
$proc->importStylesheet($xsl_doc);
$proc->transformToURI($xml_doc, 'output/index.html');*/
