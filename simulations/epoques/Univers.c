#include <TMath.h>
#include <vector>
#include <cstdio>
#include <string>
#include "interactions.h"

#define POINTS 5000
#define ABS(x) ((x) > 0 ? (x) : (-(x)))
#define C_BOLTZMANN (1.38064852e-23)
#define C_EV (1.60217662e-19)

const double o_m0 = 0.315, o_v0 = 0.685, o_r0 = 8.4e-5, o_k0 = 1-o_m0-o_v0-o_r0, H_0 = /*1/(13.9e9)*/1.0/14536650456.5; // planck values
//const double o_m0 = 0.315, o_v0 = 0.685, o_r0 = 8.4e-5, o_k0 = -0.1, H_0 = /*1/(13.9e9)*/1.0/14536650456.5; // planck values
const double t[POINTS], a[POINTS];

std::vector<part *> particles;

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

int fast_lookup_rev(const double val, const int size, const double *A)
{
    for(int i = size-1; i > 0; --i)
    {
        if(val > A[i]) return i;
    }
    return A[0];
}

int Friedmann(const double o_m0, const double o_r0, const double o_v0, const double o_k0, const double eta_0, const int N, double *a, double *t, const int offset = 0)
{
    double d_eta = eta_0/double(N);
   
    for(int i = 0; i < N-1; ++i)
    {
        a[offset+i+1] = a[i] + d_eta * sqrt(o_r0 + o_m0*a[i] + o_k0*a[i]*a[i] + o_v0*a[i]*a[i]*a[i]*a[i]);
        t[offset+i+1] = t[i] + a[i]*d_eta;
    }
    return 0;
}

int d_eta_z(const double z, const double *a, const double *t, const int N, const double t0)
{
    int eta_0 = lookup(t0, N, t);
    double a0 = a[eta_0];
    double ae = a0/(1+z);
    int eta_e = lookup(ae, N, a);
    //double te = t[eta_e];
    //printf("%.3f\n", t[eta_e]/H_0);
    return eta_0 - eta_e;
}

double a_temperature(double a)
{
    return 2.7/a;
}

double a_energy(double a)
{
    return C_BOLTZMANN * 2.7/a/C_EV;
}

void bind_particles()
{
    part *el = new part("el", 0.511e6);
    part *proton = new part("proton", 0.9e9);
    part *Z = new part("Z", 90e9);
    particles.push_back(el);
    particles.push_back(proton);
    particles.push_back(Z);
}

void Univers()
{
    // split eras

    bind_particles();

    double a[POINTS*5], t[POINTS*5];
    a[0] = t[0] = 0;
    Friedmann(o_m0, o_r0, o_v0, 0, 0.01, POINTS, a, t);
    Friedmann(o_m0, o_r0, o_v0, 0, 0.1, POINTS, a, t, POINTS-1);

    for(int i = 0; i < particles.size(); ++i)
    {
        part *p = particles[i];
        for(int j = 0; j < POINTS*2; ++j)
        {
            printf("%f\n", t[j]);
            double e = a_energy(a[j]);
            if(e<p->mass)
            {
                printf("freeze %s (T=%f eV, t=%f)\n", p->name, p->mass, t[j]);
                break;
            }
        }
    }
}
