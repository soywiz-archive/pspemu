module pspemu.core.Interrupts;

public import pspemu.core.cpu.Registers;

class Interrupts {
	enum Type : uint {
		Gpio = 4, Ata = 5, Umd = 6, Mscm0 = 7, Wlan = 8, Audio = 10, I2C = 12, Sircs = 14,
		Systimer0 = 15, Systimer1 = 16, Systimer2 = 17, Systimer3 = 18, Thread0 = 19,
		Nand = 20, Dmacplus = 21, Dma0 = 22, Dma1 = 23, Memlmd = 24, Ge = 25, Vblank = 30,
		Mecodec = 31, Hpremote = 36, Mscm1 = 60, Mscm2 = 61, Thread1 = 65, Interrupt = 66,
	};

	struct Task {
		Type      type;
		Registers registers;
	}

	alias void delegate(Interrupts.Task interruptTask) InterruptHandler;
	
	/**
	 * Global InterruptFlag
	 */
	public bool _I_F;
	
	@property public bool I_F() { return _I_F; }
	
	protected InterruptHandler[][Type.max] interruptHandlersPerType;
	protected Interrupts.Task[] interruptsTasks;
	
	public this() {
		
	}
	
	void reset() {
		interruptHandlersPerType = null;
		interruptsTasks.length = 0;
	}
	
	public void addInterruptHandler(Type type, InterruptHandler interruptHandler) {
		interruptHandlersPerType[type] ~= interruptHandler;
	}
	
	public void interrupt(Type type) {
		synchronized (this) {
			Interrupts.Task interruptTask;
			interruptTask.type = type;
			interruptsTasks ~= interruptTask;
			_I_F = true;
		}
	}
	
	public void executeInterrupts(Registers registers) {
		synchronized (this) {
			auto code = {
				foreach (interruptTask; interruptsTasks) {
					interruptTask.registers = registers;
					
					foreach (interruptHandler; interruptHandlersPerType[interruptTask.type]) {
						interruptHandler(interruptTask);
					}
				}
			};
			
			if (registers !is null) {
				registers.restoreBlock(code);
			} else {
				code();
			}
			_I_F = false;
		}
	}
}