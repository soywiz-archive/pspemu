// D import file generated from 'src\core\math.d'
module core.math;
version (LDC)
{
    public import ldc.intrinsics;

}
public 
{
    pure nothrow @safe real cos(real x);
    pure nothrow @safe real sin(real x);
    pure nothrow @safe long rndtol(real x);
    extern (C) real rndtonl(real x);

    nothrow pure @safe 
{
    float sqrt(float x);
    double sqrt(double x);
    real sqrt(real x);
}
    pure nothrow @safe real ldexp(real n, int exp);
        pure nothrow @safe real fabs(real x);
    pure nothrow @safe real rint(real x);
    pure nothrow @safe real yl2x(real x, real y);
    pure nothrow @safe real yl2xp1(real x, real y);
    }
