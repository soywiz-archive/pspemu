module tango_d1;

import tango.io.Stdout;
import tango.util.Convert;

alias char[] string;

static string tos(T)(T v, int base = 16) {
//static string tos(int base = 16, T)(T v) {
	string r;
	const string table = "0123456789abcdef";
	assert(base <= table.length, "Base should be less than or equals to 16.");

	if (v == 0) return "0";
	bool sign = (v < 0);
	if (sign) v = -v;
	while (v > 0) {
		r = table[(v % base)] ~ r;
		v /= base;
	}
	if (sign) r = "-" ~ r;
	return r;
}

static string bitslice(string source, string type, string name, int bitStart, int bitEnd) {
	string r;
	//string bitMask = "(1 << (" ~ bitEnd ~ " - " ~ bitStart ~ ") - 1)";
	string bitMask = tos(1 << (bitEnd - bitStart) - 1);

	// All the shifting stuff should be resolved at compile time by the optimizer.
	r ~= type ~ " " ~ name ~ "() {\n";
		r ~= "\treturn cast(" ~ type ~ ")((" ~ source ~ " >> " ~ tos(bitStart) ~ ") & " ~ bitMask ~ ");\n";
	r ~= "}\n";

	r ~= type ~ " " ~ name ~ "(" ~ type ~ " __value) {\n";
		// Clean bits.
		r ~= "\t" ~ source ~ " &= ~(" ~ bitMask ~ "<< " ~ tos(bitStart) ~ ");\n";
		r ~= "\t" ~ source ~ " |= (__value & " ~ bitMask ~ ") << " ~ tos(bitStart) ~ ";\n";
		r ~= "\treturn cast(" ~ type ~ ")cast(int)(__value & " ~ bitMask ~ ");\n";
	r ~= "}\n";

	return r;
}

unittest {
	struct Test {
		uint data;

		mixin(bitslice("data", "bool", "slice1", 0, 1));
	}
	Test test;
	test.slice1 = 1;
	assert(test.slice1 == 1);
}

//pragma(msg, bitslice("data", "bool", "slice1", 0, 1));

void main() {
}