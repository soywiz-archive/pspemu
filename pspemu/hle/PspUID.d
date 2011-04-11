module pspemu.hle.PspUID;

import pspemu.All;

class PspUID {
	uint last_uid = 0;
	void*[uint] uids;
	
	synchronized uint alloc(T)(T value) {
		uint uid = last_uid++;
		uids[uid] = value;
		return uid;
	}
	
	synchronized void free(uint uid) {
		uids.remove(uid);
	}
	
	synchronized T get(T)(uint uid) {
		return cast(T)uids[uid];
	}
}