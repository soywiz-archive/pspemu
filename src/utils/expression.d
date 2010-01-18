module pspemu.utils.expression;

import std.stdio, std.string;

static long parseStringBaseUnsigned(string s, int base) {
	long r;
	foreach (c; s) {
		int digit = void;
			 if (c >= '0' && c <= '9') digit = 0 + (c - '0');
		else if (c >= 'a' && c <= 'z') digit = 10 + (c - 'a');
		else if (c >= 'A' && c <= 'Z') digit = 10 + (c - 'A');
		else assert(0, format("Invalid Digit '%c'", c));
		r *= base;
		r += digit;
	}
	return r;
}

static long parseString(string s) {
	long v = 0;
	if (s.length > 0) {
		switch (s[0]) {
			case '-':
				return -parseString(s[1..$]);
			break;
			case '0':
				if (s.length > 1) {
					switch (s[1]) {
						case 'b': return parseStringBaseUnsigned(s[2..$], 2);
						case 'x': return parseStringBaseUnsigned(s[2..$], 16);
						default:  return parseStringBaseUnsigned(s[2..$], 8);
					}
				}
			break;
			default:
				return parseStringBaseUnsigned(s, 10);
			break;
		}
	}
	return v;
}

unittest {
	writefln("Unittesting: utils.expression...");

	assert(parseString("-0x05") == -0x05);
}
