module pspemu.hle.kd.systimer; // kd/systimer.prx (sceSystimer)

import pspemu.hle.Module;

alias int SceSysTimerId;

class SysTimerForKernel : Module {
	void initNids() {
		mixin(registerd!(0xC99073E3, sceSTimerAlloc));
		mixin(registerd!(0x975D8E84, sceSTimerSetHandler));
		mixin(registerd!(0xA95143E2, sceSTimerStartCount));
	}

	/**
	 * Allocate a new SysTimer timer instance.
	 *
	 * @return SysTimerId on success, < 0 on error
	 */
	SceSysTimerId sceSTimerAlloc() {
		unimplemented();
		return -1;
	}

	/**
	 * Setup a SysTimer handler
	 *
	 * @param timer - The timer id.
	 * @param cycle - The timer cycle in microseconds (???). Maximum: 4194303 which represents ~1/10 seconds.
	 * @param handler - The handler function. Has to return -1.
	 * @param unk1 - Unknown. Pass 0.
	 */
	//void sceSTimerSetHandler(SceSysTimerId timer, int cycle, int (*handler)(void), int unk1) {
	void sceSTimerSetHandler(SceSysTimerId timer, int cycle, uint handler, int unk1) {
		unimplemented();
	}

	/**
	 * Start the SysTimer timer count.
	 *
	 * @param timer - The timer id.
	 *
	 */
	void sceSTimerStartCount(SceSysTimerId timer) {
		unimplemented();
	}
}

static this() {
	mixin(Module.registerModule("SysTimerForKernel"));
}
