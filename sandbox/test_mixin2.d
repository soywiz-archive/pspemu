import std.stdio, std.traits;

string func_inline() {
	return q{
		writefln("[2]");
	};
}

void func_called() {
	writefln("[2]");
}

string testFunc(string func) {
	return "
		writefln(\"[1]\");
		static if (is(ReturnType!(" ~ func ~ ") : string)) {
			mixin(" ~ func ~ "());
		} else {
			" ~ func ~ "();
		}
	";
}

void main() {
	mixin(testFunc("func_inline"));
	mixin(testFunc("func_called"));
}