module pspemu.hle.kd.loadcore.Types;

public import pspemu.hle.kd.Types;

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
