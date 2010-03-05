module pspemu.formats.iso;

import pspemu.formats.base;

class ISOContainer : FileContainer {
	// Types
	// Signed
	alias byte  s8;
	alias short s16;
	alias int   s32;
	alias long  s64;
	// Unsigned
	alias ubyte  u8;
	alias ushort u16;
	alias uint   u32;
	alias ulong  u64;
	// Both Byte Order Types
	align(1) struct u16b { u16 l, b; void opAssign(u16 v) { l = v; b = bswap(v) >> 16; } }
	align(1) struct u32b { u32 l, b; void opAssign(u32 v) { l = v; b = bswap(v); } }
	
	// 8.4.26 Volume Creation Date and Time (BP 814 to 830)
	align (1) struct Date {
		union {
			struct {
				char[4] year    = "0000"; // +00
				char[2] month   = "00";   // +04
				char[2] day     = "00";   // +06
				char[2] hour    = "00";   // +08
				char[2] minute  = "00";   // +0A
				char[2] second  = "00";   // +0C
				char[2] hsecond = "00";   // +0E
				s8   offset     = 0;      // +10
			}
			u8 v[17];
		}
	}
	
	// 9.1 Format of a Directory Record
	align (1) struct DirectoryRecord {
		align(1) struct Date {
			union {
				struct { u8 year, month, day, hour, minute, second, offset; }
				u8[7] v;
			}
			
			void opAssign(d_time t) {
				std.date.Date date;
				date.parse(std.date.toUTCString(t));
				year   = date.year - 1900;
				month  = date.month;
				day    = date.day;
				hour   = date.hour;
				minute = date.minute;
				second = date.second;
				offset = 0;				
			}
		}
	
		u8   Length;
		u8   ExtAttrLength;
		u32b Extent;
		u32b Size;
		Date date; // 9.1.5 Recording Date and Time (BP 19 to 25)
		u8   Flags;
		u8   FileUnitSize;
		u8   Interleave;
		u16b VolumeSequenceNumber;
		u8   NameLength;
	}
	
	// 8 Volume Descriptors
	align (1) struct VDHeader {
		enum Type : u8 {
			BootRecord                    = 0x00, // 8.2 Boot Record
			VolumePartitionSetTerminator  = 0xFF, // 8.3 Volume Descriptor Set Terminator
			PrimaryVolumeDescriptor       = 0x01, // 8.4 Primary Volume Descriptor
			SupplementaryVolumeDescriptor = 0x02, // 8.5 Supplementary Volume Descriptor
			VolumePartitionDescriptor     = 0x03, // 8.6 Volume Partition Descriptor
		}
		
		Type type;
		u8   id[5];
		u8   ver;
	}
	
	// 8.4 Primary Volume Descriptor
	align (1) struct PrimaryVolumeDescriptor {
		VDHeader vdh;
		
		u8   _1;
		u8   SystemId[0x20];
		u8   VolumeId[0x20];
		u64  _2;
		u32b VolumeSpaceSize;
		u64  _3[4];
		u32   VolumeSetSize;
		u32  VolumeSequenceNumber;
		u16b  LogicalBlockSize;
		u32b PathTableSize;
		u32  TypeLPathTable;
		u32  OptType1PathTable;
		u32  TypeMPathTable;
		u32  OptTypeMPathTable;
		
		DirectoryRecord dr;
		
		u8   _4;
		u8   VolumeSetId[0x80];
		u8   PublisherId[0x80];
		u8   PreparerId[0x80];
		u8   ApplicationId[0x80];
		u8   CopyrightFileId[37];
		u8   AbstractFileId[37];
		u8   BibliographicFileId[37];
		
		Date CreationDate;
		Date ModificationDate;
		Date ExpirationDate;
		Date EffectiveDate;
		u8   FileStructureVersion;
		u8   _5;
		u8   ApplicationData[0x200];
		u8   _6[653];
	}
	
	char[] path;
	DirectoryRecord dr;
	Stream s;
	
	ISOContainer[] _childs;
	FileContainer[] childs() { return _childs; }
	
	ISOContainer _parent;
	FileContainer parent() { return _parent; }
	
	bool  isdir() { return (dr.Flags & 2) != 0; }
	
	this(ISOContainer parent, DirectoryRecord dr, char[] path, char[] name = null) {
		this._parent = parent;
		this.dr = dr;
		this.path = path;
		this.name = name;
		this.s = parent.s;
	}
	
	Stream open(FileMode fm = FileMode.In) {
		return s;
	}
	
	this() { }
	
	override char[] toString() {
		return path;
	}		
}

class ISO : ISOContainer {
	PrimaryVolumeDescriptor pvd;
	
	void processDR(ISOContainer parent) {
		ulong start = parent.dr.Extent.l * 0x800;
		ulong len = parent.dr.Size.l;
		Stream s2 = new SliceStream(s, start, start + parent.dr.Size.l);
		
		while (!s2.eof) {
			ubyte l; s2.read(l);
			if (!l) break;
			
			DirectoryRecord* dr;
			ubyte[] drd;
			drd.length = l;
			s2.read(drd[1..drd.length]);
			dr = cast(DirectoryRecord*)drd.ptr;
			
			char[] name;
			if (dr.NameLength) name = cast(char[])drd[DirectoryRecord.sizeof..DirectoryRecord.sizeof + dr.NameLength];
			
			if (name == "\x00" || name == "\x01") continue;
			parent._childs ~= new ISOContainer(parent, *dr, parent.path ~ "/" ~ name, name);
		}
		
		foreach (c; parent._childs) if (c.isdir) processDR(c);
	}
	
	this(Stream s) {
		this.s = s;
		s.position = 0x800 * 0x10;
		s.readExact(&pvd, pvd.sizeof);
		dr = pvd.dr;
		processDR(this);
	}
}
