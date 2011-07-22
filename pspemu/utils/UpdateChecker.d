module pspemu.utils.UpdateChecker;

import pspemu.utils.SvnVersion;
import std.windows.registry;
import dfl.internal.winapi;
import core.thread;
import std.datetime;
import std.stdio;

class UpdateChecker {
	protected __gshared {
		Key key;
		int lastestVersion;
		int currentVersion;
		void delegate(bool) callbackResult;
	}

	static this() {
		key = std.windows.registry.Registry
			.currentUser()
			.createKey("Software")
			.createKey("Soywiz")
			.createKey("Pspemu")
		;
	}
	
	public static void tryCheckBackground(void delegate(bool) callbackResult = null, bool force = false) {
		UpdateChecker.callbackResult = callbackResult;
		Thread thread = new Thread({
			bool result;
			if (force) {
				result = checkForUpdates();
			} else {
				result = tryCheckForUpdates();
			}
			if (!(UpdateChecker.callbackResult is null)) {
				callbackResult(result);
			}
		});
		thread.name = "UpdateChecker";
		thread.start();
	}
	
	public static bool tryCheckForUpdates() {
		try {
			SysTime sysTime = std.conv.to!long(key.getValue("lastCheckDate").value_EXPAND_SZ);
			Duration elapsedSinceLastCheck = Clock.currTime() - sysTime;
			writefln("Since last check for update: %s", elapsedSinceLastCheck);
			if (elapsedSinceLastCheck >= dur!"days"(2)) {
			//if (elapsedSinceLastCheck >= dur!"minutes"(30)) {
				return checkForUpdates();
			}
		} catch (RegistryException) {
			// Not setted yet yet.
			setCheckDateToNow();
		}
		return false;
	}
	
	public static bool isANewerVersionAvailable() {
		currentVersion = SvnVersion.revision;
		lastestVersion = SvnVersion.getLastOnlineVersion;
		return (lastestVersion > currentVersion);
	}
	
	protected static bool checkForUpdates() {
		writefln("Checking for updates...");
		
		bool _isANewerVersionAvailable = isANewerVersionAvailable();
		scope (exit) setCheckDateToNow();
		
		writefln("  Current: %d, Online: %d", currentVersion, lastestVersion);
		
		if (_isANewerVersionAvailable) {
			writefln("    There is a new version!");
			string str = std.string.format(
				"You have version %d\n"
				"And there is a new version %d\n"
				"\n" 
				"Would you like to download it?"
			, currentVersion ,lastestVersion);
			
			if (MessageBoxA(null, "New Version!", std.string.toStringz(str), MB_YESNO | MB_ICONASTERISK | MB_DEFBUTTON1) == IDYES) {
				ShellExecuteA(null, "open", "http://pspemu.soywiz.com/", null, null, SW_SHOWNORMAL);
			}
		} else {
			writefln("    No new version available");
		}
		
		return _isANewerVersionAvailable;
	}
	
	protected static void setCheckDateToNow() {
		long lastCheckDate = Clock.currTime().stdTime;
		writefln("Updated lastCheckDate to %d", lastCheckDate);
		key.setValue("lastCheckDate", std.string.format("%d", lastCheckDate));
	}
}