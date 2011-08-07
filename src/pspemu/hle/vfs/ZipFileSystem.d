module pspemu.hle.vfs.ZipFileSystem;

public import pspemu.hle.vfs.VirtualFileSystem;
import pspemu.utils.Expression;

import std.stdio;
import std.stream;
import std.string;
import std.array;
import std.datetime;
import std.conv;

public import std.zip;

/*

class IsoDirHandle : DirHandle {
	Iso.IsoNode isoNode;
	int currentIndex;

	this(VirtualFileSystem virtualFileSystem, Iso.IsoNode isoNode) {
		super(virtualFileSystem);
		this.isoNode = isoNode;
		this.currentIndex = 0;
	}
	
	bool hasMore() {
		return (currentIndex < isoNode.childs.length);
	}
	
	Iso.IsoNode next() {
		if (currentIndex < isoNode.childs.length) {
			return isoNode.childs[currentIndex++];
		} else {
			//return null;
			throw(new Exception("No more entries"));
		}
	}
}
*/

FileStat zipMemberToFileStat(ZipFileSystem zipFileSystem, ArchiveMember archiveMember) {
	FileStat fileStat = new FileStat(zipFileSystem);
	{
		fileStat.atime = DosFileTimeToSysTime(archiveMember.time);
		fileStat.ctime = DosFileTimeToSysTime(archiveMember.time);
		fileStat.mtime = DosFileTimeToSysTime(archiveMember.time);
		fileStat.isDir = false;
		fileStat.isRoot = false;
		fileStat.size = archiveMember.expandedSize;
	}
	return fileStat;
}

class ZipNode {
	ArchiveMember archiveMember;
	ZipNode[] childs;
}

class ZipFileSystem : VirtualFileSystem {
	ZipArchive zipArchive;

	public this(ZipArchive zipArchive) {
		this.zipArchive = zipArchive;
	}
	

	ArchiveMember getArchiveMember(string file) {
		if (!(file in this.zipArchive.directory)) {
			throw(new FileNotExistsException("File not exists '" ~ file ~ "'"));
		}
		return this.zipArchive.directory[file];
	}

	override FileHandle open(string file, FileOpenMode flags, FileAccessMode mode) {
		ArchiveMember member = getArchiveMember(file);
		this.zipArchive.expand(member);
		return new StreamFileHandle(this, new MemoryStream(member.expandedData));
	}
	
	mixin VirtualFileSystem_Stream;

	override FileStat getstat(string file) {
		ArchiveMember member = getArchiveMember(file);
		return zipMemberToFileStat(this, member);
	}
	
	/*
	override DirHandle dopen(string file) {
		return new IsoDirHandle(this, iso.locate(file));
	}

	override void dclose(DirHandle handle) {
	}
	
	override FileEntry dread(DirHandle handle) {
		IsoDirHandle isoDirHandle = cast(IsoDirHandle)handle;
		if (isoDirHandle.hasMore) {
			return isoNodeToFileEntry(this, isoDirHandle.next());
		} else {
			return null;
		}
	}
	
	*/
}