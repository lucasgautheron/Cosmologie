<?php

function skip($h, $n, $off)
{
    for($i = 0; $i < $off; ++$i)
    {
        $h = substr($h, strpos($h, $n)+1);
    }
    return $h;
}

function extract_columns(&$columns, $file, $length)
{
    $fp = fopen($file, 'r');
    $index = 0;
    $z = 0;
    $mu = 0;
    $dmu = 0;
    while($cols = fgetcsv($fp, 1024, ","))
    {
        if(empty($cols[0])) continue;
        $pm_count = substr_count($cols[0], "±");
        if($pm_count > 1)
        {
            $index += $pm_count-1;
            $cols[0] = trim(skip($cols[0], " ", 4*($pm_count-1)));
echo $cols[0] . "\n";
        }
        if($index == 1) $z = $cols[0];
        if($index == 6)
        {
            $mu = (float)$cols[0];
            $dmu = trim(substr($cols[0], strpos($cols[0], "±")+2));
        }
        if($index >= $length-1)
        {
            $index = 0;
            $columns[] = array($z, $mu, $dmu);
        }
        else ++$index;
    } 
}

$columns = array();
extract_columns($columns, 'sn_data1.csv', 8);
extract_columns($columns, 'sn_data2.csv', 7);

file_put_contents('sn_raw.res', '');
file_put_contents('sn.res', '');
foreach($columns as $column)
{
    $z = $column[0];
    $d = 0.0002261568 * pow(10, ($column[1]+5)/5)/(1e6);
    $dd = (log(10)/5) * $d * $column[2];
    file_put_contents('sn_raw.res', "$z {$column[1]} {$column[2]}\n", FILE_APPEND);
    file_put_contents('sn.res', "$z $d $dd\n", FILE_APPEND);
}
?>
