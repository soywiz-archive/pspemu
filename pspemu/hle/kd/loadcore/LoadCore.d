module pspemu.hle.kd.loadcore.LoadCore; // kd/loadcore.prx (sceLoaderCore):

import std.stdio;

import pspemu.hle.ModuleNative;
import pspemu.hle.ModulePsp;
import pspemu.hle.kd.loadcore.Types;

class LoadCoreForKernel : ModuleNative {
	void initNids() {
		mixin(registerd!(0xD8779AC6, sceKernelIcacheClearAll));
		mixin(registerd!(0xCF8A41B1, sceKernelFindModuleByName));

		mixin(registerd!(0xACE23476, sceKernelCheckPspConfig));
		mixin(registerd!(0xBF983EF2, sceKernelProbeExecutableObject));
		mixin(registerd!(0xCCE4A157, sceKernelFindModuleByUID));
	}

	// @TODO: Unknown.
	void sceKernelCheckPspConfig() { unimplemented(); }
	void sceKernelProbeExecutableObject() { unimplemented(); }

	/**
	 * Find a module by it's UID.
	 *
	 * @param modid - The UID of the module.
	 *
	 * @return Pointer to the ::SceModule structure if found, otherwise NULL.
	 */
	SceModule* sceKernelFindModuleByUID(SceUID modid) {
		logWarning("Not implemented sceKernelFindModuleByUID(%d)", modid);
		
		return uniqueIdFactory.get!Module(modid).sceModule;
	}

	/**
	 * Invalidate the CPU's instruction cache.
	 */
	void sceKernelIcacheClearAll() {
		//unimplemented();
	}

	/**
	 * Find a module by it's name.
	 *
	 * @param modname - The name of the module.
	 *
	 * @return Pointer to the ::SceModule structure if found, otherwise NULL.
	 */
	SceModule* sceKernelFindModuleByName(string modname) {
		logWarning("sceKernelFindModuleByName('%s') not implemented", modname);
		//unimplemented();
		return null;
	}
}

static this() {
	mixin(ModuleNative.registerModule("LoadCoreForKernel"));
}
