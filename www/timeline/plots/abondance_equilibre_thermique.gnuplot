set yrange [-5:3.5]
set size ratio 1.4

set xlabel 'A'
set ylabel 'log(n)'

set fit quiet

E(x) = k*x+p
fit E(x) 'data/noyaux_energies.res' u 1:3 via k, p
A(x) = a*E(x) - b
fit [0:80] A(x) 'data/noyaux_abondances.res' u 1:2 via a,b

plot 'data/noyaux_abondances.res' u 1:2 t 'Exp. (Brown 1949)' lc rgb 'red', A(x) t 'Fit Boltzmann' lt 1 lc rgb 'black'

