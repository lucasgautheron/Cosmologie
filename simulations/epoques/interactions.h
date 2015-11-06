struct part
{
    char name[32];
    float mass;
    part(const char *n, float m)
    {
        mass = m;
        sprintf(name, "%s", n);
    }
};
