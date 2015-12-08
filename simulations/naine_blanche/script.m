Clear[n]
Clear[P]
Clear[m]
Clear[Q]

Remove[f]
Remove[g]
Remove[h]
n[x_?NumericQ] := NIntegrate [ u * (u^2-1)^(1/2) / (Exp[u*x]+1), {u,1,+Infinity} ]
P[x_?NumericQ] := NIntegrate [ (u^2-1)^(3/2) / (Exp[u*x]+1), {u,1,+Infinity} ]

m[x_?NumericQ] := NIntegrate [ u * (u^2-1)^(1/2), {u,1,1+x*x} ]
Q[x_?NumericQ] := NIntegrate [ (u^2-1)^(3/2), {u,1,1+x*x} ]

SetAttributes[n, Listable];
SetAttributes[P, Listable];

f[x_] := x/2500
g[x_] := 1 + x/250
h[x_] := 20 + x/2500

Do [ Print[{ i, N[f[i]], n[f[i]], P[f[i]], m[f[i]], Q[f[i]] } ], {i, 2500} ]
Do [ Print[{ i, N[g[i]], n[g[i]], P[g[i]], m[g[i]], Q[g[i]] } ], {i, 5000} ]
Do [ Print[{ i, N[h[i]], n[h[i]], P[h[i]], m[h[i]], Q[h[i]] } ], {i, 2500} ]
