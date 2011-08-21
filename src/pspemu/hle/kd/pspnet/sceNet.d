module pspemu.hle.kd.pspnet.sceNet;

import pspemu.hle.ModuleNative;
import pspemu.hle.kd.pspnet.Types;

struct SceNetMallocStat {
	int pool;
	int maximum;
	int free;
}

class sceNet : HleModuleHost {
	mixin TRegisterModule;

	void initNids() {
        mixin(registerFunction!(0x39AF39A6, sceNetInit));
        mixin(registerFunction!(0x281928A9, sceNetTerm));
        mixin(registerFunction!(0x50647530, sceNetFreeThreadinfo));
        mixin(registerFunction!(0xAD6844c6, sceNetThreadAbort));
        mixin(registerFunction!(0x89360950, sceNetEtherNtostr));
        mixin(registerFunction!(0xD27961C9, sceNetEtherStrton));
        //mixin(registerFunction!(0xF5805EFE, sceNetHtonl));
        //mixin(registerFunction!(0x39C1BF02, sceNetHtons));
        //mixin(registerFunction!(0x93C4AF7E, sceNetNtohl));
        //mixin(registerFunction!(0x4CE03207, sceNetNtohs));
        mixin(registerFunction!(0x0BF0A3AE, sceNetGetLocalEtherAddr));
        mixin(registerFunction!(0xCC393E48, sceNetGetMallocStat));
	}
	
	/**
	 * Initialise the networking library
	 *
	 * @param poolsize - Memory pool size (appears to be for the whole of the networking library).
	 * @param calloutprio - Priority of the SceNetCallout thread.
	 * @param calloutstack - Stack size of the SceNetCallout thread (defaults to 4096 on non 1.5 firmware regardless of what value is passed).
	 * @param netintrprio - Priority of the SceNetNetintr thread.
	 * @param netintrstack - Stack size of the SceNetNetintr thread (defaults to 4096 on non 1.5 firmware regardless of what value is passed).
	 *
	 * @return 0 on success, < 0 on error
	 */
	int sceNetInit(int poolsize, int calloutprio, int calloutstack, int netintrprio, int netintrstack) {
		unimplemented_notice();
		return -1;
	}
		
	/**
	 * Terminate the networking library
	 *
	 * @return 0 on success, < 0 on error
	 */
	int sceNetTerm() {
		unimplemented();
		return -1;
	}
	
	/**
	 * Free (delete) thread info/data
	 *
	 * @param thid - The thread id.
	 *
	 * @return 0 on success, < 0 on error
	 */
	int sceNetFreeThreadinfo(int thid) {
		unimplemented();
		return -1;
	}
	
	/**
	 * Abort a thread
	 *
	 * @param thid - The thread id.
	 *
	 * @return 0 on success, < 0 on error
	 */
	int sceNetThreadAbort(int thid) {
		unimplemented();
		return -1;
	}
	
	/**
	 * Convert string to a Mac address
	 *
	 * @param name - The string to convert.
	 * @param mac - Pointer to a buffer to store the result.
	 */
	void sceNetEtherStrton(string name, ubyte* mac) {
		unimplemented();
	}
	
	/**
	 * Convert Mac address to a string
	 *
	 * @param mac - The Mac address to convert.
	 * @param name - Pointer to a buffer to store the result.
	 */
	void sceNetEtherNtostr(ubyte* mac, char* name) {
		unimplemented();
	}
	
	/**
	 * Retrieve the local Mac address
	 *
	 * @param mac - Pointer to a buffer to store the result.
	 *
	 * @return 0 on success, < 0 on error
	 */
	int sceNetGetLocalEtherAddr(ubyte* mac) {
		unimplemented();
		return -1;
	}
	
	/**
	 * Retrieve the networking library memory usage
	 *
	 * @param stat - Pointer to a ::SceNetMallocStat type to store the result.
	 *
	 * @return 0 on success, < 0 on error
	 */
	int sceNetGetMallocStat(SceNetMallocStat *stat) {
		unimplemented();
		return -1;
	}
}
