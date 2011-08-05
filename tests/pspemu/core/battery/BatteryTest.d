module pspemu.core.battery.BatteryTest;

import pspemu.interfaces.IBattery;
import pspemu.core.battery.Battery;

import tests.Test;

class BatteryTest : Test {
	IBattery battery;
	
	this() {
		battery = new Battery();
	}
	
	void testBattery() {
		assertTrue(battery.isPresent);
	}
}