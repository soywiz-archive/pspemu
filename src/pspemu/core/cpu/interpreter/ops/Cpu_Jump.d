module pspemu.core.cpu.interpreter.ops.Cpu_Jump;

//debug = DEBUG_CALLS;

template TemplateCpu_JUMP() {
	mixin TemplateCpu_JUMP_Utils;
	
	// J -- Jump
	// Jumps to the calculated address
	// PC = nPC; nPC = (PC & 0xf0000000) | (target << 2);
	void OP_J() {
		mixin(JUMP);
	}

	// JAL -- Jump and link
	// Jumps to the calculated address and stores the return address in $31
	// $31 = PC + 8 (or nPC + 4); PC = nPC; nPC = (PC & 0xf0000000) | (target << 2);
	void OP_JAL() {
		registers.CallStackPush();
		mixin(LINK ~ JUMP);
		/*
		debug (DEBUG_CALLS) {
			foreach (n; 0..registers.CallStack.length) writef("|");
			writef("JAL: %08X->%08X (", registers.RA, registers.nPC);
			for (int n = 0; n < 3; n++) writef("a%d=%08X, ", n, registers.R[4 + n]);
			writef("SP=%08X", registers.SP);
			writefln(")");
		}
		*/
	}

	// JR -- Jump register
	// Jump to the address contained in register $s
	// PC = nPC; nPC = $s;
	void OP_JR() {
		if (instruction.RS == 31) {
			registers.CallStackPop();
		}
		/*
		debug (DEBUG_CALLS) if (instruction.RS == 31) {
			foreach (n; 0..registers.CallStack.length) writef("|");
			writefln("/jr RA %08X", registers.RA);
			registers.dump();
			if (registers.CallStack.length > 0) registers.CallStack.length = registers.CallStack.length - 1;
		}
		*/
		
		//writefln("JR %08X", registers[instruction.RS]);
		mixin(JUMPR);
	}

	// JALR -- Jump and link register
	void OP_JALR() {
		registers.CallStackPush();
		mixin(LINK("instruction.RD") ~ JUMPR);
	}
}

template TemplateCpu_JUMP_Utils() {
	static pure nothrow {
		string LINK(string reg = "31") {
			return "registers.R[" ~ reg ~ "] = registers.nPC + 4;";
		}
		string JUMP() {
			return q{
				registers.PC  = registers.nPC;
				registers.nPC = (registers.PC & 0x_F0000000) | instruction.JUMP2;
			};
		}
		string JUMPR() {
			return q{
				registers.PC  = registers.nPC;
				registers.nPC = registers[instruction.RS];
			};
		}
	}
}