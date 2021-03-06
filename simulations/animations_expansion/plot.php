<?php
$type = "acc";

function ticks($min, $max, $count, $round)
{
    $delta = ($max-$min)/$count;
    $delta /= $round;
    $delta = ceil($delta);
    return $delta * $round;
}

$lines = file_get_contents("out_$type.res");

$data = array();
preg_match_all("#(.*) (.*) (.*) (.*) (.*)\n#u", $lines, $data);

$lines = array();
foreach($data[0] as $n => $line)
{
    $lines[] = array($data[1][$n], $data[2][$n], $data[3][$n], $data[4][$n]);
    $max_ratio = 1+$data[4][$n];
    $max_time = $data[1][$n];
    $max_dl = (1+$data[4][$n])*$data[3][$n];
    $max_x = $data[2][$n];
}

foreach($lines as $n => $line)
{
    /*$skip = $n && $n < count($lines)-1 && $n%2;
    if($skip) continue;*/
    $index = sprintf("%04d", $n);
    $min_x = -1.5 * $max_ratio / (1+$line[3]);
    $max_x = 1.5 * $max_ratio / (1+$line[3]);
    $min_y = -1.5 * $max_ratio / (1+$line[3]);
    $max_y = 1.5 * $max_ratio / (1+$line[3]);
    //$code = "set term svg enhanced dynamic dashed font 'DejaVuSerif,14'; set out 'files/$index.svg'; \n";
    $code = "set term pngcairo enhanced font 'DejaVuSerif,14'  size 640,1280; set out 'files/$index.png';\n";
    $xtics = 0.5 * $max_ratio / 6;
    $xtics = round($xtics*10)/10;
    $code .= "set size 2,1
set multiplot layout 3, 1
";
    $code .= "
set title  sprintf(\"t=%.2f, z=%.2f\",{$line[0]},{$line[3]})
set lmargin at screen 0.15
set rmargin at screen 0.85
set bmargin at screen 0.50
set tmargin at screen 0.85

unset key
set xrange [ $min_x:$max_x ]
 set yrange [ $min_y : $max_y ]
set grid xtics ytics
set xtics $xtics
set xtics format ' '
set ytics format ' '
set ytics $xtics

set samples 1000
set object 1 circle at first -1,0 size 0.05
set object 2 circle at first 1,0 size 0.05
set obj 10 circle at first -1, 0 size first (1+{$line[1]}) fc rgb 'red'

plot 'out_$type.res' u ($2):($1 <= {$line[0]}+0.01 ? 0 : NaN) w l lt 1 lw 1.5
";
    $xtics = ticks(0, $max_time, 5, 0.25);
    $ytics = ticks(0, 1, 5, 0.5);
    $code .= "
set lmargin at screen 0.1
set rmargin at screen 0.9
set bmargin at screen 0.3
set tmargin at screen 0.4

    unset title
    unset key
    unset grid
    unset xtics
    unset ytics
    set xtics format '%.1f'
    set ytics format '%.1f'
    unset object 1
    unset object 2
    unset object 10
    set ytics -1,$ytics,1
    set xtics 0,$xtics,$max_time
    set xrange [ 0:$max_time ]
    set yrange [ -1:1 ]
plot 'out_$type.res' u 1:($1 <= {$line[0]}+0.01 ? ($2) : NaN) w l 
";

    $xtics = ticks(0, $max_time, 5, 0.25);

    $ytics = ticks(0, $max_dl, 5, 25);
    $code .= "
set lmargin at screen 0.1
set rmargin at screen 0.9
set bmargin at screen 0.1
set tmargin at screen 0.2

    unset title
    unset key
    unset grid
    unset xtics
    unset ytics
    set xtics format '%.1f'
    set ytics format '%.1f'
    unset object 1
    unset object 2
    set ytics 0,$ytics,$max_dl
    set xtics 0,$xtics,$max_time
    set xrange [ 0:$max_time ]
    set yrange [ 0:$max_dl ]
plot 'out_$type.res' u 1:($1 <= {$line[0]}+0.01 ? ((1+$4)*$3) : NaN) w l t 'd_L(z)'
";

    $code .= "
unset multiplot";
    file_put_contents('tmp', $code);
    exec('gnuplot tmp');
}
?>
