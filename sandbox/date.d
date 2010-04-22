import std.stdio, std.date;

void main() {
	writefln("%d", std.date.parse("2009-07-02"));
	writefln("%d", std.date.parse("2009-07-03"));
	writefln("%d", getUTCtime);
	//writefln("%s", toUTCString(getUTCtime));
}