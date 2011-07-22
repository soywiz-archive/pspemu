module pspemu.utils.StructUtils;

ubyte[] TA(T)(ref T v) {
	return cast(ubyte[])((&v)[0..1]);
}

void swap(T)(ref T a, ref T b) {
	T t;
	t = a;
	a = b;
	b = t;
}

ushort SwapBytes(ushort v) {
	return cast(ushort)(v >> 8) | cast(ushort)(v << 8);
}

ushort bswap16(ushort v) { return cast(ushort)((v >> 8) | (v << 8)); }
uint   bswap32(uint v) { return cast(uint)(bswap16(v >> 16) | (bswap16(cast(ushort)v) << 16)); }

struct be(T) {
	T v;
	
	this(T that) {
		//opAssign(that); // Regression on v2.054
		v = swap(that);
	}
	
	static T swap(T)(T v) {
		static if (T.sizeof == 2u) return cast(ushort)bswap16(cast(ushort)v);
		static if (T.sizeof == 4u) return cast(uint)bswap32(cast(uint)v);
		else return -1;
		//pragma(msg, T.sizeof);
		//static assert(0);
	}
	
	static be!T opCall(T vv) {
		be!T v = void;
		v.v = swap(vv);
		return v;
	}
	
	void opAssign(T that) {
		v = swap(that);
	}
	
	@property T v_be() {
		return swap(v);
	}
	
	alias v_be this;
}
