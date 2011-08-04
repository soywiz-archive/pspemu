module pspemu.core.cpu.dynarec.CpuThreadDynarec;

import pspemu.core.cpu.dynarec.EmiterMipsToX86;
import pspemu.core.cpu.dynarec.EmiterX86;
import pspemu.core.Memory;
import pspemu.core.ThreadState;
import pspemu.core.cpu.Registers;
import pspemu.core.cpu.CpuThreadBase;

class CpuThreadDynarec : CpuThreadBase {
	public this(ThreadState threadState) {
		super(threadState);
	}
	
	public CpuThreadBase createCpuThread(ThreadState threadState) {
		return new CpuThreadDynarec(threadState);
	}
	
	/*
	mixin TemplateCpu_ALU;
	mixin TemplateCpu_MEMORY;
	mixin TemplateCpu_BRANCH;
	mixin TemplateCpu_JUMP;
	mixin TemplateCpu_SPECIAL;
	mixin TemplateCpu_FPU;
	*/
}
/+
class CpuDynaRec : Cpu {
	alias EmiterMipsToX86.MipsRegisters Register;
	alias EmiterX86.Register32 Register32;

	EmiterMipsToX86[uint] emiters;
	
	void*[] instructionMapScratchPad;
	void*[] instructionMapMainMemory;

	this(Memory memory, Gpu gpu, Display display, IController controller) {
		instructionMapScratchPad = new void*[0x_4000 / 4];
		instructionMapMainMemory = new void*[0x_2000000 / 4];
		super(memory, gpu, display, controller);
	}

	void** instructionMapForAddressPointer(uint PspAddress) {
		PspAddress &= 0x7FFFFFFF;
		if (PspAddress >= 0x00010000 && PspAddress < 0x00014000) return &instructionMapScratchPad[(PspAddress - 0x00010000) >> 2];
		if (PspAddress >= 0x08000000 && PspAddress < 0x0A000000) return &instructionMapMainMemory[(PspAddress - 0x08000000) >> 2];
		//throw(new Exception(std.string.format("CpuDynaRec.instructionMapForAddress:Invalid Address 0x%08X", PspAddress)));
		return null;
	}

	void* getInstructionMapForAddress(uint PspAddress) {
		auto ptrPtr = instructionMapForAddressPointer(PspAddress);
		return (ptrPtr !is null) ? *ptrPtr : null;
	}
	
	void setInstructionMapForAddress(uint PspAddress, void* HostAddress) {
		auto ptrPtr = instructionMapForAddressPointer(PspAddress);
		if (ptrPtr == null) throw(new Exception(std.string.format("CpuDynaRec.setInstructionMapForAddress:Invalid Address 0x%08X", PspAddress)));
		*ptrPtr = HostAddress;
	}

	void reset() {
		instructionMapScratchPad[] = null;
		instructionMapMainMemory[] = null;
		emiters = null;
		super.reset();
	}

	void executePC(uint PC) {
		auto ptr = getInstructionMapForAddress(PC);
		
		// Miss.
		if (ptr is null) {
			try {
				analyzeFunction(PC);
			} catch (Throwable o) {
				writefln("CpuDynaRec.analyzeFunction: %s", o);
				throw(o);
			}
			ptr = getInstructionMapForAddress(PC);
		}
		
		EmiterMipsToX86.executeCode(registers, ptr);
	}

	bool addBreakPointWhenStart = true;
	//bool addBreakPointWhenStart = false;

	void analyzeFunction(uint PC) {
		InstructionMarker explored = new InstructionMarker;
		InstructionInfo instructionInfo, delayedInstructionInfo;
		bool[uint] branchesToExplore;
		auto emiter = new EmiterMipsToX86;
		Emiter.Label*[uint] labels;
		uint StartPC = PC;
		uint maxPC = 0x00000000, minPC = 0xFFFFFFFF;
		
		emiter.memory = memory;
		
		Emiter.Label* getLabel(uint PC) {
			if ((PC in labels) is null) labels[PC] = emiter.createLabel();
			return labels[PC];
		}
		
		bool moreToExplore() { return branchesToExplore.length > 0; }
		uint extractToExplore() {
			uint PC = branchesToExplore.keys[0]; branchesToExplore.remove(PC);
			return PC;
		}
		void addToExplore(uint PC) {
			if (PC != -1) {
				branchesToExplore[PC] = true;
			}
		}
		
		try {
			addToExplore(StartPC);
			explored.reset();
			while (moreToExplore) {
				// Extract a PC to start processing.
				PC = extractToExplore;
				
				if (PC < minPC) minPC = PC;

				for (; !explored.marked(PC); PC += 4) {
					explored.mark(PC);

					emiter.setLabelHere(getLabel(PC));

					if (addBreakPointWhenStart && (PC == StartPC)) {
						if (IsDebuggerPresent()) emiter.INT3(); // Debugger
						emiter.MOV(Register32.EDX, PC); // Just for debugging.
					}

					debug (DEBUG_DYNA_CODE_GEN) writefln("EMIT:%08X", PC);

					instructionInfo.set(PC, memory.tread!(uint)(PC));
					instructionInfo.parseJumps();

					// Jump.
					if (instructionInfo.isJump) {
						auto labelTrue = getLabel(instructionInfo.jumpAddress);
						auto labelFalse = getLabel(PC + 8);

						//auto dis = new AllegrexDisassembler(memory); writefln(":::%s", dis.dissasm(PC, memory));

						instructionInfo.emitPreDelayed(PC, instructionInfo.jumpAddress, emiter, labelTrue, labelFalse);
						labels[PC + 4] = emiter.createLabelAndSetHere();
						delayedInstructionInfo.set(PC + 4, memory.tread!(uint)(PC + 4));
						delayedInstructionInfo.inDelayedBranch = true;
						delayedInstructionInfo.emitNonDelayed(emiter);
						instructionInfo.emitPostDelayed(PC, instructionInfo.jumpAddress, emiter, labelTrue, labelFalse);
						PC += 4;
					}
					// No jump.
					else {
						instructionInfo.emitNonDelayed(emiter);
					}

					if (instructionInfo.isJump && instructionInfo.follow) {
						debug (DEBUG_DYNA_CODE_GEN) writefln(" EXP: %08X", instructionInfo.jumpAddress);
						addToExplore(instructionInfo.jumpAddress);
					}

					if (instructionInfo.isEndOfBranch) {
						break;
					}
				}
				if (PC > maxPC) maxPC = PC;
			}
		} catch (UnknownOperationException e) {
			auto dis = new AllegrexDisassembler(memory);
			throw(new UnknownOperationException(
				e.PC,
				std.string.format("%s : %s", e, std.string.join(dis.dissasm(e.PC, memory), ""))
			));
		}
		
		emiter.writeLabels();
		
		foreach (cPC, label; labels) {
			switch (label.type) {
				case Emiter.Label.Type.Internal:
					if ((cPC != -1) && (label.address != -1)) {
						setInstructionMapForAddress(cPC, emiter.buffer.ptr + label.address);
					}
				break;
				case Emiter.Label.Type.External:
					//throw(new Exception("Label.External"));
				break;
			}
			//writefln("LABEL: %08X", cPC);
		}
		
		emiters[minPC] = emiter;
	}

	void execute(uint count) {
		lastCpu = this;

		try {
			while (true) executePC(registers.PC);
		} catch (Object o) {
			writefln("CpuDynaRec.execute: %s", o);
			throw(o);
		}
	}
}

+/