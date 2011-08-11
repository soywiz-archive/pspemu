module pspemu.hle.elf.PspHeader;

align(1) struct PspHeader {
	char[4]   magic = "\x7EPSP";
	ushort    mod_attr;
	ushort    comp_mod_attr;
	ubyte     mod_ver_lo;
	ubyte     mod_ver_hi;
	char[28]  modname;
	ubyte     mod_version;
	ubyte     nsegments;
	uint      elf_size;
	uint      psp_size;
	uint      boot_entry;
	uint      modinfo_offset;
	uint      bss_size;
	ushort[4] seg_align;
	uint[4]   seg_address;
	uint[4]   seg_size;
	uint[4]   reserved;
	uint      devkit_version;
	ubyte     dec_mode;
	ubyte     pad;
	ushort    overlap_size;
	ubyte[16] aes_key;
	ubyte[16] cmac_key;
	ubyte[16] cmac_header_hash;
	uint      comp_size;
	uint      comp_offset;
	uint      unk1;
	uint      unk2;
	ubyte[16] cmac_data_hash;
	uint      tag;
	ubyte[88] sig_check;
	ubyte[20] sha1_hash;
	ubyte[16] key_data;
	
	static assert (this.sizeof == 1111);
}
