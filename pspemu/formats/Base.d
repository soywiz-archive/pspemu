module pspemu.formats.Base;

public import std.stdio, std.string, std.stream, std.file, std.path, std.date, std.intrinsic;

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
