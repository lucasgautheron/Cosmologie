#include <TMath.h>
#include <vector>

struct SN
{
    float d, z, err;
};

#define POINTS 500000
#define ABS(x) ((x) > 0 ? (x) : (-(x))) 

const double o_r0 = 8.4e-5, o_k0 = 0, H_0 = /*1/(13.9e9)*/1.0/14536650456.5; // planck values

int fast_lookup_rev(const double val, const int size, const double *A)
{
    for(int i = size-1; i > 0; --i)
    {
        if(val > A[i]) return i;
    }
    return A[0];
}

int Friedmann(const double o_m0, const double o_r0, const double o_v0, const double o_k0, const double eta_0, const int N, double *a, double *t)
{
    double d_eta = eta_0/double(N);
    a[0] = 0;
    t[0] = 0;
   
    for(int i = 0; i < N-1; ++i)
    {
        a[i+1] = a[i] + d_eta * sqrt(o_r0 + o_m0*a[i] + o_k0*a[i]*a[i] + o_v0*a[i]*a[i]*a[i]*a[i]);
        t[i+1] = t[i] + a[i]*d_eta;
    }
    return 0;
}

double calculate_square(const vector<SN *> &supernovaes, const double o_m0, const double o_v0)
{
    double t[POINTS], a[POINTS];
    Friedmann(o_m0, o_r0, o_v0, o_k0, 3.5, POINTS, a, t);

    int origin = fast_lookup_rev(1.0, POINTS, a);
    
    double d = 0;
    for(unsigned int i = 0; i < supernovaes.size(); ++i)
    {
        SN *sn = supernovaes[i];
        int j = fast_lookup_rev(1.0/(1.0+sn->z), POINTS, a);
        double deta = 3.5 * (origin-j) / double(POINTS);
        double dl = deta*(1+sn->z);
        //d += (sn->d-dl) * (sn->d-dl) / (sn->err * sn->err);
        d += (sn->d-dl) * (sn->d-dl);
    }
    return d;
}

void snIa()
{
    FILE *fp = fopen("sn.res", "r");
    SN tmp;
    std::vector<SN *> supernovaes;
    while(fscanf(fp, "%f %f %f\n", &tmp.z, &tmp.d, &tmp.err) > 0)
    {
        SN *sn = new SN();
        sn->z = tmp.z;
        sn->d = tmp.d;
        sn->err = tmp.err;
        supernovaes.push_back(sn);
        //printf("%f %f\n", tmp.z, tmp.d);
    } 
    fclose(fp);

    //double o_m0_min = 0.25, o_m0_max = 0.30;
    double o_m0_min = 0.2, o_m0_max = 0.35;
    const int tries = 50;

    double min_square = -1;
    double best_m0 = -1;

    fp = fopen("sn_fit.res", "w+");
    for(int i = 0; i < tries; ++i)
    {
        double o_m0 = o_m0_min + (o_m0_max - o_m0_min) * double(i) / double(tries);
        double square = calculate_square(supernovaes, o_m0, 1-o_m0);
        printf("m0=%f square=%f\n", o_m0, square);
        fprintf(fp, "%f %f %f\n", o_m0, square, 100.0 * sqrt(min_square)/double(supernovaes.size()));
        if(best_m0 < 0 || square < min_square)
        {
            best_m0 = o_m0;
            min_square = square;
        }
    }
    fclose(fp);
    
    printf("Best fit: m0=%f square=%f err%%=%f %%\n", best_m0, min_square, 100.0 * sqrt(min_square)/double(supernovaes.size()));

    double t[POINTS], a[POINTS];
    Friedmann(best_m0, o_r0, 1-best_m0, o_k0, 3.5, POINTS, a, t);

    fp = fopen("luminosite.res", "w+");
    int origin = fast_lookup_rev(1.0, POINTS, a);
    for(int i = 0; i < 1000; ++i)
    {
        const double z = 2 * double(i)/1000.0;
        int j = fast_lookup_rev(1.0/(1.0+z), POINTS, a);
        double deta = 3.5 * (origin-j) / double(POINTS);
        double dl = deta*(1+z);
        fprintf(fp, "%f %f %f\n", z, dl, 5*(TMath::Log10(1e6*dl/0.0002261568)-1));
    }
    fclose(fp);
}
