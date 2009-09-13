module psp.hle.fs;

import std.stdio, std.string, std.stream, std.file, std.path, std.date, std.intrinsic;
import etc.c.zlib;

template TA(T) { ubyte[] TA(inout T t) { return (cast(ubyte *)&t)[0..T.sizeof]; } }

abstract class FileContainer {
	// IDENTIFY
	char[] name;
	override char[] toString() { return "FileContainer(" ~ name ~ ")"; }
	
	// HIERARCHY
	FileContainer parent() { return null; }
	FileContainer[] childs() { return null; }
	alias childs list;
	
	// OPEN
	Stream open(FileMode fm = FileMode.In) { return null; }
	
	// STAT
	ulong ctime()  { return 0; }
	ulong atime()  { return 0; }
	ulong mtime()  { return 0; }
	ulong size()   { return 0; }
	ulong mode()   { return 0777; }
	int   uid()    { return -1; }
	int   gid()    { return -1; }
	bool  isdir()  { return (childs != null); }
	bool  exists() { return true; }
	
	// NAVIGATE
	FileContainer opIndex(char[] path) {
		char[] cpath;
		FileContainer current = this;
		foreach (idx, n; std.string.split(std.string.replace(path, "\\", "/"), "/")) {
			if (cpath.length) cpath ~= "/"; cpath ~= n;
			// root
			if (!n.length) {
				if (idx == 0) while (current.parent) current = current.parent;
				continue;
			}
			if ((current = current.getChild(n)) is null) throw(new Exception(std.string.format("File '%s' doesn't exists", cpath)));
		}
		return current;
	}
	
	FileContainer getChild(char[] name) {
		if (name == "." ) return this;
		if (name == "..") return parent ? parent : this;
		foreach (cc; childs) if (cc.name == name) return cc;
		return null;
	}
	
	FileContainer[] tree() {
		FileContainer[] r;
		foreach (c; childs) {
			r ~= c;
			foreach (cc; c.tree) r ~= cc;
		}
		return r;
	}
	
    int opApply(int delegate(ref FileContainer) dg) {
		int result = 0;
		FileContainer[] _childs = childs;

		foreach (cc; _childs) {
			result = dg(cc);
			if (result) break;
		}
		return result;
    }	
}

class Directory : FileContainer {
	char[] path;

	FileContainer _parent;
	FileContainer parent() { return _parent; }
	
	bool childsFetched = false;
	FileContainer[] _childs;
	FileContainer[] childs() {
		if (!childsFetched) {
			foreach (name; listdir(path)) _childs ~= new Directory(path ~ "/" ~ name, name, this);
			childsFetched = true;
		}
		
		return _childs;
	}
	
	Stream open(FileMode fm = FileMode.In) { return new File(path, fm); }
	
	bool  isdir() { return std.file.isdir(path) != 0; }
	
	this(char[] path, char[] name = null, Directory parent = null) {
		this.path = path;
		this.name = name;
		this._parent = parent;
	}
	
	FileContainer getChild(char[] name) {
		if (name == "." ) return this;
		if (name == "..") return parent ? parent : this;
		return new Directory(path ~ "/" ~ name, name, this);
	}	
	
	override char[] toString() {
		return path;
	}	
}

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
				char year[4]    = "0000";
				char month[2]   = "00";
				char day[2]     = "00";
				char hour[2]    = "00";
				char minute[2]  = "00";
				char second[2]  = "00";
				char hsecond[2] = "00";
				s8   offset     = 0;
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

class CSOStream : Stream {
	struct Header {
		ubyte magic[4];    // +00 : 'C','I','S','O'
		uint  header_size; // +04 : header size (==0x18)
		ulong total_bytes; // +08 : number of original data size
		uint  block_size;  // +10 : number of compressed block size
		ubyte ver;         // +14 : version 01
		ubyte _align;      // +15 : align of index value
		ubyte rsv_06[2];   // +16 : reserved
	}
	
	Header h;
	uint[] blockData;
	uint bufferBlock;
	ubyte[] buffer;
	Stream s;
	z_stream z;
	long position = 0;
	
	int blocks() { return blockData.length - 1; }
	
	this(Stream s) {
		this.s = s;
		
		s.read(TA(h));
		
		if (h.magic != cast(ubyte[])"CISO") throw(new Exception("Not a CSO file"));
		if (h.ver != 1) throw(new Exception("Not a CSO ver1"));
		//if (h.header_size != h.sizeof) throw(new Exception(std.string.format("Invalid header size %d!=%d", h.header_size, h.sizeof)));
		
		blockData.length = h.total_bytes / h.block_size + 1;
		s.readExact(blockData.ptr, 4 * blockData.length);
		
		buffer.length = h.block_size;
		
		seekable = true;
		writeable = false;
		readable = true;
	}
	
	void readSector(uint sector) {
		if (bufferBlock == sector) return;

		if (sector >= blockData.length - 1) throw(new Exception("Invalid CSO sector"));
		
		bufferBlock = sector;
		
		bool getCompressed(uint sector) { return (blockData[sector] & (1 << 31)) == 0; }
		uint getPosition(uint sector) { return blockData[sector] & ~(1 << 31); }
		
		uint start = getPosition(sector);
		uint len = getPosition(sector + 1) - start;
		bool compressed = getCompressed(sector);
		
		s.position = start;
		
		if (!compressed) {
			s.readExact(buffer.ptr, len);
			return;
		}
		
		ubyte[] data = cast(ubyte[])s.readString(len);
		if (data.length != len) throw(new Exception(std.string.format("block=%d : read error", sector)));
	
		if (inflateInit2(&z, -15) != Z_OK) throw(new Exception(std.string.format("defalteInit : %s", z.msg)));
		try {
			z.next_out  = buffer.ptr;
			z.avail_out = buffer.length;
			z.next_in   = data.ptr;
			z.avail_in  = data.length;
			int status  = inflate(&z, Z_FULL_FLUSH);
			if (status != Z_STREAM_END) throw(new Exception(std.string.format("block %d:inflate : %s[%d]\n", sector, z.msg, status)));
		} finally {
			inflateEnd(&z);
		}
	}
	
	override uint readBlock(void* _data, uint size) {
		ubyte *data = cast(ubyte*)_data;
		uint _size = size;
		while (true) {
			uint sec = position / h.block_size;
			uint pos = position % h.block_size;
			uint rem = h.block_size - pos;
			
			readSector(sec);
			
			if (size > rem) {
				data[0..rem] = buffer[pos..pos + rem];
				data += rem;
				size -= rem;
				position += rem;
			} else {
				data[0..size] = buffer[pos..pos + size];
				data += size;
				position += size;
				size = 0;
				break;
			}
		}
		
		return _size;
	}

	override uint writeBlock(void* buffer, uint size) { throw(new Exception("Not implemented")); }
	
	override ulong seek(long offset, SeekPos whence) {
		switch (whence) {
			default:
			case SeekPos.Set:     return position = offset;
			case SeekPos.End:     return position = h.total_bytes + offset;
			case SeekPos.Current: return position += offset;
		}
	}
}

unittest {
//int main(char[][] args) {
	FileContainer test = new Directory(".");
	Stream ss = test["test.txt"].open(FileMode.OutNew);
	ss.writeString("test");
	ss.close();

	FileContainer fc = new ISO(new CSOStream(new File("test.cso")));
	
	ubyte[20] d;
	fc["/PSP_GAME/SYSDIR/BOOT.BIN"].open.read(d);
	writefln(d);
	
	return 0;
}