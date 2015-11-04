<?php

function extract_columns($columns)
{
    $lines = file('snIa.txt');
    $entries = array();
    $column_numbers = array();
    
    $labels = explode('|', $lines[0]);

    foreach($columns as $n => $column) foreach($labels as $i => $label)
    {
        if(trim($label) == $column)
        {
            $column_numbers[$n] = $i;
        }
    }

    foreach($lines as $k => $line) 
    {
        if($k == 0) continue;
        $data = explode('|', $line);
        $entry = array();
        foreach($column_numbers as $j => $cn)
        {
            $entry[$j] = trim($data[$cn]);
        }
        $entries[$k] = $entry;
    }

    return $entries;
}

$entries = extract_columns(array('redshift', 'sn_mag', 'sn_type', 'sn_qmag', 'sn_gal_uncert', 'sn_mband'));

file_put_contents('sn.res', '');
$count = 0;
foreach($entries as $entry)
{
    if($entry[0] > 0 && $entry[1] > 0 && $entry[2] == 'Ia' && $entry[3] != 'uncertain' && $entry[4] != 'uncertain' && $entry[5] != 'undef')
    {
        ++$count;
        $z = $entry[0];
        $d = 0.0002261568 * pow(10, ($entry[1]+19.3+5)/5)/(1e6);
        file_put_contents('sn.res', "$z $d\n", FILE_APPEND);
    }
}
echo "Entries: $count\n";

?>
