set xlabel 'log(N)'
set ylabel 'log(P)'

set style fill transparent solid 0.2 border
set style data lines

A(x) = a*x+b
B(x) = c*x+d
C(x) = k*x+l

fit [-20:-14] A(x) 'data/fermi_state.res' u (log($4)):(log($5)) via a,b
fit [-25:-18] B(x) 'data/fermi_state.res' u (log($2)):(log($3)) via c,d
fit [6:16] C(x) 'data/fermi_state.res' u (log($4)):(log($5)) via k,l

set label 'Exclusion Pauli forbidden?' at 5,-20 

plot 'data/fermi_state.res' u (log($2)):(log($3)) t 'fermi-dirac' w l lt 1 lc rgb 'black', '' u (log($4)):(log($5)) t 'full degenerate' w filledcurve x1 lt 1

