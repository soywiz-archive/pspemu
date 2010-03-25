module pspemu.hle.kd.usersystemlib; // kd/usersystemlib.prx (sceKernelLibrary)

import pspemu.hle.Module;
 
class Kernel_Library : Module {
	void initNids() {
		mixin(registerd!(0x092968F4, sceKernelCpuSuspendIntr));
		mixin(registerd!(0x5F10D406, sceKernelCpuResumeIntr));
	}

	/**
	 * Suspend all interrupts.
	 *
	 * @return The current state of the interrupt controller, to be used with ::sceKernelCpuResumeIntr().
	 */
	uint sceKernelCpuSuspendIntr() {
		unimplemented();
		return -1;
	}

	/**
	 * Resume all interrupts.
	 *
	 * @param flags - The value returned from ::sceKernelCpuSuspendIntr().
	 */
	void sceKernelCpuResumeIntr(uint flags) {
		unimplemented();
	}
}

static this() {
	mixin(Module.registerModule("Kernel_Library"));
}