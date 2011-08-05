module pspemu.interfaces.IBattery;

import pspemu.interfaces.IComponent;

interface IBattery {
	@property float chargedPercentage();
	@property bool  isCharging();
	@property bool  isPresent();
	@property bool  isPowerOnline();
	@property int   temperatureInCelsiusDegree();
}