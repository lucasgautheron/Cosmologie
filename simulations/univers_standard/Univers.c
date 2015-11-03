#include <TMath.h>

#define POINTS 200000
#define ABS(x) ((x) > 0 ? (x) : (-(x))) 

const double o_m0 = 0.315, o_v0 = 0.685, o_r0 = 8.4e-5, o_k0 = 1-o_m0-o_v0-o_r0, H_0 = /*1/(13.9e9)*/1.0/14536650456.5; // planck values
//const double o_m0 = 0.315, o_v0 = 0.685, o_r0 = 8.4e-5, o_k0 = -0.1, H_0 = /*1/(13.9e9)*/1.0/14536650456.5; // planck values
const double t[POINTS], a[POINTS];

int lookup(const double val, const int size, const double *A)
{
    double dist = -1;
    int closest = -1;
    for(int i = 0; i < size; ++i)
    {
        if(ABS(val-A[i]) < dist || closest < 0)
        {
            dist = ABS(val-A[i]);
            closest = i;
        }
    }
    return closest;
}

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
    return 0;
}

int d_eta_z(const double z, double *a, double *t, const int N, double t0)
{
    int eta_0 = lookup(t0, N, t);
    double a0 = a[eta_0];
    double ae = a0/(1+z);
    int eta_e = lookup(ae, N, a);
    //double te = t[eta_e];
    //printf("%.3f\n", t[eta_e]/H_0);
    return eta_0 - eta_e;
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

    double t0 = t[lookup(1.0, POINTS, a)];
    printf("Age univers: %f Ga\n", 1e-9 * t0/H_0);

    fp = fopen("luminosite.res", "w+");
    for(int i = 0; i < 50; ++i)
    {
        const double z = 1 * double(i)/50.0;
        double deta = 3.5 * d_eta_z(z, a, t, POINTS, t0) / double(POINTS);
        //printf("z = %.2f: dn = %f (%f)\n", z, 1e-9 * deta/H_0, deta*(1+z));
        fprintf(fp, "%.2f %f %f %f %f %f %f\n", z, deta*(1+z), deta/(1+z), TMath::SinH(deta)*(1+z), TMath::SinH(deta)/(1+z), TMath::Sin(deta)*(1+z), TMath::Sin(deta)/(1+z));
    }
    fclose(fp);
    
}
