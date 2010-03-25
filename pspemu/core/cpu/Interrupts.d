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

	struct CallbackInfo {
		bool autoremove;
	}
	
	CallbackInfo[Callback][Type] callbacks;

	this() {
		list = new List;
		mutex = new Object;
		//callbacks[Type.THREAD0] ~= { writefln("THREAD0"); };
	}

	void registerCallback(Type type, Callback cb, bool autoremove = false) {
		synchronized (mutex) {
			callbacks[type][cb] = CallbackInfo(autoremove);
		}
	}

	void registerCallbackSingle(Type type, Callback cb) {
		registerCallback(type, cb, true);
	}

	void unregisterCallback(Type type, Callback cb) {
		synchronized (mutex) {
			callbacks[type].remove(cb);
		}
	}

	void queue(Type type) {
		synchronized (mutex) {
			list.queue(type);
			InterruptFlag = true;
		}
	}

	Callback[1024] cblist;
	void process() {
		synchronized (mutex) {
			while (list.readAvailable) {
				auto type = list.consume();
				if (type in callbacks) {
					auto callbackKeys = callbacks[type].keys;
					cblist[0..callbackKeys.length] = callbackKeys[0..$];
					foreach (callback; cblist[0..callbackKeys.length]) {
						callback();
						if (callbacks[type][callback].autoremove) {
							callbacks[type].remove(callback);
						}
					}
				}
			}
			InterruptFlag = false;
		}
	}
}
