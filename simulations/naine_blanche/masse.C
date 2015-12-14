#include <stdio.h>
#include <math.h>

#define PI 3.141592654

#define max(a,b) ((a)>(b)? (a) : (b))

double pressure(double x)
{
    double root = pow(x, 1.0/3.0);
    return (3.0/8.0) * log(root + sqrt(root*root+1)) + sqrt(1+root*root) * (0.25 * x - (3.0/8.0) * root); 
}

double dpressure(double x)
{
    return pow(x, 2.0/3.0)/(3.0*sqrt( 1 + pow(x, 2.0/3.0) ));
}

double find_x_from_pressure(double p, double x0 = 1)
{
    const double max_error = 1e-10;
    const int max_iterations = 10000;
    
    double x = x0, x1 = x0, error = max_error+1;
    
    int i = 0;
    while (error > max_error && i < max_iterations)
    {
        x1 = x - (pressure(x)-p)/(dpressure(x));
        error = fabs(x1-x);
        x = x1;
        ++i;
    }
    return x;
}

const double mu = 2;

const double alpha = 0.00018181636;
const double beta = 499699.060742;
const double r = 0.00000424425; // r scharw / r sun

const double dchi = 0.00000005;
const int steps = 2500000;

bool calculate_star(const double x0, double &radius, double &mass)
{
    double x[2], m[2], p[2], chi[2];
    
    // initialisation
    for(int i = 0; i < 2; ++i)
    {
        x[i] = m[i] = p[i] = chi[i] = 0;
    }
    
    // conditions aux limites
    m[0] = 0;
    x[0] = x0;
    p[0] = pressure(x[0]);
    
    FILE *fp = fopen("masse.res", "w+");
    
    bool converged = false;
    for(int i = 1; i < steps; ++i)
    {
        double _dchi = max(dchi, chi[1]/50000);
        //chi[1] = double(i) * dchi;
        chi[1] += _dchi;
        double dm = _dchi * (4.0/3.0) * PI * mu * beta * chi[1] * chi[1] * x[0];
        m[1] = m[0] + dm;
        p[1] = p[0] - _dchi * (r/(2*alpha*chi[1]*chi[1])) * (mu * x[0] /3.0 + alpha * p[0]) * (m[0] + 4*PI*alpha * beta * chi[1]*chi[1]*chi[1]*p[0]) / (1-r/chi[1]);
        x[1] = find_x_from_pressure(p[1], x[0]);
        
        if(p[1] < 0) 
        {
            mass = m[0];
            radius = chi[1];
            
            converged = true;
            break;
        }
        
        fprintf(fp, "%f %f %f %f\n", chi[1], m[1], p[1], x[1]);
        m[0] = m[1];
        p[0] = p[1];
        x[0] = x[1];
    }
    
    if(!converged) printf("DID NOT CONVERGE : ADD MORE STEPS");
    
    fclose(fp);
}


int main()
{
    FILE *fp = fopen("masse_rayon.res", "w+");
    const int N = 250;
    
    for(int i = 0; i < N; ++i)
    {
        double radius, mass;
        double x0 = pow(10, 2+4.5*double(i)/double(N));
        
        calculate_star(x0, radius, mass);
        printf("%d / %d done.\n", i+1, N);
        fprintf(fp, "%f %f %f\n", x0, radius, mass);
    }
    fclose(fp);
    return 0;
}
