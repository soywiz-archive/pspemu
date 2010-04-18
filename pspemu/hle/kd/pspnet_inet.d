module pspemu.hle.kd.pspnet_inet; // kd/pspnet_inet.prx (sceNetInet_Library)

//debug = DEBUG_SYSCALL;

import pspemu.hle.Module;

struct sockaddr;
struct in_addr;

class sceNetInet_lib : Module {
	void initNids() {
		mixin(registerd!(0x4A114C7C, sceNetInetGetsockopt));
		mixin(registerd!(0x2FE71FE7, sceNetInetSetsockopt));
		mixin(registerd!(0xFBABE411, sceNetInetGetErrno));
		
		mixin(registerd!(0x17943399, sceNetInetInit));
		mixin(registerd!(0xA9ED66B9, sceNetInetTerm));
		mixin(registerd!(0xDB094E1B, sceNetInetAccept));
		mixin(registerd!(0x1A33F9AE, sceNetInetBind));
		mixin(registerd!(0x8D7284EA, sceNetInetClose));
		mixin(registerd!(0x410B34AA, sceNetInetConnect));
		mixin(registerd!(0xD10A1A7A, sceNetInetListen));
		mixin(registerd!(0xCDA85C99, sceNetInetRecv));
		mixin(registerd!(0x7AA671BC, sceNetInetSend));
		mixin(registerd!(0x8B7B220F, sceNetInetSocket));
		mixin(registerd!(0x1BDF5D13, sceNetInetInetAton));
		mixin(registerd!(0xC91142E4, sceNetInetRecvfrom));
		mixin(registerd!(0x05038FC7, sceNetInetSendto));
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

	int sceNetInetInit() { unimplemented(); return -1; }
	int sceNetInetTerm() { unimplemented(); return -1; }
	int	sceNetInetAccept(int s, sockaddr* addr, socklen_t* addrlen) { unimplemented(); return -1; }
	int	sceNetInetBind(int s, sockaddr* my_addr, socklen_t addrlen) { unimplemented(); return -1; }
	int sceNetInetClose(int s) { unimplemented(); return -1; }
	int	sceNetInetConnect(int s, sockaddr* serv_addr, socklen_t addrlen) { unimplemented(); return -1; }
	int	sceNetInetListen(int s, int backlog) { unimplemented(); return -1; }
	size_t sceNetInetRecv(int s, void* buf, size_t len, int flags) { unimplemented(); return -1; }
	size_t sceNetInetSend(int s, void* buf, size_t len, int flags) { unimplemented(); return -1; }
	int	sceNetInetSocket(int domain, int type, int protocol) { unimplemented(); return -1; }
	int sceNetInetInetAton(string host, in_addr* addr) { unimplemented(); return -1; }
	size_t sceNetInetRecvfrom(int s, void* buf, size_t flags, int, sockaddr* from, socklen_t* fromlen) { unimplemented(); return -1; }
	size_t sceNetInetSendto(int s, void* buf, size_t len, int flags, sockaddr* to, socklen_t tolen) { unimplemented(); return -1; }
}

class sceNetInet : sceNetInet_lib {
}

static this() {
	mixin(Module.registerModule("sceNetInet_lib"));
	mixin(Module.registerModule("sceNetInet"));
}