module pspemu.hle.kd.loadexec.sceDmac;

import pspemu.hle.ModuleNative;

class sceDmac : HleModuleHost {
	mixin TRegisterModule;
	
	void initNids() {
		mixin(registerFunction!(0x617F3FE6, sceDmacMemcpy));
		mixin(registerFunction!(0xD97F94D8, sceDmacTryMemcpy));
	}
	
	/**
	 * Copies data using the internal DMAC. Should be faster than a memcpy,
	 * but requires that data to be copied is no more in the cache, so usually
	 * you should issue a oslUncacheData on the source and destination addresses
	 * else very strange bugs may happen.
	 */
	int sceDmacMemcpy(ubyte *dest, ubyte *source, uint size) {
	//ubyte* sceDmacMemcpy(ubyte *dest, ubyte *source, uint size) {
		dest[0..size] = source[0..size];
		//return dest;
		return 0;
	}
	
	alias sceDmacMemcpy sceDmacTryMemcpy;
}
