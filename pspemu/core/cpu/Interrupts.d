module pspemu.core.cpu.Interrupts;

import std.stdio;

import pspemu.utils.Utils;

class Interrupts {
	enum Type : uint {
		GPIO      =  4, ATA       =  5, UMD       =  6,
		MSCM0     =  7, WLAN      =  8, AUDIO     = 10,
		I2C       = 12, SIRCS     = 14, SYSTIMER0 = 15,
		SYSTIMER1 = 16, SYSTIMER2 = 17, SYSTIMER3 = 18,
		THREAD0   = 19, NAND      = 20, DMACPLUS  = 21,
		DMA0      = 22, DMA1      = 23, MEMLMD    = 24,
		GE        = 25, VBLANK    = 30, MECODEC   = 31,
		HPREMOTE  = 36, MSCM1     = 60, MSCM2     = 61,
		THREAD1   = 65, INTERRUPT = 66,
	}

	alias CircularList!(Type, false) List;
	alias void delegate() Callback;

	bool InterruptFlag;
	List list;
	Object mutex;
	Callback[][Type] callbacks;

	this() {
		list = new List;
		mutex = new Object;
		//callbacks[Type.THREAD0] ~= { writefln("THREAD0"); };
	}

	void queue(Type type) {
		synchronized (mutex) {
			list.queue(type);
			InterruptFlag = true;
		}
	}

	void process() {
		synchronized (mutex) {
			while (list.readAvailable) {
				auto type = list.consume();
				if (type in callbacks) {
					foreach (callback; callbacks[type]) callback();
				}
			}
			InterruptFlag = false;
		}
	}
}
