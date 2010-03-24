module pspemu.hle.kd.pspnet_inet; // kd/pspnet_inet.prx (sceNetInet_Library)

//debug = DEBUG_SYSCALL;

import pspemu.hle.Module;

class sceNetInet_lib : Module {
	void initNids() {
		mixin(registerd!(0x4A114C7C, sceNetInetGetsockopt));
		mixin(registerd!(0x2FE71FE7, sceNetInetSetsockopt));
		mixin(registerd!(0xFBABE411, sceNetInetGetErrno));
	}

	alias uint socklen_t;
	
	int	sceNetInetGetsockopt(int s, int level, int optname, void *optval, socklen_t* optlen) {
		unimplemented();
		return -1;
	}

	int	sceNetInetSetsockopt(int s, int level, int optname, const void* optval, socklen_t optlen) {
		unimplemented();
		return -1;
	}

	int sceNetInetGetErrno() {
		unimplemented();
		return -1;
	}
}

class sceNetInet : sceNetInet_lib {
}

static this() {
	mixin(Module.registerModule("sceNetInet_lib"));
	mixin(Module.registerModule("sceNetInet"));
}