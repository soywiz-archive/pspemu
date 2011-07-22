module pspemu.hle.kd.modulemgr.ModuleMgr; // kd/modulemgr.prx (sceModuleManager)

import pspemu.hle.ModuleNative;

import std.stream;
import std.stdio;

import pspemu.hle.ModuleNative;
import pspemu.hle.ModulePsp;
import pspemu.hle.kd.loadcore.Types;
import pspemu.hle.kd.modulemgr.Types;
import pspemu.hle.kd.iofilemgr.Types;

//debug = DEBUG_SYSCALL;

import pspemu.hle.kd.threadman.ThreadMan; 
import pspemu.hle.kd.iofilemgr.IoFileMgr;
import pspemu.hle.vfs.VirtualFileSystem;

class ModuleMgrForUser : ModuleNative {
	void initNids() {
		mixin(registerd!(0xD675EBB8, sceKernelSelfStopUnloadModule));
		mixin(registerd!(0xB7F46618, sceKernelLoadModuleByID));
		mixin(registerd!(0x977DE386, sceKernelLoadModule));
		mixin(registerd!(0x50F0C1EC, sceKernelStartModule));
		mixin(registerd!(0xD1FF982A, sceKernelStopModule));
		mixin(registerd!(0x2E0911AA, sceKernelUnloadModule));
		mixin(registerd!(0xD8B73127, sceKernelGetModuleIdByAddress));
		mixin(registerd!(0xF0A26395, sceKernelGetModuleId));
		mixin(registerd!(0x8F2DF740, sceKernelStopUnloadSelfModuleWithStatus));
		mixin(registerd!(0x748CBED9, sceKernelQueryModuleInfo));
	}

	/**
	 * Query the information about a loaded module from its UID.
	 * @note This fails on v1.0 firmware (and even it worked has a limited structure)
	 * so if you want to be compatible with both 1.5 and 1.0 (and you are running in 
	 * kernel mode) then call this function first then ::pspSdkQueryModuleInfoV1 
	 * if it fails, or make separate v1 and v1.5+ builds.
	 *
	 * @param modid - The UID of the loaded module.
	 * @param info  - Pointer to a ::SceKernelModuleInfo structure.
	 * 
	 * @return 0 on success, otherwise one of ::PspKernelErrorCodes.
	 */
	int sceKernelQueryModuleInfo(SceUID modid, SceKernelModuleInfo* info) {
		unimplemented_notice();
		
		Module pspModule = uniqueIdFactory.get!Module(modid);
		SceModule* sceModule = pspModule.sceModule;
		// TODO!
		info.size        = SceKernelModuleInfo.sizeof;
		info.nsegment    = cast(ubyte)sceModule.nsegment;
		info.segmentaddr = sceModule.segmentaddr;
		info.segmentsize = sceModule.segmentsize;
		info.entry_addr  = sceModule.entry_addr;
		info.gp_value    = sceModule.gp_value;
		info.text_addr   = sceModule.text_addr;
		info.text_size   = sceModule.text_size;
		info.data_size   = sceModule.data_size;
		info.bss_size    = sceModule.bss_size;
		info.attribute   = sceModule.attribute;
		info._version    = sceModule._version;
		info.name[] = 0;
		info.name[0..27] = sceModule.modname[0..27];
		//info.next = 0xAA007712;
		//info.
		//hleEmulatorState.moduleManager.
		//unimplemented();
		return 0;
	}

	/**
	 * Gets a module by its loaded address.
	 */
	SceUID sceKernelGetModuleIdByAddress(uint addr) {
		logWarning("sceKernelGetModuleIdByAddress(0x%08X)", addr);
		return hleEmulatorState.moduleManager.getModuleByAddress(addr).modid;
	}

	/**
	 * Get module ID from the module that called the API. 
	 *
	 * @return >= 0 on success
	 */
	uint sceKernelGetModuleId() {
		//unimplemented();
		unimplemented_notice();
		
		ModulePsp modulePsp = new ModulePsp();
		modulePsp.dummyModule = true;
		return uniqueIdFactory.add!Module(modulePsp);
	}

	uint sceKernelStopUnloadSelfModuleWithStatus() {
		unimplemented_notice();
		throw(new HaltException("sceKernelStopUnloadSelfModuleWithStatus"));
		return 0;
	}

	/**
	 * Stop and unload the current module.
	 *
	 * @param unknown - Unknown (I've seen 1 passed).
	 * @param argsize - Size (in bytes) of the arguments that will be passed to module_stop().
	 * @param argp    - Pointer to arguments that will be passed to module_stop().
	 *
	 * @return ??? on success, otherwise one of ::PspKernelErrorCodes.
	 */
	int sceKernelSelfStopUnloadModule(int unknown, SceSize argsize, void *argp) {
		//hleEmulatorState.emulatorState.runningState.stop();
		logWarning("sceKernelSelfStopUnloadModule");
		hleEmulatorState.emulatorState.runningState.stopCpu();
		throw(new HaltException("sceKernelSelfStopUnloadModule"));
		return 0;
	}
	
	SceUID _sceKernelLoadModule(Stream moduleStream, string path, int flags, SceKernelLMOption* option) {
		try {
			Module modulePsp = hleEmulatorState.moduleManager.loadPspModule(moduleStream, path);
			
			switch (modulePsp.name) {
				case "sceMpeg_library":
					modulePsp = hleEmulatorState.moduleManager.getName("sceMpeg");
				break;
				case "sceATRAC3plus_Library":
					modulePsp = hleEmulatorState.moduleManager.getName("sceAtrac3plus");
				break;
				default:
				break;
			}
			
			//logWarning("Loaded '%s'", modulePsp.name);
			//switch (modulePsp.name)
			
			// Fill the blank imports of the current module with the exports from the loaded module.
			currentThreadState().threadModule.fillImportsWithExports(currentMemory, modulePsp);
			
			Logger.log(Logger.Level.INFO, "ModuleMgrForUser", "sceKernelLoadModule.loaded");
			return modulePsp.modid;
		} catch (Throwable o) {
			logError("Unable to load module sceKernelLoadModule '%s' : %s", path, o);
			
			return hleEmulatorState.moduleManager.createDummyModule().modid;
		}
	}

	/**
	 * Load a module from the given file UID.
	 *
	 * @param fid    - The module's file UID.
	 * @param flags  - Unused, always 0.
	 * @param option - Pointer to an optional ::SceKernelLMOption structure.
	 *
	 * @return The UID of the loaded module on success, otherwise one of ::PspKernelErrorCodes.
	 */
	SceUID sceKernelLoadModuleByID(SceUID fid, int flags, SceKernelLMOption *option) {
		FileHandle fileHandle = uniqueIdFactory.get!FileHandle(fid);
		
		logInfo("sceKernelLoadModuleByID(%d, %d, 0x%08X)", fid, flags, cast(uint)cast(void*)option);
		//unimplemented();
		return _sceKernelLoadModule(
			fileHandle, "?unknown_path?",
			flags,
			option
		);
	}

	/**
	 * Load a module.
	 * @note This function restricts where it can load from (such as from flash0) 
	 * unless you call it in kernel mode. It also must be called from a thread.
	 * 
	 * @param path   - The path to the module to load.
	 * @param flags  - Unused, always 0 .
	 * @param option - Pointer to a mod_param_t structure. Can be NULL.
	 *
	 * @return The UID of the loaded module on success, otherwise one of ::PspKernelErrorCodes.
	 */
	SceUID sceKernelLoadModule(string path, int flags, SceKernelLMOption* option) {
		logInfo("@WARNING FAKED :: sceKernelLoadModule('%s', %d, 0x%08X)", path, flags, cast(uint)option);

		try {
			IoFileMgrForKernel ioFileMgrForKernel = hleEmulatorState.moduleManager.get!IoFileMgrForKernel();
			return _sceKernelLoadModule(
				ioFileMgrForKernel._open(path, SceIoFlags.PSP_O_RDONLY, octal!777), path,
				flags,
				option
			);
		} catch (Throwable o) {
			logError("Unable to load module sceKernelLoadModule '%s' : %s", path, o);
			
			return hleEmulatorState.moduleManager.createDummyModule().modid;
		}
	}

	/**
	 * Start a loaded module.
	 *
	 * @param modid   - The ID of the module returned from LoadModule.
	 * @param argsize - Length of the args.
	 * @param argp    - A pointer to the arguments to the module.
	 * @param status  - Returns the status of the start.
	 * @param option  - Pointer to an optional ::SceKernelSMOption structure.
	 *
	 * @return ??? on success, otherwise one of ::PspKernelErrorCodes.
	 */
	int sceKernelStartModule(SceUID modid, SceSize argsize, uint argp, int *status, SceKernelSMOption *option) {
		logInfo("sceKernelStartModule(modid=%d)", modid);
		
		//writefln("[1]");
		Module modulePsp = uniqueIdFactory.get!Module(modid);
		//writefln("[2]");
		
		if (modulePsp.isNative) {
			return 0;
		}
		
		if (modulePsp.dummyModule) {
			return 0;
		}
		//writefln("[3]");
		
		ThreadManForUser threadManForUser = hleEmulatorState.moduleManager.get!ThreadManForUser();
		
		//writefln("[4]");
		
		//SceUID sceKernelCreateThread(string name, SceKernelThreadEntry entry, int initPriority, int stackSize, SceUInt attr, SceKernelThreadOptParam *option)
		SceUID thid = threadManForUser.sceKernelCreateThread("main_thread", modulePsp.sceModule.entry_addr, 0, 0x1000, modulePsp.sceModule.attribute, null);
		
		//writefln("[4a]");
		
		ThreadState threadState = uniqueIdFactory.get!ThreadState(thid);
		
		//writefln("[4b]");
		
		threadState.threadModule = modulePsp;
		
		//writefln("[5]");
		
		threadManForUser.sceKernelStartThread(thid, argsize, argp);
		
		//writefln("[6]");
		
		return 0;
	}

	/**
	 * Stop a running module.
	 *
	 * @param modid   - The UID of the module to stop.
	 * @param argsize - The length of the arguments pointed to by argp.
	 * @param argp    - Pointer to arguments to pass to the module's module_stop() routine.
	 * @param status  - Return value of the module's module_stop() routine.
	 * @param option  - Pointer to an optional ::SceKernelSMOption structure.
	 *
	 * @return ??? on success, otherwise one of ::PspKernelErrorCodes.
	 */
	int sceKernelStopModule(SceUID modid, SceSize argsize, void *argp, int *status, SceKernelSMOption *option) {
		Module pspModule = hleEmulatorState.uniqueIdFactory.get!Module(modid);

		unimplemented_notice();
		logError("Not implemented sceKernelStopModule!!");
		return 0;
	}

	/**
	 * Unload a stopped module.
	 *
	 * @param modid - The UID of the module to unload.
	 *
	 * @return ??? on success, otherwise one of ::PspKernelErrorCodes.
	 */
	int sceKernelUnloadModule(SceUID modid) {
		Module pspModule = hleEmulatorState.uniqueIdFactory.get!Module(modid);

		unimplemented_notice();
		logError("Not implemented sceKernelUnloadModule!!");
		
		//pspModule.
		
		//hleEmulatorState.moduleManager.unloadModu
		return 0;
	}
}

class ModuleMgrForKernel : ModuleMgrForUser {
}

static this() {
	mixin(ModuleNative.registerModule("ModuleMgrForKernel"));
	mixin(ModuleNative.registerModule("ModuleMgrForUser"));
}