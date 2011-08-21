module pspemu.hle.kd.pspnet.sceNetResolver;

import pspemu.hle.ModuleNative;
import pspemu.hle.kd.pspnet.Types;

class sceNetResolver : HleModuleHost {
	mixin TRegisterModule;

	void initNids() {
		mixin(registerFunction!(0x244172AF, sceNetResolverCreate));
		mixin(registerFunction!(0x94523E09, sceNetResolverDelete));
		mixin(registerFunction!(0x224C5F44, sceNetResolverStartNtoA));
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
	int sceNetResolverCreate(int *rid, void *buf, SceSize buflen) {
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

}
