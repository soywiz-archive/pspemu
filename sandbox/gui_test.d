module sandbox.gui_test;

private import dfl.all;

import pspemu.gui.HexEditor;
import std.stdio;

class TestForm : Form {
	HexEditorComponent hex1;
	
	this() {
		text = "Test";
		backColor = Color(255, 255, 255);
		startPosition = FormStartPosition.CENTER_SCREEN;
		setClientSizeCore(480, 320);
		with (hex1 = new HexEditorComponent) {
			//stream = new std.stream.File("sandbox/sse.d");
			stream = new std.stream.File("gui_test.exe");
			dock = DockStyle.FILL;
			parent = this;
		}
	}

	override void onMouseWheel(MouseEventArgs ea) {
		hex1.onMouseWheel(ea);
		//writefln("wheel!");
	}

	override void onKeyDown(KeyEventArgs ea) {
		//ea.delta *= 5;
		hex1.onKeyDown(ea);
	}

	override void onKeyPress(KeyPressEventArgs ea) {
		//ea.delta *= 5;
		hex1.onKeyPress(ea);
	}
}

int main() {
	int result = 0;
	
	try {
		Application.enableVisualStyles();
		Application.run(new TestForm);
	} catch(Object o) {
		msgBox(o.toString(), "Fatal Error", MsgBoxButtons.OK, MsgBoxIcon.ERROR);
		
		result = 1;
	}
	
	return result;
}