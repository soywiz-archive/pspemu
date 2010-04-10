module sandbox.gui_test;

private import dfl.all;

import pspemu.gui.HexEditorForm;
import pspemu.gui.Registers;
import std.stream;
import std.stdio;

int main() {
	int result = 0;
	
	try {
		Application.enableVisualStyles();

		//auto registerViewerForm = new RegisterViewerForm(); registerViewerForm.show();

		Application.run(new HexEditorForm);
	} catch(Object o) {
		msgBox(o.toString(), "Fatal Error", MsgBoxButtons.OK, MsgBoxIcon.ERROR);
		
		result = 1;
	}
	
	return result;
}