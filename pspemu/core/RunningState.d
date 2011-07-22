module pspemu.core.RunningState;

import pspemu.utils.Event;
import pspemu.utils.Logger;

import pspemu.core.exceptions.HaltException;

public import pspemu.utils.sync.WaitEvent;

class RunningState {
	/**
	 * @deprecated use stopEvent instead.
	 */
	public bool running = true;

	/**
	 * @deprecated use stopEvent instead.
	 */
	Event onStop;

	/**
	 * @deprecated use stopEvent instead.
	 */
	Event onStopCpu;
	
	/**
	 * Will trigger when the execution is being stopped.
	 */
	WaitEvent stopEvent;

	/**
	 * Will trigger when the execution is being stopped.
	 */
	WaitEvent stopEventCpu;
	
	this() {
		stopEvent = new WaitEvent("stopEvent");
		stopEvent.callback = delegate(Object object) {
			Logger.log(Logger.Level.WARNING, "RunningState", "Launching stopEvent");
			throw(new HaltException("Halt"));
		};

		stopEventCpu = new WaitEvent("stopEventCpu");
		stopEventCpu.callback = delegate(Object object) {
			Logger.log(Logger.Level.WARNING, "RunningState", "Launching stopEventCpu");
			throw(new HaltException("Halt"));
		};
	}
	
	public void reset() {
		this.running = true;
		onStop.reset();
		onStopCpu.reset();
		stopEvent.reset();
		stopEventCpu.reset();
	}

	public void stop() {
		Logger.log(Logger.Level.INFO, "RunningState.stop");
		onStop();
		running = false;
		stopEvent.signal();
		stopCpu();
	}

	public void stopCpu() {
		Logger.log(Logger.Level.INFO, "RunningState.stopCpu");
		onStopCpu();
		stopEventCpu.signal();
	}
}