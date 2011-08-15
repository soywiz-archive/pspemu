module pspemu.utils.TraitsUtils;

public import std.traits;
import std.string;

bool isArrayType(alias T)() { return is(typeof(T[0])) && is(typeof(T.sort)); }
bool isPointerType(alias T)() { return is(typeof(*T)) && !isArrayType!(T); }
bool isArrayType(T)() { return is(typeof(T[0])) && is(typeof(T.sort)); }
bool isPointerType(T)() { static if (is(T == void*)) return true; return is(typeof(*T)) && !isArrayType!(T); }
bool isClassType(T)() { return is(T == class); }
bool isString(T)() { return is(T == string); }
string FunctionName(alias f)() { return (&f).stringof[2 .. $]; }
string FunctionName(T)() { return T.stringof[2 .. $]; }
string stringOf(T)() { return T.stringof; }

static string classInfoBaseName(ClassInfo ci) {
	auto index = ci.name.lastIndexOf('.');
	if (index == -1) index = 0; else index++;
	return ci.name[index..$];
}
