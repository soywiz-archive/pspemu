module pspemu.hle.formats.iso.Iso;

import std.utf;
import std.encoding;
import std.stdio;
import std.datetime;
import std.stream;
import std.string;
import core.bitop;
import pspemu.core.exceptions.NotImplementedException;
import pspemu.utils.MathUtils;

import std.system;

class Iso {
	const SECTOR_SIZE = 0x800;
	
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
	align(1) struct u16b {
		u16 l, b; void opAssign(u16 v) { l = v; b = bswap(v) >> 16; }
		string toString() { return std.string.format("%d", l); }

	    version(LittleEndian) {
			alias l this;
		} else {
			alias b this;
		}

		T opCast(T = uint)() {
			return cast(T)l;
		}
	}
	align(1) struct u32b {
		u32 l, b; void opAssign(u32 v) { l = v; b = bswap(v); }
		string toString() { return std.string.format("%d", l); }

	    version(LittleEndian) {
			alias l this;
		} else {
			alias b this;
		}
		
		T opCast(T = uint)() {
			return cast(T)l;
		}
	}
	
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
			
			void opAssign(DateTime dateTime) {
				throw(new NotImplementedException("Iso.DirectoryRecord.Date.opAssign not implemented"));
				/*
				std.date.Date date;
				date.parse(std.date.toUTCString(t));
				year   = date.year - 1900;
				month  = date.month;
				day    = date.day;
				hour   = date.hour;
				minute = date.minute;
				second = date.second;
				offset = 0;
				*/
			}
			
			DateTime toDateTime() {
				return DateTime(year + 1900, month, day, hour, minute, second);
			}
			
			string toString() {
				return std.string.format("Date(%04d-%02d-%02d %02d:%02d:%02d +%02d)", year + 1900, month, day, hour, minute, second, offset);
			}
		}
		
		enum Flags : u8 {
			Unknown1  = 1 << 0,
			Directory = 1 << 1,
			Unknown2  = 1 << 2,
			Unknown3  = 1 << 3,
			Unknown4  = 1 << 4,
			Unknown5  = 1 << 5,
		}
	
		u8     length;
		u8     extAttrLength;
		u32b   extent;
		u32b   size;
		Date   date; // 9.1.5 Recording Date and Time (BP 19 to 25)
		Flags  flags;
		u8     fileUnitSize;
		u8     interleave;
		u16b   volumeSequenceNumber;
		u8     nameLength;
		
		@property const ulong offset() {
			return extent.l * SECTOR_SIZE;
		}
		
		string toString() {
			return std.string.format("DirectoryRecord(offset=%08X, size=%d, date=%s, flags=%d)", offset, cast(uint)size, date, cast(uint)flags);
		}
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
		
		DirectoryRecord directoryRecord;
		
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
	
	class IsoNode {
		DirectoryRecord directoryRecord;
		IsoNode[] _childs;
		IsoNode[string] _childsByName;
		IsoNode[string] _childsByNameUpperCase;
		IsoNode _parent;
		string fullPath;
		string name;

		bool isDir() { return (directoryRecord.flags & DirectoryRecord.Flags.Directory) != 0; }
		IsoNode[] childs() { return _childs; }
		IsoNode parent() { return _parent; }
		
		protected IsoNode accessChild(string childName) {
			if (childName == "" || childName == ".") return this;
			if (childName == "..") return (parent !is null) ? parent : this;
			childName = std.string.toUpper(childName);
			if (childName !in _childsByNameUpperCase) {
				throw(new Exception(std.string.format("Can't find '%s' on '%s'", childName, this)));
			}
			return _childsByNameUpperCase[childName];
		}
		
		public IsoNode locate(string path) {
			int index = std.string.indexOf(path, '/');
			string childName, descendencyPath;
			if (index < 0) {
				childName = path;
				descendencyPath = "";
			} else {
				childName = path[0..index];
				descendencyPath = path[index + 1..$];
			}
			IsoNode childIsoNode = accessChild(childName);
			if (descendencyPath != "") childIsoNode = childIsoNode.locate(descendencyPath);
			return childIsoNode;
		}
		
		Stream open() {
			return new SliceStream(stream, directoryRecord.offset, directoryRecord.offset + cast(uint)directoryRecord.size); 
		}
		
		void saveTo(string outFileName = null) {
			if (outFileName is null) outFileName = this.name;
			BufferedFile outFile = new BufferedFile(outFileName, FileMode.OutNew);
			outFile.copyFrom(open);
			outFile.flush();
			outFile.close();
		}
		
		alias locate opIndex;
		
		this(DirectoryRecord directoryRecord, string name = "", IsoNode parent = null) {
			this._parent = parent;
			this.directoryRecord = directoryRecord;
			if (parent !is null) {
				this.fullPath = parent.fullPath ~ "/" ~ name;
			} else {
				this.fullPath = name;
			}
			this.name = name;
			
			//writefln("%s", this.fullPath);
		}
		
		public IsoRecursiveIterator descendency() {
			return new IsoRecursiveIterator(this);
		}
		
		int opApply(int delegate(ref IsoNode) dg) {
			int result = 0;
		
			foreach (child; _childs) {
			    result = dg(child);
			    if (result) break;
			}
			return result;
		}
		
		string toString() {
			return std.string.format("IsoNode('%s', %s)", fullPath, directoryRecord);
		}
	}
	
	class IsoRecursiveIterator {
		IsoNode isoNode;

		public this(IsoNode isoNode) {
			this.isoNode = isoNode;
		}
		
		int opApply(int delegate(ref IsoNode) dg) {
			int result = 0;
		
			foreach (child; isoNode) {
			    result = dg(child);
			    if (result) break;

			    if (child.isDir) {
			    	result = (new IsoRecursiveIterator(child)).opApply(dg);
			    	if (result) break;
			    }
			}
			return result;
		}
	}

	IsoNode rootIsoNode;
	PrimaryVolumeDescriptor primaryVolumeDescriptor;
	Stream stream;
	string isoPath;
	
	public IsoRecursiveIterator descendency() {
		return rootIsoNode.descendency;
	}
	
	public IsoNode locate(string path) {
		return rootIsoNode.locate(path);
	}
	
	alias locate opIndex;
	
	int opApply(int delegate(ref IsoNode) dg) {
		int result = 0;
	
		foreach (isoNode; rootIsoNode) {
		    result = dg(isoNode);
		    if (result) break;
		}
		return result;
	}
	
	protected void processDirectoryRecord(IsoNode parent) {
		ulong directoryStart  = parent.directoryRecord.extent.l * SECTOR_SIZE;
		ulong directoryLength = parent.directoryRecord.size.l;
		Stream directoryStream = new SliceStream(this.stream, directoryStart, directoryStart + directoryLength);
		
		while (!directoryStream.eof) {
			//writefln("%08X : %08X : %08X", directoryStream.position, directoryStart, directoryLength);
			ubyte l; directoryStream.read(l);
			
			// Even if a directory spans multiple sectors, the directory entries are not permitted to cross the sector boundary (unlike the path table).
			// Where there is not enough space to record an entire directory entry at the end of a sector, that sector is zero-padded and the next
			// consecutive sector is used.
			if (!l) {
				directoryStream.position = nextAlignedValue!ulong(directoryStream.position, SECTOR_SIZE);
				continue;
			}
			
			DirectoryRecord* directoryRecord;
			ubyte[] drd;
			drd.length = l;
			directoryStream.read(drd[1..drd.length]);
			directoryRecord = cast(DirectoryRecord*)drd.ptr;
			
			string name;
			if (directoryRecord.nameLength) {
				name = cast(string)drd[DirectoryRecord.sizeof..DirectoryRecord.sizeof + directoryRecord.nameLength];
			}
			
			if (name == "\x00" || name == "\x01") continue;
			
			name = std.encoding.sanitize(name);

			//writefln("   %s", name);
			
			IsoNode childIsoNode = new IsoNode(*directoryRecord, name, parent);
			parent._childs ~= childIsoNode;
			parent._childsByName[childIsoNode.name] = childIsoNode;
			parent._childsByNameUpperCase[std.string.toUpper(childIsoNode.name)] = childIsoNode;
		}
		
		foreach (child; parent._childs) {
			if (child.isDir) processDirectoryRecord(child);
		}
	}
	
	this() {
		
	}
	
	this(string path) {
		this(new BufferedFile(path, FileMode.In), path);
	}
	
	this(Stream stream, string path = "<unknown>") {
		load(stream, path);
	}
	
	void load(Stream stream, string path = "<unknown>") {
		this.isoPath = path;
		this.stream = stream;
		this.stream.position = SECTOR_SIZE * 0x10;
		this.stream.readExact(&primaryVolumeDescriptor, primaryVolumeDescriptor.sizeof);
		this.rootIsoNode = new IsoNode(primaryVolumeDescriptor.directoryRecord);
		processDirectoryRecord(this.rootIsoNode);
	}
	
	string toString() {
		return "Iso('" ~ isoPath ~ "')";
	}
}
