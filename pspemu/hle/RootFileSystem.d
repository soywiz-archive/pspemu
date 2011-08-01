module pspemu.hle.RootFileSystem;

import std.stdio;
import std.regex;
import std.file;
import std.string;
import std.array;

import pspemu.utils.Logger;
import pspemu.utils.Path;

import pspemu.hle.HleEmulatorState;

import pspemu.hle.vfs.devices.UmdDevice;
import pspemu.hle.vfs.devices.MemoryStickDevice;
import pspemu.hle.vfs.LocalFileSystem;
import pspemu.hle.vfs.IsoFileSystem;
import pspemu.hle.vfs.MountableVirtualFileSystem;
import pspemu.hle.vfs.EmulatorFileSystem;

import pspemu.formats.iso.IsoFactory;

class RootFileSystem {
	HleEmulatorState hleEmulatorState;
	MountableVirtualFileSystem fsroot, ms0root, umd0root;
	VirtualFileSystem gameroot;
	IoDevice[string] devices;
	string fscurdir;
	bool isUmdGame;
	string gameID = "*";
	
	this(HleEmulatorState hleEmulatorState) {
		this.hleEmulatorState = hleEmulatorState;
		init();
	}
	
	T getDevice(T = IoDevice)(string name) {
		if (name !in devices) throw(new Exception("Can't find device '%s'", name));
		return cast(T)devices[name];
	}
	
	void addDriver(string name, IoDevice ioDevice) {
		string name2 = name ~ ":";
		//writefln("addDriver('%s')", name2);
		devices[name2] = ioDevice;
		fsroot.mount(name2, ioDevice);
	}
	
	void delDriver(string name) {
		string name2 = name ~ ":";
		//writefln("delDriver('%s')", name2);
		//writefln("  %s", devices[name2]);
		devices[name2].exit();
		devices.remove(name2);
		fsroot.umount(name2);
	}

	void init() {
		//.writefln("[1]");
		fsroot = new MountableVirtualFileSystem(new VirtualFileSystem());
		//.writefln("[2]");

		// Devices.
		devices["ms0:"   ] = new MemoryStickDevice(hleEmulatorState, ms0root = new MountableVirtualFileSystem(new LocalFileSystem(ApplicationPaths.exe ~ "/pspfs/ms0")));
		devices["flash0:"] = new IoDevice         (hleEmulatorState, new MountableVirtualFileSystem(new LocalFileSystem(ApplicationPaths.exe ~ "/pspfs/flash0")));
		devices["flash1:"] = new IoDevice         (hleEmulatorState, new MountableVirtualFileSystem(new LocalFileSystem(ApplicationPaths.exe ~ "/pspfs/flash1")));
		devices["umd0:"  ] = new UmdDevice        (hleEmulatorState, umd0root = new MountableVirtualFileSystem(new LocalFileSystem(ApplicationPaths.exe ~ "/pspfs/umd0")));

		// Special Emulator Device.		
		devices["emulator:"] = new IoDevice         (hleEmulatorState, new MountableVirtualFileSystem(new EmulatorFileSystem(hleEmulatorState)));
		//.writefln("[3]");
	
		// Aliases.
		devices["disc0:"  ] = devices["umd0:"];
		devices["ms:"     ] = devices["ms0:"];
		devices["mscmhc0:"] = devices["ms0:"];
		devices["fatms0:" ] = devices["ms0:"];
		//devices["fatms:"  ] = devices["ms0:"];
		devices["fatms:"  ] = devices["umd0:"];
		//.writefln("[4]");

		// Mount registered devices:
		foreach (deviceName, device; devices) fsroot.mount(deviceName, device);
	}
	
	void setIsoPath(string path) {
		devices["umd0:"].parentVirtualFileSystem = new IsoFileSystem(IsoFactory.getIsoFromStream(path), devices["umd0:"]);
		try {
			string umd_data = cast(string)fsroot.readAll("umd0:/UMD_DATA.BIN");
			string[] parts = std.string.split(umd_data, "|");
			gameID = parts[0];
		} catch {
			
		}
	}
	
	void setVirtualBoot(string bootpath) {
	}
	
	void setVirtualDir(string path) {
		// No absolute path; Relative path. No starts by '/' nor contains ':'.
		if ((path[0] == '/') || (path.indexOf(':') != -1)) {
			//writefln("set absolute!");
		} else {
			//writefln("path already absolute!");
			path = std.file.getcwd() ~ '/' ~ path;
		}
		//writefln("setVirtualDir('%s')", path);
		
		auto r = regex(r"PSP_GAME\\SYSDIR$");
		auto m = match(path, r);
		
		if (!m.empty) {
			auto path2 = replace(path, r, "PSP_GAME");
			//fsroot["disc0:"].addChild(new FileSystem(path2), "PSP_GAME");
			//fsroot["umd0:"].addChild(new FileSystem(path2), "PSP_GAME");
			//devices["umd0:"].parentVirtualFileSystem = new FileSystem(path2);
			//throw(new Exception("Not implemented"));
			
			this.isUmdGame = true;
			fscurdir = "umd0:/PSP_GAME/SYSDIR";
			umd0root.mount("PSP_GAME", new LocalFileSystem(path ~ "/.."));
		} else {
			this.isUmdGame = false;
			fscurdir = "ms0:/PSP/GAME/virtual";
		}

		//fsroot["ms0:/PSP/GAME"].addChild(new FileSystem(path), "virtual");
		//gameroot = new VFS_Proxy("<gameroot>", fsroot[fscurdir]);
		ms0root.mount("PSP/GAME/virtual", new LocalFileSystem(path));
		//ms0root.mount("PSP/GAME/virtual", new LocalFileSystem(path));

		
		Logger.log(Logger.Level.INFO, "IoFileMgr", "Setted ms0:/PSP/GAME/virtual to '%s'", path);
	}
}