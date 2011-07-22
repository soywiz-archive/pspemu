import std.demangle;
import std.stdio;

int main(string[] args) {
	foreach (arg; args) {
		writefln("%s", demangle(arg));
	}
	return 0;
}