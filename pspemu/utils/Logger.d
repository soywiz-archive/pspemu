module pspemu.utils.Logger;

import std.format, std.stdio, std.typecons;

class Logger {
	static mixin(defineEnum!("Level", ubyte, "TRACE", "DEBUG", "INFO", "WARNING", "ERROR", "CRITICAL"));

	struct Message {
		uint   time;
		Level  level;
		string component;
		wstring text;
		void print() {
			.writefln("%-8s: %-10d: '%s'::'%s'", enumToString(level), time, component, text);
		}
	}

	__gshared static Message[] messages;

	static void log(Level level, string component, ...) {
		wstring text;
		void put(dchar c) { text ~= c; }
		std.format.doFormat(&put, _arguments, _argptr);
		auto message = Message(std.c.time.time(null), level, component, text);
		messages ~= message;
		if (level >= Level.WARNING) {
		//if (level >= Level.DEBUG) {
			message.print();
		}
	}
}