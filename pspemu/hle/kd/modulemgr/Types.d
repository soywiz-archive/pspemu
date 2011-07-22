module pspemu.hle.kd.modulemgr.Types;

public import pspemu.hle.kd.Types;

struct SceKernelLMOption {
	SceSize size;
	SceUID  mpidtext;
	SceUID  mpiddata;
	uint    flags;
	char    position;
	char    access;
	char    creserved[2];
}

struct SceKernelSMOption {
	SceSize size;
	SceUID  mpidstack;
	SceSize stacksize;
	int     priority;
	uint    attribute;
}

struct SceModuleInfo {
	ushort modattribute;
	ubyte  modversion[2];
	char   modname[27];
	char   terminal;
	void*  gp_value;
	void*  ent_top;
	void*  ent_end;
	void*  stub_top;
	void*  stub_end;
}

struct SceKernelModuleInfo {
	SceSize size;
	ubyte   nsegment;
	char    reserved[3];
	uint    segmentaddr[4];
	uint    segmentsize[4];
	uint    entry_addr;
	uint    gp_value;
	uint    text_addr;
	uint    text_size;
	uint    data_size;
	uint    bss_size;
	// The following is only available in the v1.5 firmware and above,
	// but as sceKernelQueryModuleInfo is broken in v1.0 is doesn't matter ;)
	ushort  attribute;
	ubyte   _version[2];
	char    name[28];
}

enum PspModuleInfoAttr {
	PSP_MODULE_USER			= 0,
	PSP_MODULE_NO_STOP		= 0x0001,
	PSP_MODULE_SINGLE_LOAD	= 0x0002,
	PSP_MODULE_SINGLE_START	= 0x0004,
	PSP_MODULE_KERNEL		= 0x1000,
};
