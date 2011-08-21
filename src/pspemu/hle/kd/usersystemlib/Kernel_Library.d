module pspemu.hle.kd.usersystemlib.Kernel_Library;

import pspemu.hle.ModuleNative;
import pspemu.core.cpu.CpuThreadBase;

/**
 * @note
 * On a multithreaded enviroment, having disabled the interrupts probably means
 * no having thread switching. So probably to emulate a suspend and resume,
 * we would have to pause and resume all threads.
 */
class Kernel_Library : HleModuleHost {
	mixin TRegisterModule;
	
	void initNids() {
		mixin(registerFunction!(0x092968F4, sceKernelCpuSuspendIntr));
		mixin(registerFunction!(0x5F10D406, sceKernelCpuResumeIntr));
	}
	
	const int Enabled  = 1;
	const int Disabled = 0;
	
	ref bool enabledInterrupts() {
		return hleEmulatorState.emulatorState.enabledInterrupts;
	}
	
	/**
	 * Suspend all interrupts.
	 *
	 * @return The current state of the interrupt controller, to be used with ::sceKernelCpuResumeIntr().
	 */
	uint sceKernelCpuSuspendIntr() {
		synchronized (this) {
			if (enabledInterrupts()) {
				ThreadState.suspendAllCpuThreadsButThis();
				enabledInterrupts() = false;
				return Enabled;
			} else {
				return Disabled;
			}
		}
	}
	
	/**
	 * Resume/Enable all interrupts.
	 *
	 * @param flags - The value returned from ::sceKernelCpuSuspendIntr().
	 */
	void sceKernelCpuResumeIntr(bool set) {
		synchronized (this) {
			if (set == Enabled) {
				enabledInterrupts() = true;
				ThreadState.resumeAllCpuThreadsButThis();
			} else {
				ThreadState.suspendAllCpuThreadsButThis();
				enabledInterrupts() = false;
			}
		}
	}
}
