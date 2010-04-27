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

	struct CallbackInfo {
		bool autoremove;
	}

	alias CircularList!(Type, false) List;
	alias void delegate() Callback;

	// Fields.
	bool InterruptFlag;
	List list;
	CallbackInfo[Callback][Type] callbacks;

	this() {
		reset();
	}

	void reset() {
		synchronized (this) {
			InterruptFlag = InterruptFlag.init;
			list = new List;
			callbacks = null;
			//callbacks[Type.THREAD0] ~= { writefln("THREAD0"); };	
		}
	}

	void registerCallback(Type type, Callback cb, bool autoremove = false) {
		synchronized (this) {
			callbacks[type][cb] = CallbackInfo(autoremove);
		}
	}

	void registerCallbackSingle(Type type, Callback cb) {
		registerCallback(type, cb, true);
	}

	void unregisterCallback(Type type, Callback cb) {
		synchronized (this) {
			callbacks[type].remove(cb);
		}
	}

	void queue(Type type) {
		synchronized (this) {
			list.queue(type);
			InterruptFlag = true;
		}
	}

	Callback[1024] cblist;
	void process() {
		synchronized (this) {
			while (list.readAvailable) {
				auto type = list.consume();
				//writefln("%d", type);
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
