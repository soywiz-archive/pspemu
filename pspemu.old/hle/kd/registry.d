module pspemu.hle.kd.registry; // kd/registry.prx (sceRegistry_Service)

debug = DEBUG_SYSCALL;

import std.string, std.stdio;
import std.c.windows.windows;

import pspemu.hle.Module;

import pspemu.utils.VirtualFileSystem;

class sceReg : Module {
	void initNids() {
		mixin(registerd!(0x92E41280, sceRegOpenRegistry));
		mixin(registerd!(0x39461B4D, sceRegFlushRegistry));
		mixin(registerd!(0x1D8A762E, sceRegOpenCategory));
		mixin(registerd!(0xFA8A5739, sceRegCloseRegistry));
		mixin(registerd!(0xD4475AA8, sceRegGetKeyInfo));
		mixin(registerd!(0x0CAE832B, sceRegCloseCategory));
		mixin(registerd!(0x17768E14, sceRegSetKeyValue));
		mixin(registerd!(0x0D69BF40, sceRegFlushCategory));
		mixin(registerd!(0x28A8E98A, sceRegGetKeyValue));
	}

	void initModule() {
		registry = new Registry;
	}

	Registry registry;

	//bool[VFS] openedRegistries;

	/**
	 * Open the registry
	 *
	 * @param reg - A filled in ::RegParam structure
	 * @param mode - Open mode (set to 1)
	 * @param h - Pointer to a REGHANDLE to receive the registry handle
	 *
	 * @return 0 on success, < 0 on error
	 */
	int sceRegOpenRegistry(RegParam* reg, int mode, REGHANDLE* h) {
		auto registry = this.registry;
		//openedRegistries[registry] = true;
		*h = reinterpret!(uint)(registry);
		return 0;
	}

	/**
	 * Flush the registry to disk
	 *
	 * @param h - The open registry handle
	 *
	 * @return 0 on success, < 0 on error
	 */
	int sceRegFlushRegistry(REGHANDLE h) {
		auto registry = reinterpret!(VFS)(h);
		if (registry is null) return -1;
		registry.flush();
		return 0;
	}

	/**
	 * Close the registry 
	 *
	 * @param h - The open registry handle
	 *
	 * @return 0 on success, < 0 on error
	 */
	int sceRegCloseRegistry(REGHANDLE h) {
		auto registry = reinterpret!(VFS)(h);
		if (registry is null) return -1;
		//openedRegistries.remove(registry);
		return 0;
	}

	/**
	 * Open a registry directory
	 *
	 * @param h - The open registry handle
	 * @param name - The path to the dir to open (e.g. /CONFIG/SYSTEM)
	 * @param mode - Open mode (can be 1 or 2, probably read or read/write
	 * @param hd - Pointer to a REGHANDLE to receive the registry dir handle
	 *
	 * @return 0 on success, < 0 on error
	 */
	int sceRegOpenCategory(REGHANDLE h, string name, int mode, REGHANDLE *hd) {
		auto registry = reinterpret!(VFS)(h);
		try {
			auto registryCat = registry[name];
			*hd = reinterpret!(REGHANDLE)(registryCat);
			//openedRegistries[registryCat] = true;
			return 0;
		} catch (Exception e) {
			writefln("sceRegOpenCategory:: '%s'", e);
			return -1;
		}
	}

	/**
	 * Close the registry directory
	 *
	 * @param hd - The open registry dir handle
	 *
	 * @return 0 on success, < 0 on error
	 */
	int sceRegCloseCategory(REGHANDLE hd) {
		auto registry = reinterpret!(VFS)(hd);
		if (registry is null) return -1;
		//openedRegistries.remove(registry);
		return 0;
	}

	/**
	 * Get a key's information
	 *
	 * @param hd - The open registry dir handle
	 * @param name - Name of the key
	 * @param hk - Pointer to a REGHANDLE to get registry key handle
	 * @param type - Type of the key, on of ::RegKeyTypes
	 * @param size - The size of the key's value in bytes
	 *
	 * @return 0 on success, < 0 on error
	 */
	int sceRegGetKeyInfo(REGHANDLE hd, string name, REGHANDLE* hk, uint* type, SceSize* size) {
		auto registry = reinterpret!(VFS)(hd);
		auto registryKey = registry[name];
		try {
			*hk = reinterpret!(REGHANDLE)(registryKey);
			*type = (cast(RegistryNode)registryKey).type;
			*size = (cast(RegistryNode)registryKey).typeSize;
			return 0;
		} catch (Exception e) {
			writefln("sceRegOpenCategory:: '%s'", e);
			return -1;
		}
	}

	/**
	 * Set a key's value
	 *
	 * @param hd - The open registry dir handle
	 * @param name - The key name
	 * @param buf - Buffer to hold the value
	 * @param size - The size of the buffer
	 *
	 * @return 0 on success, < 0 on error
	 */
	int sceRegSetKeyValue(REGHANDLE hd, string name, void *buf, SceSize size) {
		unimplemented();
		return -1;
	}

	/**
	 * Flush the registry directory to disk
	 *
	 * @param hd - The open registry dir handle
	 *
	 * @return 0 on success, < 0 on error
	 */
	int sceRegFlushCategory(REGHANDLE hd) {
		auto registryDirectory = reinterpret!(RegistryNode)(hd);
		if (registryDirectory is null) return -1;
		registryDirectory.flush();
		return 0;
	}

	/**
	 * Get a key's value
	 *
	 * @param hd - The open registry dir handle
	 * @param hk - The open registry key handler (from ::sceRegGetKeyInfo)
	 * @param buf - Buffer to hold the value
	 * @param size - The size of the buffer
	 *
	 * @return 0 on success, < 0 on error
	 */
	int sceRegGetKeyValue(REGHANDLE hd, REGHANDLE hk, void* buf, SceSize size) {
		auto registryKey = reinterpret!(RegistryNode)(hk);
		try {
			(cast(ubyte *)buf)[0..size] = registryKey.value[0..size];
			return 0;
		} catch (Exception e) {
			throw(e);
			return -1;
		}
	}
}

alias uint REGHANDLE;

struct RegParam {
	uint regtype;     /* 0x0, set to 1 only for system */
	/** Seemingly never used, set to ::SYSTEM_REGISTRY */
	char name[256];        /* 0x4-0x104 */
	/** Length of the name */
	uint namelen;     /* 0x104 */
	/** Unknown, set to 1 */
	uint unk2 = 1;     /* 0x108 */
	/** Unknown, set to 1 */
	uint unk3 = 1;     /* 0x10C */
}

enum RegKeyTypes {
	/** Key is a directory */
	REG_TYPE_DIR = 1,
	/** Key is an integer (4 bytes) */
	REG_TYPE_INT = 2,
	/** Key is a string */
	REG_TYPE_STR = 3,
	/** Key is a binary string */
	REG_TYPE_BIN = 4,
}

/**
 * Valid values for PSP_SYSTEMPARAM_ID_INT_LANGUAGE
 */
enum {
	PSP_SYSTEMPARAM_LANGUAGE_JAPANESE		= 0,
	PSP_SYSTEMPARAM_LANGUAGE_ENGLISH		= 1,
	PSP_SYSTEMPARAM_LANGUAGE_FRENCH			= 2,
	PSP_SYSTEMPARAM_LANGUAGE_SPANISH		= 3,
	PSP_SYSTEMPARAM_LANGUAGE_GERMAN			= 4,
	PSP_SYSTEMPARAM_LANGUAGE_ITALIAN		= 5,
	PSP_SYSTEMPARAM_LANGUAGE_DUTCH			= 6,
	PSP_SYSTEMPARAM_LANGUAGE_PORTUGUESE		= 7,
	PSP_SYSTEMPARAM_LANGUAGE_RUSSIAN		= 8,
	PSP_SYSTEMPARAM_LANGUAGE_KOREAN			= 9,
	PSP_SYSTEMPARAM_LANGUAGE_CHINESE_TRADITIONAL	= 10,
	PSP_SYSTEMPARAM_LANGUAGE_CHINESE_SIMPLIFIED	= 11,
}

static struct RegistryEntry {

}

class RegistryNode : VFS {
	RegKeyTypes type;
	ubyte[] value;
	VFS[] childs;
	VFS[] implList() { return childs; }

	this(string name) {
		this.type = RegKeyTypes.REG_TYPE_DIR;
		super(name);
	}

	this(string name, uint value) {
		this.type  = RegKeyTypes.REG_TYPE_INT;
		this.value.length = 4;
		*cast(uint *)this.value.ptr = value;
		super(name);
	}

	this(string name, string value) {
		this.type  = RegKeyTypes.REG_TYPE_STR;
		this.value = cast(ubyte[])value;
		super(name);
	}

	VFS implContains(string name, bool create = false) {
		if (create) {
			auto node = new RegistryNode(name);
			this.childs ~= node;
			return node;
		}
		return null;
	}

	uint typeSize() {
		switch (type) {
			case RegKeyTypes.REG_TYPE_DIR: return 0;
			case RegKeyTypes.REG_TYPE_INT: return 4;
			case RegKeyTypes.REG_TYPE_STR, RegKeyTypes.REG_TYPE_BIN: return value.length;
		}
	}
	
	Stats implStats() {
		Stats stats;
		{
			stats.phyname = this.name;
			stats.mode = 0;
			stats.attr = 0;
			stats.size = this.typeSize;
			stats.type = (this.type == RegKeyTypes.REG_TYPE_DIR) ? Type.Directory : Type.File;
		}
		return stats;
	}

	Stream implOpen(string name, FileMode mode, int attr) {
		return new MemoryStream(value);
	}
}

extern (Windows) uint GetSystemDefaultLCID();

class Registry : RegistryNode {
	this() {
		uint language = PSP_SYSTEMPARAM_LANGUAGE_ENGLISH;
		switch (GetSystemDefaultLCID & 0x1FF) {
			case 0x07: language = PSP_SYSTEMPARAM_LANGUAGE_GERMAN; break;
			default:
			case 0x09: language = PSP_SYSTEMPARAM_LANGUAGE_ENGLISH; break;
			case 0x0A: language = PSP_SYSTEMPARAM_LANGUAGE_SPANISH; break;
			case 0x0C: language = PSP_SYSTEMPARAM_LANGUAGE_FRENCH; break;
			case 0x10: language = PSP_SYSTEMPARAM_LANGUAGE_ITALIAN; break;
			case 0x11: language = PSP_SYSTEMPARAM_LANGUAGE_JAPANESE; break;
		}
		this.set("/CONFIG/SYSTEM/XMB", "language", language);
		this.set("/CONFIG/SYSTEM/XMB", "button_assign", 0);
		super("<RegistryRoot>");
	}

	void set(string path, string key, uint   value) { this.access(path, true) ~= new RegistryNode(key, value); }
	void set(string path, string key, string value) { this.access(path, true) ~= new RegistryNode(key, value); }
}


static this() {
	mixin(Module.registerModule("sceReg"));
}
