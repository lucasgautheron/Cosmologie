<?php
function strip_decl($str)
{
    return str_replace("<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n", '', $str);
}
// XML
$files[0] = strip_decl(file_get_contents("data/events.xml"));
$files[1] = strip_decl(file_get_contents("data/contents.xml"));
$files[2] = strip_decl(file_get_contents("data/ressources.xml"));
$files[3] = strip_decl(file_get_contents("data/references.xml"));

file_put_contents('data/cache', "<?xml version=\"1.0\" encoding=\"UTF-8\"?><root>{$files[0]}{$files[1]}{$files[2]}{$files[3]}</root>");

$start_time = microtime(true);
exec('saxonb-xslt -s:data/cache -xsl:layout.xsl -o:output/index.html -ext:on');
echo "generation done (" . round(microtime(true) - $start_time, 4) . " s)\n";
