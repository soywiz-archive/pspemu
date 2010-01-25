import std.stdio;

string testFunc2() {
	return q{
		writefln("[2]");
	};
}

string testFunc() {
	return q{
		writefln("[1]");
		mixin(testFunc2);
	};
}

void main() {
	mixin(testFunc);
}