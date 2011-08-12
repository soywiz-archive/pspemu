module pspemu.utils.Logger;

import std.string;
import std.format;
import std.stdio;
import std.conv;

class Logger {
	enum Level : ubyte { TRACE, DEBUG, INFO, WARNING, ERROR, CRITICAL, NONE }

	struct Message {
		uint   time;
		Level  level;
		string component;
		string text;
		
		void _print() {
			stdout.writefln("%-8s: %-10d: '%s'::'%s'", to!string(level), time, component, text);
			stdout.flush();
		}
		
		void print() {
			if (inExclusiveLock) {
				_print();
			} else {
				synchronized (synchronizationObject) _print();
			}
		}
	}
	
	static void exclusiveLock(void delegate() callback) {
		synchronized (synchronizationObject) {
			inExclusiveLock = true;
			scope (exit) inExclusiveLock = false;
			callback();
		}
	}
	
	static bool inExclusiveLock = false;
	
	__gshared Object synchronizationObject;
	static this() {
		synchronizationObject = new Object();
	}

	//__gshared Message[] messages;
	__gshared Level currentLogLevel = Level.NONE;
	__gshared string[] disabledLogComponents;
	__gshared string[] enabledLogComponents;
	
	static public void setLevel(Level level) {
		currentLogLevel = level;
	}
	
	static public void disableLogComponent(string componentToDisable) {
		disabledLogComponents ~= componentToDisable;
	}

	static public void enableLogComponent(string componentToEnable) {
		enabledLogComponents ~= componentToEnable;
		writefln("Enabled: %s", componentToEnable);
	}
	
	static void log(T...)(Level level, string component, T args) {
		if (currentLogLevel == Level.NONE) return;

		foreach (enabledLogComponent; enabledLogComponents) {
			if (component == enabledLogComponent) goto display;
			//writefln("%s, %s", component, enabledLogComponent);
		}
		if (level < currentLogLevel) return;

		if (level <= Level.INFO) {
			foreach (disabledLogComponent; disabledLogComponents) {
				if (component == disabledLogComponent) return;
			}
		}
		
		display:;

		auto message = Message(std.c.time.time(null), level, component, std.string.format(args));
		message.print();
	}
	
	template DebugLogPerComponent(string componentName) {
		void logLevel(T...)(Logger.Level level, T args) {
			Logger.log(level, componentName, args);
		}
		void logLevelOnce(T...)(Logger.Level level, string onceKey, T args) {
			static bool[string] alreadyLogged;
			if (!(onceKey in alreadyLogged)) {
				alreadyLogged[onceKey] = true;
				Logger.log(level, componentName, args);
			}
		}
		mixin Logger.LogPerComponent;	
	}
	
	template LogPerComponent() {
		void logTrace   (T...)(T args) { logLevel(Logger.Level.TRACE   , args); }
		void logDebug   (T...)(T args) { logLevel(Logger.Level.DEBUG   , args); }
		void logInfo    (T...)(T args) { logLevel(Logger.Level.INFO    , args); }
		void logWarning (T...)(T args) { logLevel(Logger.Level.WARNING , args); }
		void logError   (T...)(T args) { logLevel(Logger.Level.ERROR   , args); }
		void logCritical(T...)(T args) { logLevel(Logger.Level.CRITICAL, args); }
		
		void logTraceOnce   (T...)(string onceKey, T args) { logLevelOnce(Logger.Level.TRACE   , onceKey, args); }
		void logDebugOnce   (T...)(string onceKey, T args) { logLevelOnce(Logger.Level.DEBUG   , onceKey, args); }
		void logInfoOnce    (T...)(string onceKey, T args) { logLevelOnce(Logger.Level.INFO    , onceKey, args); }
		void logWarningOnce (T...)(string onceKey, T args) { logLevelOnce(Logger.Level.WARNING , onceKey, args); }
		void logErrorOnce   (T...)(string onceKey, T args) { logLevelOnce(Logger.Level.ERROR   , onceKey, args); }
		void logCriticalOnce(T...)(string onceKey, T args) { logLevelOnce(Logger.Level.CRITICAL, onceKey, args); }
	}
}