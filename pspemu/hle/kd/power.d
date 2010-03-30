module pspemu.hle.kd.power; // kd/power.prx (scePower_Service)

debug = DEBUG_SYSCALL;

import pspemu.hle.Module;

class scePower : Module {
	void initNids() {
		mixin(registerd!(0xEFD3C963, scePowerTick));
		mixin(registerd!(0x87440F5E, scePowerIsPowerOnline));
		mixin(registerd!(0x0AFD0D8B, scePowerIsBatteryExist));
		mixin(registerd!(0x1E490401, scePowerIsBatteryCharging));
		mixin(registerd!(0xD3075926, scePowerIsLowBattery));
		mixin(registerd!(0x2085D15D, scePowerGetBatteryLifePercent));
		mixin(registerd!(0x8EFB3FA2, scePowerGetBatteryLifeTime));
		mixin(registerd!(0x28E12023, scePowerGetBatteryTemp));
		mixin(registerd!(0x483CE86B, scePowerGetBatteryVolt));
		mixin(registerd!(0xD6D016EF, scePowerLock));
		mixin(registerd!(0xCA3D34C1, scePowerUnlock));
		mixin(registerd!(0x04B7766E, scePowerRegisterCallback));
		mixin(registerd!(0xFEE03A2F, scePowerGetCpuClockFrequency));
		mixin(registerd!(0x478FE6F5, scePowerGetBusClockFrequency));
		mixin(registerd!(0x737486F2, scePowerSetClockFrequency));
		mixin(registerd!(0x843FBF43, scePowerSetCpuClockFrequency));
		mixin(registerd!(0xB8D7B3FB, scePowerSetBusClockFrequency));
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
		unimplemented();
		return -1;
	}

	/**
	 * Check if a battery is present
	 *
	 * @return 1 if battery present, 0 if battery not present, < 0 on error.
	 */
	int scePowerIsBatteryExist() {
		unimplemented();
		return -1;
	}

	/**
	 * Check if the battery is charging
	 *
	 * @return 1 if battery charging, 0 if battery not charging, < 0 on error.
	 */
	int scePowerIsBatteryCharging() {
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
		unimplemented();
		return -1;
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
	 * Get temperature of the battery
	 */
	int scePowerGetBatteryTemp() {
		unimplemented();
		return -1;
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
			return 1;
		} else {
			return 0;
		}
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
}

static this() {
	mixin(Module.registerModule("scePower"));
}
