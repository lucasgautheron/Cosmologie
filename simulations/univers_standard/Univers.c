#include <TMath.h>

#define POINTS 200000

const double o_m0 = 0.315, o_v0 = 0.685, o_r0 = 8.4e-5, o_k0 = 0, H_0 = /*1/(13.9e9)*/1.0/14536650456.5;
const double t[POINTS], a[POINTS];

int Friedmann(const double o_m0, const double o_r0, const double o_v0, const double o_k0, const double eta_0, const int N, double *a, double *t)
{
    double d_eta = eta_0/double(N);
    a[0] = 0;
    t[0] = 0;
   
    for(int i = 0; i < N-1; ++i)
    {
        a[i+1] = a[i] + d_eta * sqrt(o_r0 + o_m0*a[i] + o_k0*a[i]*a[i] + o_v0*a[i]*a[i]*a[i]*a[i]);
    }

    for(int i = 0; i < N-1; ++i)
    {
        t[i+1] = t[i] + a[i]*d_eta;
    }
} 

void Univers()
{
    Friedmann(o_m0, o_r0, o_v0, o_k0, 3.5, POINTS, a, t);

    FILE *fp = fopen("univers.res", "w+");
    
    for(int i = 0; i < POINTS-1; ++i)
    {
        fprintf(fp, "%f %f %f %f\n", t[i]/H_0, a[i], (a[i+1]-a[i])/(t[i+1]-t[i])/a[i], (a[i+1]-a[i])/(t[i+1]-t[i]));
    }

    fclose(fp);
}
