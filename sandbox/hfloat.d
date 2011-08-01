import std.numeric;
import std.stdio;

alias CustomFloat!(10, 5, CustomFloatFlags.ieee) hfloat;

void main() {
	//hfloat value = 0.01111111111111112;
	hfloat value;
	int a, b;
	a = 1811939328;
	b = -7;
	value.fromNormalized(a, b);
	value.toNormalized(a, b);
	//value.fromNormalized(1, 2);
	writefln("%s, %s", a, b);
}