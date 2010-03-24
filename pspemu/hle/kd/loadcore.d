module pspemu.hle.kd.loadcore; // kd/loadcore.prx (sceLoaderCore):

import pspemu.hle.Module;

class LoadCoreForKernel : Module {
	void initNids() {
		mixin(registerd!(0xD8779AC6, sceKernelIcacheClearAll));
		mixin(registerd!(0xCF8A41B1, sceKernelFindModuleByName));
	}

	/**
	 * Invalidate the CPU's instruction cache.
	 */
	void sceKernelIcacheClearAll() {
		unimplemented();
	}

	/**
	 * Find a module by it's name.
	 *
	 * @param modname - The name of the module.
	 *
	 * @return Pointer to the ::SceModule structure if found, otherwise NULL.
	 */
	SceModule* sceKernelFindModuleByName(string modname) {
		unimplemented();
		return null;
	}
}

struct SceModule {
	SceModule* next;
	ushort  attribute;
	ubyte   _version[2];
	char    modname[27];
	char    terminal;
	uint    unknown1;
	uint    unknown2;
	SceUID  modid;
	uint    unknown3[4];
	void*   ent_top;
	uint    ent_size;
	void*   stub_top;
	uint    stub_size;
	uint    unknown4[4];
	uint    entry_addr;
	uint    gp_value;
	uint    text_addr;
	uint    text_size;
	uint    data_size;
	uint    bss_size;
	uint    nsegment;
	uint    segmentaddr[4];
	uint    segmentsize[4];
}

static this() {
	mixin(Module.registerModule("LoadCoreForKernel"));
}
