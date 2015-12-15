set xrange [ 0 : 17500 ]
set yrange [ 0 : 1.5 ]

set xtics 2500

set xlabel 'R (km)'
set ylabel 'M/M_{soleil}'

a = 1.5
b = 5000
f(x) = a*cos(x/b)

fit [0:5000] f(x) 'data/wd_mass_radius.res' u ($2 * 700000):3 via a,b

plot 'data/wd_mass_radius.res' u ($2 * 700000):3 t 'Hydr. Newton' w l
# 'data/wd_mass_radius_relativistic.res' u ($2 * 700000):3 t 'RG' w l lt 2 lc rgb 'black'

