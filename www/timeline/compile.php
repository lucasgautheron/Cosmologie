<?php
$output = array();
$return_code = $return = 0;

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
exec('saxonb-xslt -s:data/cache -xsl:layout.xsl -o:output/index.html -ext:on', $output, $return_code);
$return |= $return_code;
echo "HTML generation completed (" . round(microtime(true) - $start_time, 4) . " s)\n";

$start_time = microtime(true);
exec('saxonb-xslt -s:data/cache -xsl:graph.xsl -o:output/graph.html -ext:on', $output, $return_code);
$return |= $return_code;
echo "graph generation completed (" . round(microtime(true) - $start_time, 4) . " s)\n";

// gnuplot
$start_time = microtime(true);
chdir('plots/');
$plots = glob("*.gnuplot");
foreach($plots as $plot)
{
    $plot = preg_replace('/\\.(gnuplot)/', '', $plot);
    file_put_contents("tmp", "set term svg enhanced dashed font 'DejaVuSerif,14'; set out '../images/$plot.svg'; \n" . file_get_contents("$plot.gnuplot"));
    exec('gnuplot tmp', $output, $return_code);
    $return |= $return_code;
}
if(is_file('tmp')) unlink('tmp');
echo "plot generation completed (" . round(microtime(true) - $start_time, 4) . " s)\n";

exit((int)$return);
