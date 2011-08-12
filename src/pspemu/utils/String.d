module pspemu.utils.String;

public import std.conv;
import std.traits;
import std.ascii;
import std.c.stdio;
import std.stdio;

string DString(string cArray, string dString) {
	string str;
	str ~= "@property void " ~ dString ~ "(string value) { " ~ cArray ~ "[0..value.length] = value[0..$]; " ~ cArray ~ "[value.length..$] = 0; }";
	str ~= "@property string " ~ dString ~ "() { return std.conv.to!string(" ~ cArray ~ ".ptr); }";
	return str;
}

void setFixedStringz(char[] dest, string value) {
	dest[0..value.length] = value[0..$];
	dest[value.length..$] = 0;
}

void dumpHex(ubyte[] data, uint ptr = 0) {
	while (data.length) {
		printf("%08X ", ptr);
		for (int n = 0; n < 0x10; n++) writef(" %02X", data[n]);
		printf("  ");
		for (int n = 0; n < 0x10; n++) {
			char c = cast(char)data[n];
			if (c < 0x20) c = '.';
			//if (c > 0x7F) c = '.';
			printf("%c", c);
		}
		printf("\n");
		data = data[0x10..$];
		ptr += 0x10;
	}
}

string toSet(T)(T v) {
	string r;
    foreach (i, e; EnumMembers!T)
    {
        if (v & e) {
        	if (r.length > 0) r ~= " | ";
            r ~= __traits(allMembers, T)[i];
        }
    }
	return r;
}

T[] ltrim(T)(T[] array, T valueToRemove) {
	foreach (index, value; array) if (value != valueToRemove) return array[index..$];
	return [];
}

string ltrim_str(string array, char valueToRemove) {
	return cast(string)ltrim(cast(char[])array, valueToRemove);
}

T[] rtrim(T)(T[] array, T valueToRemove) {
	foreach_reverse (index, value; array) if (value != valueToRemove) return array[0..index + 1];
	return [];
}

string rtrim_str(string array, char valueToRemove) {
	return cast(string)rtrim(cast(char[])array, valueToRemove);
}

string stringInterpolate2(string base, char[] chars, string[] map) {
	string r;
	assert(chars.length == map.length);
	for (int n = 0; n < base.length; n++) {
		char c = base[n];
		if (isAlphaNum(c)) {
			if (
				((n == 0) || !isAlphaNum(base[n - 1])) &&
				((n == base.length - 1) || !isAlphaNum(base[n + 1]))
			) {
				bool found = false;
				foreach (k, c2; chars) {
					if (c2 == c) {
						found = true;
						r ~= map[k];
						break;
					}
				}
				if (found) continue;
			}
		}
		r ~= c;
	}
	return r;
}

static pure nothrow {
	string stringInterpolate(string base, string[string] map) {
		string r;
		for (int n = 0; n < base.length; n++) {
			if (base[n] == '{') {
				if (base[n + 1] == '$') {
					int m = n + 2;
					for (n = m; n < base.length; n++) if (base[n] == '}') break;
					r ~= map[base[m..n]];
					continue;
				}
			}
			r ~= base[n];
		}
		return r;
	}

	/*
	unittest {
		string[string] map;
		map["test"] = "prueba";
		map["hello"] = "hola";
		map["is"] = "es";
		assert(stringInterpolate("{$hello}, esto {$is} una {$test}", map) == "hola, esto es una prueba");
	}
	*/

	string tos(T)(T v, int base = 10, int pad = 0) {
		if (v == 0) return "0";
		const digits = "0123456789abcdef";
		assert(base <= digits.length);
		string r;
		long vv = cast(long)v;
		bool sign = (vv < 0);
		if (sign) vv = -vv;
		while (vv != 0) {
			r = digits[cast(uint)(vv) % base] ~ r;
			vv /= base;
		}
		while (r.length < pad) r = '0' ~ r;
		if (sign) r = "-" ~ r;
		return r;
	}

	/*
	unittest {
		assert(tos(100) == "100");
		assert(tos(-99) == "-99");
	}
	*/
}

//void main() { }
