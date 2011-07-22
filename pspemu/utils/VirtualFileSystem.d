module pspemu.utils.VirtualFileSystem;

import std.stream;
import std.string;
import std.stdio;
import std.file;
import std.path;
import std.datetime;
import std.conv;

class VFS {
	enum Type {
		Directory,
		File,
		Unknown
	}
	struct Stats {
		string phyname;
		ulong size;
		uint mode;
		uint attr;
		SysTime time_c;
		SysTime time_m;
		SysTime time_a;
		Type type;

		bool isfile() { return type == Type.File; }
		bool isdir () { return type == Type.Directory; }
		string toString() {
			return std.string.format(
				"Stats("
				//"phyname='%s',"
				"size=%d, mode=0%03o, attr=0x%04X"
				//", ctime=%s, mtime=%s, atime=%s"
				", type:%s)",
				//phyname,
				size, mode, attr,
				//std.date.toString(time_c), std.date.toString(time_m), std.date.toString(time_a),
				isfile ? "file" : "directory"
			);
		}
	}
	//bool caseInsensitive = false;
	bool caseInsensitive = true;
	VFS parent;
	string name;
	private bool _statsCached;
	private Stats _stats;
	Stats stats() {
		if (!_statsCached) {
			_stats = implStats();
			_statsCached = true;
		}
		return _stats;
	}
	void flushStats() {
		_statsCached = true;
	}

	VFS opIndex(string index) {
		return access(index, false);
	}

	/*VFS opIndexAssign(VFS newNode, string index) {
		int lastSepIndex = index.lastIndexOf('/');
		VFS base = this;
		if (lastSepIndex != -1) {
			base = base.access(index[0..lastSepIndex], true);
			index = index[lastSepIndex + 1..$];
		}
		return base.childrenMounted[index] = newNode;
	}*/

	VFS opCatAssign(VFS newNode) {
		return this.childrenMounted[newNode.name] = newNode;
	}

	VFS access(string index, bool create = false) {
		//writefln("access('%s')", index);
		auto separatorIndex = index.indexOf("/");
		if (separatorIndex == -1) separatorIndex = index.length;

		string singleComponent = index[0..separatorIndex];

		// Has at least a separator
		if (separatorIndex != index.length) {
			string remainingComponents = index[separatorIndex + 1..$];
			while (remainingComponents.length && remainingComponents[0] == '/') remainingComponents = remainingComponents[1..$];

			// First character is '/' (so we should get the root node.
			if (!singleComponent.length) {
				return remainingComponents.length ? root.access(remainingComponents, create) : root;
			}
			// We have a selection first.
			else {
				return this.access(singleComponent, create).access(remainingComponents, create);
			}
		}
		// We have a single component
		else {
			if (singleComponent == ""  ) return this;
			if (singleComponent == "." ) return this;
			if (singleComponent == "..") return parentOrThis;
			if (auto node = contains(singleComponent, create)) return node;
			throw(new Exception("Can't find component '" ~ index ~ "' in '" ~ full_name ~ "' (create:" ~ create ~ ")"));
		}
	}

	VFS contains(string index, bool create = false) {
		//writefln("[1]");
		//writefln(" ** %s (%d)", index, caseInsensitive);
		if (caseInsensitive) {
			string singleComponentLower = std.string.toLower(index);
			foreach (key; childrenMounted.keys) {
				if (std.string.toLower(key) == singleComponentLower) {
					//writefln("GET_MOUNTED :: %s", childrenMounted[key]);
					return childrenMounted[key];
				}
			}
			foreach (key; children.keys) if (std.string.toLower(key) == singleComponentLower) return children[key];
		} else {
			VFS* node;
			if ((node = (index in childrenMounted)) !is null) return *node;
			if ((node = (index in children       )) !is null) return *node;
		}
		//writefln("[2]");

		if (auto node = implContains(index, create)) {
			_childrenCached = false;
			return node;
		}
		
		//writefln("[3]");

		return null;
	}
	
	private VFS[string] childrenMounted;
	private VFS[string] _children;
	private bool _childrenCached;
	final VFS[string] children() {
		if (!_childrenCached) {
			_children = null;
			foreach (child; implList) {
				_children[child.name] = child;
			}
			_childrenCached = true;
		}
		return _children;
	}
	void flushChildren() {
		_childrenCached = false;
	}

	VFS parentOrThis() {
		return parent ? parent : this;
	}

	/**
	 * Obtains the root node.
	 */
	VFS root() {
		return parent ? parent.root : this;
	}

	int opApply(int delegate(ref VFS) dg) {
		int result = 0;

		foreach (child; childrenMounted) {
			result = dg(child);
			if (result) break;
		}

		foreach (name, child; children) {
			if (name in childrenMounted) continue;
			result = dg(child);
			if (result) break;
		}

		return result;
	}

	this(string name, VFS parent = null) {
		this.name   = name;
		this.parent = parent;
	}

	void addChild(VFS_Proxy node) {
		node.parent = this;
		this.childrenMounted[node.name] = node;
		//writefln("MOUNTED '%s' / '%s' / '%s'", this, node.name, node);
	}
	
	void addChild(VFS node, string name = null) {
		if (name is null) name = node.name;
		addChild(new VFS_Proxy(name, node));
	}

	string full_name() { return parent ? (parent.full_name ~ "/" ~ name) : (name); }
	bool is_root() { return (parent is null); }
	string toString() {
		//return full_name;
		return "VFS('" ~ full_name ~ "', " ~ stats.toString ~ ")";
	}

// To implement.
protected:
	VFS    implContains(string index, bool create = false) { return null; }
	bool   implIsFile() { return !implIsDir; }
	bool   implIsDir () { return true; }
	Stats  implStats() { return Stats(); }
	VFS[]  implList() { return []; }
	VFS    implMkdir(string path, int mode = octal!777) {
		writefln("Dummy MKDIR!");
		addChild(new VFS_Proxy(name, new VFS(name, this))); flushChildren(); return this[name];
	}
	Stream implOpen (string path, FileMode mode, int attr = octal!777) { return new MemoryStream(); }
	void   implFlush() { }

public final:
	void flush() {
		flushChildren();
		flushStats();
		implFlush();
	}

	Stream open(string path, FileMode mode = FileMode.In, int attr = octal!777) {
		//.writefln("open[0]:%s", path);
		int index = path.lastIndexOf("/");
		if (index != -1) return this[path[0..index]].open(path[index + 1..$], mode, attr);
		//assert(!isDir, "Can't open a directory");
		scope (exit) flush();
		return implOpen(path, mode, attr);
	}
	
	bool isFile() { return stats.isfile; }
	bool isDir () { return stats.isdir; }

	VFS mkdir(string path, int mode = octal!777) {
		VFS vfs = this;
		while (path.length && path[0] == '/') path = path[1..$];
		int index = path.lastIndexOf("/");
		if (index != -1) {
			vfs = this[path[0..index]];
			path = path[index + 1..$];
		}
		
		writefln("!!MKDIR('%s', '%s')", this, path);
		//assert(!isDir, "Can't open a directory");
		//scope (exit) vfs.flush();
		return vfs.implMkdir(path, mode);
	}
}

class VFS_Proxy : VFS {
	VFS node;

	this(string name, VFS node, VFS parent = null) {
		this.node = node;
		super(name, parent);
	}

	void flushChildren() { node.flushChildren(); }
	void flushStats() { node.flushStats(); }
	Stats implStats() { return node.stats; }
	VFS[] implList() {
		VFS[] nodes;
		foreach (child; node.children) {
			nodes ~= new VFS_Proxy(child.name, child, this);
		}
		return nodes;
	}

	override VFS implMkdir(string path, int mode = octal!777) {
		return node.implMkdir(path, mode);
	}
	
	Stream implOpen(string path, FileMode mode, int attr) {
		return node.implOpen(path, mode, attr);
	}
	
	string toString() {
		return node.toString;
	}
}

class FileSystem : VFS {
	string filesystem_path;
	
	string toString() {
		return "FileSystem('" ~ filesystem_path ~ "')";
	}
	
	bool _statsCached;
	Stats _stats;
	this(string path, string name = null, VFS parent = null) {
		//if (!path.exists) throw(new Exception(std.string.format("Path '%s' doesn't exists", path)));
		// Remove ending /
		while (path.length && path[$ - 1] == '/') path = path[0..$ - 1];
		
		if (name is null) name = std.path.basename(path);
		
		this.filesystem_path = path;
	
		super(name, parent);
	}
	VFS[] implList() {
		VFS[] nodes;
		auto cname = filesystem_path;
		//writefln("%s", cname);
		if (!std.file.isDir(cname)) {
			throw(new Exception("Dir not found '" ~ cname ~ "'"));
		}
		//writefln("LISTING :: %s; %s", filesystem_path, this);
		foreach (DirEntry file; dirEntries(cname, SpanMode.shallow)) {
			string file_name = file.name[cname.length + 1..$];
			//writefln("%s", file_name);
			auto node = new FileSystem(this.filesystem_path ~ "/" ~ file_name, file_name, this);
			node._statsCached = true;
			//writefln("--%s", file);
			node._stats = VFS.Stats(
				file_name,
				file.size, // size
				0,         // mode
				0,         // atrr
				file.timeCreated,         // time_c
				file.timeLastModified,    // time_m
				file.timeLastAccessed,    // time_a
				file.isfile ? Type.File : Type.Directory
			);
			//writefln("[2]");
			nodes ~= node;
		}
		return nodes;
	}
	Stats implStats() {
		if (!_statsCached) {
			string cname = filesystem_path;
			_stats.phyname = name;
			_stats.mode = 0;
			_stats.attr = getAttributes(cname);
			_stats.size = getSize(cname);
			auto file = dirEntry(cname);
			_stats.time_c = file.timeCreated;
			_stats.time_m = file.timeLastModified;
			_stats.time_a = file.timeLastAccessed;

			//getTimes(cname, _stats.time_c, _stats.time_a, _stats.time_m);
			_stats.type = .isfile(cname) ? Type.File : Type.Directory;
			_statsCached = true;
		}
		return _stats;
	}
	override VFS implMkdir(string name, int mode = octal!777) {
		//writefln("::MKDIR('%s', '%s')", full_name, name);
		std.file.mkdir(filesystem_path ~ "/" ~ name);
		flushChildren();
		return this[name];
	}
	void implRmdir(string name) {
		//.writefln("implRmdir()");
		std.file.rmdir(filesystem_path ~ "/" ~ name);
		flushChildren();
	}
	Stream implOpen(string name, FileMode mode, int attr) {
		//.writefln("%s", name);
		//writefln("implOpen(%s, %s)", full_name ~ "/" ~ name, to!string(mode));
		
		//writefln("OPEN_NODE :: %s", this);
		
		if (mode == FileMode.In) {
			return new std.stream.BufferedFile(filesystem_path ~ "/" ~ name, mode);
		} else {
			return new std.stream.File(filesystem_path ~ "/" ~ name, mode);
		}
		//return new std.stream.BufferedFile(full_name ~ "/" ~ name, mode);
	}
}

/*
void main() {
	auto path = new FileSystem("../..");
	path.addChild(new VFS_Proxy("demos", new FileSystem(".")));
	//auto s = path.open("/demos/lol.txt", FileMode.OutNew);
	//try { path.mkdir("/demos/prueba"); } catch { }
	//path.mkdir("/demos/prueba/test");

	VFS ms0root, gameroot;
	ms0root = new VFS("<root>");

	ms0root.addChild(new FileSystem("../../pspfs/ms0"), "ms0:");
	ms0root.addChild(new FileSystem("../../pspfs/flash0"), "flash0:");
	ms0root["ms0:"].mkdir("/PSP");
	ms0root["ms0:"].mkdir("/PSP/SAVES");
}
*/