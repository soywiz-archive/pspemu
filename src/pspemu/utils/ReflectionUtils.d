module pspemu.utils.ReflectionUtils;

public import std.traits;

bool isArrayType(alias T)() { return is(typeof(T[0])) && is(typeof(T.sort)); }
bool isPointerType(alias T)() { return is(typeof(*T)) && !isArrayType!(T); }
bool isArrayType(T)() { return is(typeof(T[0])) && is(typeof(T.sort)); }
bool isPointerType(T)() { static if (is(T == void*)) return true; return is(typeof(*T)) && !isArrayType!(T); }
bool isClassType(T)() { return is(T == class); }
bool isString(T)() { return is(T == string); }
string FunctionName(alias f)() { return (&f).stringof[2 .. $]; }
string FunctionName(T)() { return T.stringof[2 .. $]; }
string stringOf(T)() { return T.stringof; }