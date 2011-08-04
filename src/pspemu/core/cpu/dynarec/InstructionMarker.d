module pspemu.core.cpu.dynarec.InstructionMarker;

class InstructionMarker {
	bool[uint] marks;

	void mark(uint PC) {
		marks[PC] = true;
	}

	void unmark(uint PC) {
		marks.remove(PC);
	}
	
	bool marked(uint PC) {
		return (PC in marks) !is null;
	}

	void reset() {
		marks = null;
	}
}