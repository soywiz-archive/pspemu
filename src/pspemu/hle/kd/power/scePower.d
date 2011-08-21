module pspemu.hle.kd.power.scePower; // kd/power.prx (scePower_Service)

import pspemu.hle.ModuleNative;

import pspemu.hle.Callbacks;

class scePower : HleModuleHost {
	mixin TRegisterModule;

	void initNids() {
		mixin(registerFunction!(0xEFD3C963, scePowerTick));

		mixin(registerFunction!(0x04B7766E, scePowerRegisterCallback));
		mixin(registerFunction!(0xDFA8BAF8, scePowerUnregisterCallback));

		mixin(registerFunction!(0x87440F5E, scePowerIsPowerOnline));
		mixin(registerFunction!(0x0AFD0D8B, scePowerIsBatteryExist));
		mixin(registerFunction!(0x1E490401, scePowerIsBatteryCharging));
		mixin(registerFunction!(0xB4432BC8, scePowerGetBatteryChargingStatus));
		mixin(registerFunction!(0xD3075926, scePowerIsLowBattery));
		mixin(registerFunction!(0x2085D15D, scePowerGetBatteryLifePercent));
		mixin(registerFunction!(0x8EFB3FA2, scePowerGetBatteryLifeTime));
		mixin(registerFunction!(0x28E12023, scePowerGetBatteryTemp));
		mixin(registerFunction!(0x483CE86B, scePowerGetBatteryVolt));
		mixin(registerFunction!(0xD6D016EF, scePowerLock));
		mixin(registerFunction!(0xCA3D34C1, scePowerUnlock));
		mixin(registerFunction!(0xFEE03A2F, scePowerGetCpuClockFrequency));
		mixin(registerFunction!(0x478FE6F5, scePowerGetBusClockFrequency));
		mixin(registerFunction!(0x737486F2, scePowerSetClockFrequency));
		mixin(registerFunction!(0x843FBF43, scePowerSetCpuClockFrequency));
		mixin(registerFunction!(0xB8D7B3FB, scePowerSetBusClockFrequency));
		mixin(registerFunction!(0xFDB5BFE9, scePowerGetCpuClockFrequencyInt));

		mixin(registerFunction!(0x2B51FE2F, scePower_2B51FE2F));
		mixin(registerFunction!(0x442BFBAC, scePower_442BFBAC));
		mixin(registerFunction!(0xEDC13FE5, scePowerGetIdleTimer));
		mixin(registerFunction!(0x7F30B3B1, scePowerIdleTimerEnable));
		mixin(registerFunction!(0x972CE941, scePowerIdleTimerDisable));
		mixin(registerFunction!(0x27F3292C, scePowerBatteryUpdateInfo));
		mixin(registerFunction!(0xE8E4E204, scePower_E8E4E204));
		mixin(registerFunction!(0xB999184C, scePowerGetLowBatteryCapacity));
		mixin(registerFunction!(0x78A1A796, scePower_78A1A796));
		mixin(registerFunction!(0x94F5A53F, scePowerGetBatteryRemainCapacity));
		mixin(registerFunction!(0xFD18A0FF, scePowerGetBatteryFullCapacity));
		mixin(registerFunction!(0x862AE1A6, scePowerGetBatteryElec));
		mixin(registerFunction!(0x23436A4A, scePower_23436A4A));
		mixin(registerFunction!(0x0CD21B1F, scePowerSetPowerSwMode));
		mixin(registerFunction!(0x165CE085, scePowerGetPowerSwMode));
		mixin(registerFunction!(0xDB62C9CF, scePowerCancelRequest));
		mixin(registerFunction!(0x7FA406DD, scePowerIsRequest));
		mixin(registerFunction!(0x2B7C7CF4, scePowerRequestStandby));
		mixin(registerFunction!(0xAC32C9CC, scePowerRequestSuspend));
		mixin(registerFunction!(0x2875994B, scePower_2875994B));
		mixin(registerFunction!(0x3951AF53, scePowerWaitRequestCompletion));
		mixin(registerFunction!(0x0074EF9B, scePowerGetResumeCount));
		mixin(registerFunction!(0xDB9D28DD, scePowerUnregitserCallback));
		mixin(registerFunction!(0xBD681969, scePowerGetBusClockFrequencyInt));
		mixin(registerFunction!(0xB1A52C83, scePowerGetCpuClockFrequencyFloat));
		mixin(registerFunction!(0x9BADB3EB, scePowerGetBusClockFrequencyFloat));
		
		mixin(registerFunction!(0xEBD177D6, scePowerSetClockFrequency));
	}
	
	// PLL clock:
	// Operates at fixed rates of 148MHz, 190MHz, 222MHz, 266MHz, 333MHz.
	// Starts at 222MHz.
	int pllClock = 222;
	// CPU clock:
	// Operates at variable rates from 1MHz to 333MHz.
	// Starts at 222MHz.
	// Note: Cannot have a higher frequency than the PLL clock's frequency.
	int cpuClock = 222;
	// BUS clock:
	// Operates at variable rates from 37MHz to 166MHz.
	// Starts at 111MHz.
	// Note: Cannot have a higher frequency than 1/2 of the PLL clock's frequency
	// or lower than 1/4 of the PLL clock's frequency.
	int busClock = 111;

	/**
	 * Get Bus fequency as Integer
	 * @return frequency as int
	 */
	int scePowerGetBusClockFrequencyInt() {
		return busClock;
	}

	/**
	 * Get CPU Frequency as Float
	 * @return frequency as float
	 */
	float scePowerGetCpuClockFrequencyFloat() { unimplemented(); return -1; }

	/**
	 * Get Bus frequency as Float
	 * @return frequency as float
	 */
	float scePowerGetBusClockFrequencyFloat() { unimplemented(); return -1; }

	void scePowerUnregitserCallback() { unimplemented(); }
	void scePowerGetResumeCount() { unimplemented(); }
	void scePowerWaitRequestCompletion() { unimplemented(); }
	void scePower_2875994B() { unimplemented(); }
	void scePowerIsRequest() { unimplemented(); }
	void scePower_23436A4A() { unimplemented(); }
	void scePower_78A1A796() { unimplemented(); }
	void scePower_E8E4E204() { unimplemented(); }
	void scePower_2B51FE2F() { unimplemented(); }
	void scePower_442BFBAC() { unimplemented(); }
	void scePowerBatteryUpdateInfo() { unimplemented(); }
	void scePowerGetLowBatteryCapacity() { unimplemented(); }
	void scePowerGetBatteryRemainCapacity() { unimplemented(); }
	void scePowerGetBatteryFullCapacity() { unimplemented(); }
	void scePowerSetPowerSwMode() { unimplemented(); }
	void scePowerGetPowerSwMode() { unimplemented(); }
	void scePowerCancelRequest() { unimplemented(); }

	/**
	 * Request the PSP to go into standby
	 *
	 * @return 0 always
	 */
	int scePowerRequestStandby() { unimplemented(); return -1; }

	/**
	 * Request the PSP to go into suspend
	 *
	 * @return 0 always
	 */
	int scePowerRequestSuspend() { unimplemented(); return -1; }

	/**
	 * unknown? - crashes PSP in usermode
	 */
	int scePowerGetBatteryElec() { unimplemented(); return -1; }

	/**
	 * Get Idle timer
	 */
	int scePowerGetIdleTimer() {
		unimplemented();
		return -1;
	}

	/**
	 * Enable Idle timer
	 *
	 * @param unknown - pass 0
	 */
	int scePowerIdleTimerEnable(int unknown) {
		unimplemented();
		return -1;
	}

	/**
	 * Disable Idle timer
	 *
	 * @param unknown - pass 0
	 */
	int scePowerIdleTimerDisable(int unknown) {
		unimplemented();
		return -1;
	}

	// http://jpcsp.googlecode.com/svn/trunk/src/jpcsp/HLE/modules150/scePower.java
	int  pllfreq = 0;
	int  cpufreq = 222;
	int  busfreq = 111;
	int  batteryLifeTime = (5 * 60); // 5 hours
    int  batteryTemp = 28; //some standard battery temperature 28 deg C
    int  batteryVoltage = 4135; //battery voltage 4,135 in slim
    bool pluggedIn = true;
    bool batteryPresent = true;
    int  batteryPowerPercent = 100;
    int  batteryLowPercent = 12;
    int  batteryForceSuspendPercent = 4;
    int  fullBatteryCapacity = 1800;
    bool batteryCharging = false;
    int  backlightMaximum = 4;
	/**
	 * Generate a power tick, preventing unit from 
	 * powering off and turning off display.
	 *
	 * @param type - Either PSP_POWER_TICK_ALL, PSP_POWER_TICK_SUSPEND or PSP_POWER_TICK_DISPLAY
	 *
	 * @return 0 on success, < 0 on error.
	 */
	int scePowerTick(int type) {
		/*
		unimplemented();
		return -1;
		*/
		//unimplemented_notice();
		return 0;
	}

	/**
	 * Check if unit is plugged in
	 *
	 * @return 1 if plugged in, 0 if not plugged in, < 0 on error.
	 */
	int scePowerIsPowerOnline() {
		return hleEmulatorState.emulatorState.battery.isPowerOnline;
	}

	/**
	 * Check if a battery is present
	 *
	 * @return 1 if battery present, 0 if battery not present, < 0 on error.
	 */
	int scePowerIsBatteryExist() {
		return hleEmulatorState.emulatorState.battery.isPresent;
	}

	/**
	 * Check if the battery is charging
	 *
	 * @return 1 if battery charging, 0 if battery not charging, < 0 on error.
	 */
	int scePowerIsBatteryCharging() {
		return hleEmulatorState.emulatorState.battery.isCharging;
	}
	
	/**
	 * Get the status of the battery charging
	 */
	int scePowerGetBatteryChargingStatus() {
		unimplemented();
		return -1;
	}

	/**
	 * Check if the battery is low
	 *
	 * @return 1 if the battery is low, 0 if the battery is not low, < 0 on error.
	 */
	int scePowerIsLowBattery() {
		unimplemented();
		return -1;
	}

	/**
	 * Get battery life as integer percent
	 *
	 * @return Battery charge percentage (0-100), < 0 on error.
	 */
	int scePowerGetBatteryLifePercent() {
		//unimplemented();
		return cast(int)(hleEmulatorState.emulatorState.battery.chargedPercentage * 100);
	}

	/**
	 * Get battery life as time
	 *
	 * @return Battery life in minutes, < 0 on error.
	 */
	int scePowerGetBatteryLifeTime() {
		unimplemented();
		return -1;
	}

	/**
	 * Get temperature of the battery on deg C
	 */
	int scePowerGetBatteryTemp() {
		return hleEmulatorState.emulatorState.battery.temperatureInCelsiusDegree;
	}

	/**
	 * Get battery volt level
	 */
	int scePowerGetBatteryVolt() {
		unimplemented();
		return -1;
	}

	/**
	 * Lock power switch
	 *
	 * Note: if the power switch is toggled while locked
	 * it will fire immediately after being unlocked.
	 *
	 * @param unknown - pass 0
	 *
	 * @return 0 on success, < 0 on error.
	 */
	int scePowerLock(int unknown) {
		unimplemented();
		return -1;
	}

	/**
	 * Unlock power switch
	 *
	 * @param unknown - pass 0
	 *
	 * @return 0 on success, < 0 on error.
	 */
	int scePowerUnlock(int unknown) {
		unimplemented();
		return -1;
	}
	
	PspCallback[16] callbacks;

	/**
	 * Register Power Callback Function
	 *
	 * @param slot - slot of the callback in the list, 0 to 15, pass -1 to get an auto assignment.
	 * @param cbid - callback id from calling sceKernelCreateCallback
	 *
	 * @return 0 on success, the slot number if -1 is passed, < 0 on error.
	 */
	int scePowerRegisterCallback(int slot, SceUID cbid) {
		//unimplemented();
		//return -1;
		
		unimplemented_notice();
		
		if (slot == -1) {
			foreach (k, callback; callbacks) {
				if (callback is null) {
					slot = k;
					break;
				}
			}
		}
		
		if (callbacks[slot] !is null) {
			return SceKernelErrors.ERROR_ALREADY;
		}
		
		callbacks[slot] = uniqueIdFactory.get!PspCallback(cbid);
		hleEmulatorState.callbacksHandler.register(CallbacksHandler.Type.Power, callbacks[slot]);

		hleEmulatorState.callbacksHandler.trigger(CallbacksHandler.Type.Power, [cbid, 0x00001000, 0], 2);
		
		return 0;
	}
	
	/**
	 * Unregister Power Callback Function
	 *
	 * @param slot - slot of the callback
	 *
	 * @return 0 on success, < 0 on error.
	 */
	int scePowerUnregisterCallback(int slot) {
		hleEmulatorState.callbacksHandler.unregister(CallbacksHandler.Type.Power, callbacks[slot]);
		callbacks[slot] = null;
		return 0;
	}

	/**
	 * Alias for scePowerGetCpuClockFrequencyInt
	 * @return frequency as int
	 */
	int scePowerGetCpuClockFrequency() {
		unimplemented();
		return -1;
	}

	/**
	 * Alias for scePowerGetBusClockFrequencyInt
	 * @return frequency as int
	 */
	int scePowerGetBusClockFrequency() {
		unimplemented();
		return -1;
	}

	/**
	 * Set Clock Frequencies
	 *
	 * @param pllfreq - pll frequency, valid from 19-333
	 * @param cpufreq - cpu frequency, valid from 1-333
	 * @param busfreq - bus frequency, valid from 1-167
	 * 
	 * and:
	 * 
	 * cpufreq <= pllfreq
	 * busfreq*2 <= pllfreq
	 *
	 */
	int scePowerSetClockFrequency(int pllfreq, int cpufreq, int busfreq) {
		this.pllfreq = pllfreq;
		this.cpufreq = cpufreq;
		this.busfreq = busfreq;
		return 0;
	}
	
	/**
	 * Set CPU Frequency
	 * @param cpufreq - new CPU frequency, valid values are 1 - 333
	 */
	int scePowerSetCpuClockFrequency(int cpufreq) {
		this.cpufreq = cpufreq;
		return 0;
	}

	/**
	 * Set Bus Frequency
	 * @param busfreq - new BUS frequency, valid values are 1 - 167
	 */
	int scePowerSetBusClockFrequency(int busfreq) {
		this.busfreq = busfreq;
		return 0;
	}

	/**
	 * Get CPU Frequency as Integer
	 * @return frequency as int
	 */
	int scePowerGetCpuClockFrequencyInt() {
		return cpufreq;
	}
}
