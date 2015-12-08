<?php
$lines = file('results.txt');
file_put_contents('results.res', '');
foreach($lines as $line)
{
    $data = null;
    preg_match("#\{(?:.*),(.*),(.*),(.*),(.*),(.*)\}#u", $line, $data);
    $x = $data[1];
    $n = str_replace('*^', 'e', $data[2]);
    $P = str_replace('*^', 'e', $data[3]);
    $m = str_replace('*^', 'e', $data[4]);
    $Q = str_replace('*^', 'e', $data[5]);
    file_put_contents('results.res', "$x $n $P $m $Q\n", FILE_APPEND);
}
?>
