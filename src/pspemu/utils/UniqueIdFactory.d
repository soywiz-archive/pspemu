module pspemu.utils.UniqueIdFactory;

import std.string;

alias int UID;

class UniqueIdException : Exception { this(string msg, string file = __FILE__, size_t line = __LINE__, Throwable next = null) { super(msg, file, line, next); } }
class UniqueIdNotFoundException : UniqueIdException { this(string msg, string file = __FILE__, size_t line = __LINE__, Throwable next = null) { super(msg, file, line, next); } }

class UniqueIdFactory {
	private UniqueIdTypeFactory[string] _factoryPerType;
	
	protected UniqueIdTypeFactory factoryPerType(T)(bool createIfNotExists) {
		//if (createIfNotExists)
		{
			if ((T.stringof in _factoryPerType) is null) _factoryPerType[T.stringof] = new UniqueIdTypeFactory(T.stringof);
		}
		return _factoryPerType[T.stringof];
	}
	
	public UID add(T)(T value) {
		return factoryPerType!T(true).newUid(value);
	}

	public UID set(T)(UID uid, T value) {
		return factoryPerType!T(true).set(uid, value);
	}
	
	public T get(T)(UID uid) {
		return factoryPerType!T(false).get!(T)(uid);
	}
	
	public void remove(T)(UID uid) {
		factoryPerType!T(false).remove(uid);
	}
}

class UniqueIdTypeFactory {
	string type;
	UID last = 1;
	Object[UID] values;
	
	this(string type) {
		this.type = type;
	}
	
	public UID set(UID uid, Object value) {
		synchronized (this) {
			values[uid] = value;
			if (last < uid + 1) last = uid + 1; 
			return uid;
		}
	}

	public UID newUid(Object value) {
		synchronized (this) {
			while (true) {
				UID current = last++;
				if (current in values) continue;
				values[current] = value;
				return current;
			}
		}
	}

	public T get(T)(UID uid) {
		synchronized (this) {
			if (uid !in values) throw(new UniqueIdNotFoundException(std.string.format("Can't find %s:%d(%08X)", type, uid, uid)));
			return cast(T)values[uid];
		}
	}
	
	public void remove(UID uid) {
		synchronized (this) {
			values.remove(uid);
		}
	}
}