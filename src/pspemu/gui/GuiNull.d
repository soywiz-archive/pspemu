module pspemu.gui.GuiNull;

import pspemu.gui.GuiBase;

class GuiNull : GuiBase {
	this(HleEmulatorState hleEmulatorState) {
		super(hleEmulatorState);
	}

	public void init() {
	}

	public void loopStep() {
	}
}