#include <math.h>
#include <stdio.h>


double a_dec(double t)
{
    return sqrt(t*t*t)+0.3;
}

double a_acc(double t)
{
    return exp(t/2.5);
}

int calculate(double (*a)(double), double *_x, double *_r, double *_z, double *_t, int n)
{
    double xA = -1;
    double xB = 1;

    double dt = 0.025;
    double x = xA, t = 0;

    for(int i = 0; i < n; ++i)
    {
        _x[i] = _r[i] = _z[i] = _t[i] = 0;
    }

    _x[0] = xA;

    int i = 1;
    while(x < xB)
    {
        if(i >= n) { printf("n is too small :'( %f %d", x, i); return 1; }
        x += dt/a(t);
        t += dt;

        _x[i] = x;
        _r[i] = (x-xA) * a(t);
        _t[i] = t;
        _z[i] = a(t)/a(0) - 1;
        ++i;
    }    
    
}

int main()
{
    const int n = 10000;
    double x_acc[n], r_acc[n], z_acc[n], t_acc[n];
    double x_dec[n], r_dec[n], z_dec[n], t_dec[n];
    calculate(&a_acc, x_acc, r_acc, z_acc, t_acc, n);
    calculate(&a_dec, x_dec, r_dec, z_dec, t_dec, n);
    FILE *fp = fopen("out_acc.res", "w+");
    for(int i = 0; i < n; ++i)
    {
        if(i && t_acc[i] < t_acc[i-1]) break;
        fprintf(fp, "%f %f %f %f\n", t_acc[i], x_acc[i], r_acc[i], z_acc[i]);
    }
    fclose(fp);
    fp = fopen("out_dec.res", "w+");
    for(int i = 0; i < n; ++i)
    {
        if(i && t_dec[i] < t_dec[i-1]) break;
        fprintf(fp, "%f %f %f %f\n", t_dec[i], x_dec[i], r_dec[i], z_dec[i]);
    }
    fclose(fp);
    return 0;
}
