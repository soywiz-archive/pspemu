module pspemu.hle.elf.ElfReloc;

static struct ElfReloc {
	enum Type : ubyte {
		None        = 0,
		Mips16      = 1,
		Mips32      = 2,
		MipsRel32   = 3,
		Mips26      = 4,
		MipsHi16    = 5,
		MipsLo16    = 6,
		MipsGpRel16 = 7, 
		MipsLiteral = 8,
		MipsGot16   = 9,
		MipsPc16    = 10,
		MipsCall16  = 11,
		MipsGpRel32 = 12,
	}
	uint offset;
	union {
		uint _info;
		struct {
			Type type;
			ubyte offsetBase;
			ubyte addressBase;
			ubyte _dummy;
			uint symbolIndex() { return _info >> 8; }
		}
	}
	
	uint sindex() { return (_info >> 8); }

	// Check the size of the struct.
	static assert(this.sizeof == 8);
}
