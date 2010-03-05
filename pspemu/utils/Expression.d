module pspemu.utils.Expression;

import std.stdio, std.string;

static long parseStringBaseUnsigned(string s, int base) {
	long r;
	foreach (position, c; s) {
		int digit = void;
		if (c == '_') continue; // Ignore. For separator as in D.
			 if (c >= '0' && c <= '9') digit = 0 + (c - '0');
		else if (c >= 'a' && c <= 'z') digit = 10 + (c - 'a');
		else if (c >= 'A' && c <= 'Z') digit = 10 + (c - 'A');
		else assert(0, format("Invalid Digit '%s'", c));
		r *= base;
		r += digit;
	}
	return r;
}

static long parseString(string s, long default_value = 0) {
	if (s.length > 0) {
		try {
			switch (s[0]) {
				case '-': return -parseString(s[1..$]);
				case '+': return +parseString(s[1..$]);
				case '0':
					if (s.length > 1) {
						switch (s[1]) {
							case 'b': return parseStringBaseUnsigned(s[2..$], 2);
							case 'x': return parseStringBaseUnsigned(s[2..$], 16);
							default:  return parseStringBaseUnsigned(s[1..$], 8);
						}
					}
				break;
				default:
					return parseStringBaseUnsigned(s, 10);
				break;
			}
		} catch {
		}
	}
	return default_value;
}

unittest {
	writefln("Unittesting: " ~ __FILE__ ~ "...");

	assert(parseString("0x_000F") == 0x_000F);
	assert(parseString("-0x05") == -0x05);
	assert(parseString("0b001") == 0b001);
	assert(parseString("+017") == +017);
}
