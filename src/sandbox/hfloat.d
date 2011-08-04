import std.numeric;
import std.stdio;

alias CustomFloat!(10, 5, CustomFloatFlags.ieee) hfloat;

/*
0b0010000110110000
0.011108
*/
void main() {
	//hfloat value = 0.01111111111111112;
	hfloat value;
	value.significand = 0b0110110000;
	value.exponent = 0b01000;
	value.sign = 0b0;
	//value.fromNormalized(a, b);
	//value.toNormalized(a, b);
	//value.fromNormalized(1, 2);
	writefln("%f", value);
}