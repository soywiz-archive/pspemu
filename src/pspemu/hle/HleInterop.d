module pspemu.hle.HleInterop;

import pspemu.hle.HleThread;

/**
 * Psp Callback.
 */
class PspCallback {
	/**
	 * Name of the callback.
	 */
	string name;

	/**
	 * Pointer to the callback function to execute.
	 */
	SceKernelCallbackFunction func;

	/**
	 * Argument to send to callback function.
	 */
	uint arg;
	
	/**
	 * Number of times the callback has been executed;
	 */
	uint notifyCount;

	/**
	 * Constructor.
	 */
	this(string name, SceKernelCallbackFunction func, uint arg) {
		this.name = name;
		this.func = func;
		this.arg  = arg;
	}
	
	void execute(HleEmulatorState hleEmulatorState, ThreadState threadState, uint[] arguments) {
		//writefln("Calling 0x%08X with arguments %s", pspCallback.func, arguments);
		hleEmulatorState.executeGuestCode(threadState, this.func, arguments);
		this.notifyCount++;
	}
	
	public string toString() {
		return std.string.format("PspCallback('%s', %08X, %08X, %d)", name, func, arg, notifyCount);
	}
}

class HleInterop {
	/**
	 * Executes a piece of PSP code on the current thread. Pausing the current execution.
	 */
	public uint executeCallbackNow(uint codeAddress, uint[] args) {
		HleThread thread = HleThread.current;
		Registers registers = thread.registers;
		
		uint retval;
		
		registers.restoreBlock({
			foreach (k, arg; args) registers.R[4 + k] = arg;
			registers.pcSet = codeAddress;
			thread.run();
			retval = registers.R[2];
		});
		
		return retval;
	}
	
	@property int numberOfScheduledCallbacks() {
		return 0;
	}
	
	/**
	 * Adds a callback to be executed on a Thread waiting for CB.
	 *
	 * @TODO: Args only supports integer values (not float or longs)
	 *
	 * @param  codeAddress  - Pointer to the function to execute.
	 * @param  args         - Args to pass to the function
	 */
	public void scheduleCallback(uint codeAddress, uint[] args) {
		
	}
	
	/**
	 * Executes all scheduled callbacks.
	 */
	public void executeScheduledCallbacks() {
		
	}
}