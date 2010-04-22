module pspemu.hle.kd.pspnet_resolver; // kd/pspnet_resolver.prx (sceNetResolver_Library)

//debug = DEBUG_SYSCALL;

import pspemu.hle.Module;

struct in_addr;

class sceNetResolver : Module {
	void initNids() {
		mixin(registerd!(0xF3370E61, sceNetResolverInit));
		mixin(registerd!(0x6138194A, sceNetResolverTerm));
		mixin(registerd!(0x244172AF, sceNetResolverCreate));
		mixin(registerd!(0x224C5F44, sceNetResolverStartNtoA));
		mixin(registerd!(0x94523E09, sceNetResolverDelete));
	}

	/**
	 * Inititalise the resolver library
	 *
	 * @return 0 on sucess, < 0 on error.
	 */
	int sceNetResolverInit() {
		unimplemented();
		return -1;
	}

	/**
	 * Terminate the resolver library
	 *
	 * @return 0 on success, < 0 on error
	 */
	int sceNetResolverTerm() {
		unimplemented();
		return -1;
	}

	/**
	 * Create a resolver object
	 *
	 * @param rid - Pointer to receive the resolver id
	 * @param buf - Temporary buffer
	 * @param buflen - Length of the temporary buffer
	 *
	 * @return 0 on success, < 0 on error
	 */
	int sceNetResolverCreate(int* rid, void* buf, SceSize buflen) {
		unimplemented();
		return -1;
	}

	/**
	 * Begin a name to address lookup
	 *
	 * @param rid - Resolver id
	 * @param hostname - Name to resolve
	 * @param addr - Pointer to in_addr structure to receive the address
	 * @param timeout - Number of seconds before timeout
	 * @param retry - Number of retires
	 *
	 * @return 0 on success, < 0 on error
	 */
	int sceNetResolverStartNtoA(int rid, string hostname, in_addr* addr, uint timeout, int retry) {
		unimplemented();
		return -1;
	}

	/**
	 * Delete a resolver
	 *
	 * @param rid - The resolver to delete
	 *
	 * @return 0 on success, < 0 on error
	 */
	int sceNetResolverDelete(int rid) {
		unimplemented();
		return -1;
	}
}

static this() {
	mixin(Module.registerModule("sceNetResolver"));
}