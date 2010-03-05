module pspemu.exe.Pspemu;

import dfl.all;
import pspemu.gui.MainForm;
import pspemu.gui.DisplayForm;

import pspemu.models.IDisplay;

import pspemu.core.Memory;
import pspemu.core.cpu.Cpu;

class PspDisplay : BasePspDisplay {
	Memory memory;

	this(Memory memory) {
		this.memory = memory;
	}

	void* frameBufferPointer() {
		return memory.getPointer(0x04000000);
	}

	void vblank(bool status) {
		// Dummy.
	}
}

int main() {
	auto memory  = new Memory;
	auto cpu     = new Cpu(memory);
	auto display = new PspDisplay(memory);

	try {
		Application.run(new DisplayForm(display));
		return 0;
	} catch (Object o) {
		msgBox(o.toString(), "Fatal Error", MsgBoxButtons.OK, MsgBoxIcon.ERROR);
		return -1;
	}
}
