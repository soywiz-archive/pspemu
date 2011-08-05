module pspemu.core.battery.Battery;

import pspemu.interfaces.IBattery;

class Battery : IBattery {
	@property float chargedPercentage() {
		return 1.0;
	}

	@property bool isCharging() {
		return false;
	}

	@property bool isPresent() {
		return true;
	}

	@property bool isPowerOnline() {
		return true;
	}
	
	@property int temperatureInCelsiusDegree() {
		return 28;
	}
}