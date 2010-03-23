module pspemu.utils.VirtualFileSystem;

import std.stream, std.string, std.stdio, std.file, std.date;
import pspemu.utils.Utils;

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
		d_time time_c;
		d_time time_m;
		d_time time_a;
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
		auto separatorIndex = findIndex(index, "/");
		if (separatorIndex == -1) separatorIndex = index.length;

		string singleComponent = index[0..separatorIndex];

		// Has at least a separator
		if (separatorIndex != index.length) {
			string remainingComponents = index[separatorIndex + 1..$];
			while (remainingComponents.length && remainingComponents[0] == '/') remainingComponents = remainingComponents[1..$];

			// First character is '/' (so we should get the root node.
			if (!singleComponent.length) {
				return remainingComponents.length ? root[remainingComponents] : root;
			}
			// We have a selection first.
			else {
				return this[singleComponent][remainingComponents];
			}
		}
		// We have a single component
		else {
			VFS *node;
			if (singleComponent == ""  ) return this;
			if (singleComponent == "." ) return this;
			if (singleComponent == "..") return parentOrThis;
			if ((node = (singleComponent in childrenMounted)) !is null) return *node;
			if ((node = (singleComponent in children       )) !is null) return *node;
			throw(new Exception(std.string.format("Can't find component '%s' in '%s'", index, full_name)));
		}
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
		this.name = name;
		this.parent = parent;
	}

	this(VFS parent = null) {
		this.name = "<unknown>";
		this.parent = parent;
	}

	void addChild(VFS_Proxy node) {
		node.parent = this;
		this.childrenMounted[node.name] = node;
	}
	
	void addChild(VFS node, string name = null) {
		if (name is null) name = node.name;
		addChild(new VFS_Proxy(name, node));
	}

	string full_name() { return parent ? (parent.full_name ~ "/" ~ name) : (name); }
	bool is_root() { return (parent is null); }
	string toString() {
		//return full_name;
		return std.string.format("VFS('%s', %s)", full_name, stats);
	}

// To implement.
protected:
	bool implIsFile() { return !implIsDir; }
	bool implIsDir () { return true; }
	Stats implStats() { return Stats(); }
	VFS[] implList() { return []; }
	void   implMkdir(string path, int mode = 0777) { addChild(new VFS_Proxy(name, new VFS(name, this))); }
	Stream implOpen (string path, FileMode mode, int attr = 0777) { return new MemoryStream(); }

public final:
	void flush() {
		flushChildren();
		flushStats();
	}

	Stream open(string path, FileMode mode = FileMode.In, int attr = 0777) {
		int index = findLastIndex(path, "/");
		if (index != -1) return this[path[0..index]].open(path[index + 1..$], mode, attr);
		//assert(!isDir, "Can't open a directory");
		scope (exit) flush();
		return implOpen(path, mode, attr);
	}
	
	bool isFile() { return stats.isfile; }
	bool isDir () { return stats.isdir; }

	VFS mkdir(string path, int mode = 0777) {
		int index = findLastIndex(path, "/");
		if (index != -1) return this[path[0..index]].mkdir(path[index + 1..$], mode);
		//assert(!isDir, "Can't open a directory");
		implMkdir(path, mode);
		return this[path];
	}
}

class VFS_Proxy : VFS {
	VFS node;

	this(string name, VFS node, VFS parent = null) {
		this.name   = name;
		this.node   = node;
		this.parent = parent;
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
	Stream implOpen(string path, FileMode mode, int attr) { return node.implOpen(path, mode, attr); }
}

class FileSystem : VFS {
	bool _statsCached;
	Stats _stats;
	this(string path, VFS parent = null) {
		// Remove ending /
		while (path.length && path[$ - 1] == '/') path = path[0..$ - 1];

		super(path, parent);
	}
	VFS[] implList() {
		VFS[] nodes;
		auto cname = full_name;
		foreach (DirEntry file; dirEntries(cname, SpanMode.shallow)) {
			string file_name = file.name[cname.length + 1..$];
			auto node = new FileSystem(file_name, this);
			node._statsCached = true;
			node._stats = VFS.Stats(
				file_name,
				file.size, // size
				0,         // mode
				0,         // atrr
				file.creationTime,         // time_c
				file.lastWriteTime,         // time_m
				file.lastAccessTime,         // time_a
				file.isfile ? Type.File : Type.Directory
			);
			nodes ~= node;
		}
		return nodes;
	}
	Stats implStats() {
		if (!_statsCached) {
			string cname = full_name;
			_stats.phyname = name;
			_stats.mode = 0;
			_stats.attr = getAttributes(cname);
			_stats.size = getSize(cname);
			getTimes(cname, _stats.time_c, _stats.time_a, _stats.time_m);
			_stats.type = .isfile(cname) ? Type.File : Type.Directory;
			_statsCached = true;
		}
		return _stats;
	}
	void implMkdir(string name, int mode = 0777) {
		mkdir(full_name ~ "/" ~ name);
		flushChildren();
	}
	void implRmdir(string name) {
		rmdir(full_name ~ "/" ~ name);
		flushChildren();
	}
	Stream implOpen(string name, FileMode mode, int attr) {
		return new std.stream.File(full_name ~ "/" ~ name, mode);
	}
}

/*
void main() {
	auto path = new FileSystem("../..");
	path.addChild(new VFS_Proxy("demos", new FileSystem(".")));
	auto s = path.open("/demos/lol.txt", FileMode.OutNew);
	
	//foreach (e; path["/demos"]) writefln("%s", e);
}
*/