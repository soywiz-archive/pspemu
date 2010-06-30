module pspemu.utils.String;

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

	unittest {
		string[string] map;
		map["test"] = "prueba";
		map["hello"] = "hola";
		map["is"] = "es";
		assert(stringInterpolate("{$hello}, esto {$is} una {$test}", map) == "hola, esto es una prueba");
	}

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

	unittest {
		assert(tos(100) == "100");
		assert(tos(-99) == "-99");
	}
}

//void main() { }
