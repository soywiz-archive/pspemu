module pspemu.exe.Pspemu;

import dfl.all;
import pspemu.gui.MainForm;
import pspemu.gui.DisplayForm;

int main() {
	int result = 0;
	
	try {
		Application.run(new DisplayForm);
	} catch(Object o) {
		msgBox(o.toString(), "Fatal Error", MsgBoxButtons.OK, MsgBoxIcon.ERROR);
		result = 1;
	}

	return result;
}
