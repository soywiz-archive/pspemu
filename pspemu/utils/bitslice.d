module pspemu.utils.bitslice;

import std.conv;

string bitslice(string v, T, string name, uint start, uint count, bool asserts = false)() {
	string r;
	bool signed = (T.min < 0);

	static if (T.min < 0) {
		long  minVal = -(1uL << (count - 1));
		ulong maxVal = (1uL << (count - 1)) - 1;
	} else {
		ulong minVal = 0;
		ulong maxVal = (1uL << count) - 1;
	}
	
	auto mask = (1 << count) - 1;

	// Getter
	{
		r ~= T.stringof ~ " " ~ name ~ "() {";
		{
			//static if (is(T == bool))
			r ~= "" ~ T.stringof ~ " result = (" ~ v ~ " >> " ~ to!string(start) ~ ") & " ~ to!string(mask) ~ ";";
			if (signed) {
				r ~= "if (result & " ~ to!string(1 << (count - 1)) ~ ") result |= ~(" ~ to!string(mask) ~ ");";
			}
			r ~= "return result;";
		}
		r ~= "}";
	}
	// Setter
	{
		r ~= "void " ~ name ~ "(" ~ T.stringof ~ " ___v) {";
		{
			if (asserts) {
				r ~= "assert(___v >= " ~ to!string(minVal) ~ ");";
				r ~= "assert(___v <= " ~ to!string(maxVal) ~ ");";
				r ~= v ~ " = (" ~ v ~ " & ~" ~ to!string(mask << start) ~ ") | (___v << " ~ to!string(start) ~ ");";
			} else {
				r ~= v ~ " = (" ~ v ~ " & ~" ~ to!string(mask << start) ~ ") | ((___v & " ~ to!string(mask) ~ ") << " ~ to!string(start) ~ ");";
			}
		}
		r ~= "}";
	}
	return r;
}