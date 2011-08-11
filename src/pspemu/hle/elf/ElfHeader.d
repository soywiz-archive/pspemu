module pspemu.hle.elf.ElfHeader;

static struct ElfHeader {
	enum Type    : ushort { Executable = 0x0002, Prx = 0xFFA0 }
	enum Machine : ushort { ALLEGREX = 8 }

	// e_ident 16 bytes.
	char[4]  magic = [0x7F, 'E', 'L', 'F'];  /// 
	ubyte    _class;                         ///
	ubyte    data;                           ///
	ubyte    idver;                          ///
	ubyte[9] _0;                             /// Padding.

	Type     type;                           /// Identifies object file type
	Machine  machine = Machine.ALLEGREX;     /// Architecture build
	uint     _version;                       /// Object file version
	uint     entryPoint;                     /// Virtual address of code entry. Module EntryPoint (PC)
	uint     programHeaderOffset;            /// Program header table's file offset in bytes
	uint     sectionHeaderOffset;            /// Section header table's file offset in bytes
	uint     flags;                          /// Processor specific flags
	ushort   ehsize;                         /// ELF header size in bytes

	// Program Header.
	ushort   programHeaderEntrySize;         /// Program header size (all the same size)
	ushort   programHeaderCount;             /// Number of program headers

	// Section Header.
	ushort   sectionHeaderEntrySize;         /// Section header size (all the same size)
	ushort   sectionHeaderCount;             /// Number of section headers
	ushort   sectionHeaderStringTable;       /// Section header table index of the entry associated with the section name string table

	// Check the size of the struct.
	static assert(this.sizeof == 52);
}
