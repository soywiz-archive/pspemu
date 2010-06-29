module pspemu.core.cpu.dynarec.Cpu;

//debug = DEBUG_DYNA_CODE_GEN;

public import pspemu.utils.EmiterX86;

import pspemu.core.gpu.Gpu;
import pspemu.models.IDisplay;
import pspemu.models.IController;
import pspemu.models.ISyscall;

import pspemu.core.Memory;
import pspemu.core.cpu.Cpu;
import pspemu.core.cpu.Interrupts;
import pspemu.core.cpu.Instruction;
import pspemu.core.cpu.Disassembler;
import pspemu.core.cpu.Table;
import pspemu.core.cpu.Switch;
import pspemu.core.cpu.interpreted.Utils;

import pspemu.core.cpu.dynarec.ops.Alu;
import pspemu.core.cpu.dynarec.ops.Memory;

extern (Windows) uint IsDebuggerPresent();

class EmiterMipsToX86 : EmiterX86 {
	Memory memory;

	enum MipsRegisters : uint {
		// +00 +01 +02 +03 +04 +05 +06 +07
		    ZR, AT, V0, V1, A0, A1, A2, A3, // +00
		    T0, T1, T2, T3, T4, T5, T6, T7, // +08
		    S0, S1, S2, S3, S4, S5, S6, S7, // +16
		    T8, T9, K0, K1, GP, SP, FP, RA, // +24
	}

	/*
	
	Registers:
		GPR: 4*32
		HI, LO
		CMP1, CMP2
		CLOCKS
		FPR: 4*32
	*/

	static void executeCode(Registers registers, void* codePointer) {
		uint registersInt = cast(uint)&registers.R;
		auto func = cast(uint)codePointer;
		asm {
			//push EBP;
			push EBX;
				mov EBX, registersInt;
				//mov EBP, 0;
				mov EAX, func;
				call EAX;
			pop EBX;
			//pop EBP;
		}
	}

	byte MIPS_GET_DISPLACEMENT(MipsRegisters mipsRegister) {
		return cast(byte)(4 * (0 + (mipsRegister & 31)));
	}
	
	Memory32 MIPS_GET_REGISTER(MipsRegisters mipsRegister) {
		return Memory32(Register32.EBX, MIPS_GET_DISPLACEMENT(mipsRegister));
	}

	Memory32 MIPS_GET_LOHI(int pos) {
		return Memory32(Register32.EBX, 4 * (32 + 0 + pos));
	}

	Memory32 MIPS_GET_CMP(int pos) {
		return Memory32(Register32.EBX, 4 * (32 + 2 + pos));
	}
	
	Memory32 MIPS_GET_CLOCKS() {
		return Memory32(Register32.EBX, 4 * (32 + 4));
	}

	void MIPS_LOAD_REGISTER(Register32 x32RegTo, MipsRegisters mipsRegFrom) {
		if (mipsRegFrom == 0) {
			MOV(x32RegTo, 0);
		} else {
			MOV(x32RegTo, MIPS_GET_REGISTER(mipsRegFrom));
		}
	}

	void MIPS_STORE_REGISTER(Register32 x32RegFrom, MipsRegisters mipsRegTo) {
		if (mipsRegTo == 0) return;
		MOV(MIPS_GET_REGISTER(mipsRegTo), x32RegFrom);
	}

	void MIPS_STORE_REGISTER_VALUE(uint value, MipsRegisters mipsRegTo) {
		if (mipsRegTo == 0) return;
		MOV(MIPS_GET_REGISTER(mipsRegTo), value);
	}

	void MIPS_LI(MipsRegisters rt, uint value) {
		MIPS_STORE_REGISTER_VALUE(value, rt); return;
	}
	
	void MIPS_NOP() {
	}

	mixin Cpu_Alu_Emiter;
	mixin Cpu_Memory_Emiter;

	void MIPS_SYSCALL(uint PC, uint code) {
		{
			PUSH(code);
			PUSH(PC);
			CALL(createLabelToFunction(&SYSCALL));
			ADD(Register32.ESP, 8);
		}
		RET();
	}

	void MIPS_PREPARE_CMP(MipsRegisters rs, MipsRegisters rt) {
		MIPS_LOAD_REGISTER(Register32.EAX, rs);
		MIPS_LOAD_REGISTER(Register32.EDX, rt);
		CMP(Register32.EAX, Register32.EDX);
	}

	void MIPS_TICK(uint PC, uint count = 1) {
		static if (false) {
			ADD(MIPS_GET_CLOCKS, count);
			CMP(MIPS_GET_CLOCKS, 0xFFFF);
			auto label = createLabel;
			JNGE(label);
			{
				MOV(MIPS_GET_CLOCKS, 0);
				PUSH(PC);
				CALL(createLabelToFunction(&SYSTEM_TICK_SIMPLE));
				ADD(Register32.ESP, 4);
				CMP(Register32.EAX, 0);
				JE(1);
				RET();
			}
			setLabelHere(label);
		} else {
			PUSH(PC);
			PUSH(count);
			CALL(createLabelToFunction(&SYSTEM_TICK));
			ADD(Register32.ESP, 8);
			CMP(Register32.EAX, 0);
			JE(1);
			RET();
		}
	}
}

static Cpu lastCpu;

static extern(C) {
	bool SYSTEM_TICK_SIMPLE(uint PC) {
		lastCpu.registers.PC = PC;
		lastCpu.registers.nPC = PC + 4;

		lastCpu.interrupts.queue(Interrupts.Type.THREAD0);

		if (lastCpu.interrupts.InterruptFlag) {
			lastCpu.interrupts.process();
			//writefln("interrupt! %08X", lastCpu.registers.PC);
		}

		// Break execution.
		if (PC != lastCpu.registers.PC) {
			//writefln("changed PC!!! %08X", lastCpu.registers.PC);
			return true;
		}

		if (lastCpu.runningState != RunningState.RUNNING) lastCpu.waitUntilResume();

		if (lastCpu.registers.PAUSED) {
			while (lastCpu.registers.PAUSED) {
				lastCpu.interrupts.queue(Interrupts.Type.THREAD0);
				if (lastCpu.interrupts.InterruptFlag) lastCpu.interrupts.process();
				sleep(0);
			}
			return true;
		}

		//std.c.stdio.printf("%08X\n", PC);
		return false;
	}

	bool SYSTEM_TICK(uint COUNT, uint PC) {
		static uint count = 0;
		lastCpu.registers.PC = PC;
		lastCpu.registers.nPC = PC + 4;
		count += COUNT;
		if (count > 0xFFFF) {
			lastCpu.interrupts.queue(Interrupts.Type.THREAD0);
			count = 0;
		}
		if (lastCpu.interrupts.InterruptFlag) {
			lastCpu.interrupts.process();
			//writefln("interrupt! %08X", lastCpu.registers.PC);
		}

		// Break execution.
		if (PC != lastCpu.registers.PC) {
			//writefln("changed PC!!! %08X", lastCpu.registers.PC);
			return true;
		}

		if (lastCpu.runningState != RunningState.RUNNING) lastCpu.waitUntilResume();

		if (lastCpu.registers.PAUSED) {
			while (lastCpu.registers.PAUSED) {
				lastCpu.interrupts.queue(Interrupts.Type.THREAD0);
				if (lastCpu.interrupts.InterruptFlag) lastCpu.interrupts.process();
				sleep(0);
			}
			return true;
		}

		//std.c.stdio.printf("%08X\n", PC);
		return false;
	}

	void MEMORY_WRITE_SB(uint addr, uint value) { lastCpu.memory.twrite(addr, cast(ubyte)value); }
	void MEMORY_WRITE_SH(uint addr, uint value) { lastCpu.memory.twrite(addr, cast(ushort)value); }
	void MEMORY_WRITE_SW(uint addr, uint value) { lastCpu.memory.twrite(addr, cast(uint)value); }

	uint MEMORY_READ_LB (uint addr) { return lastCpu.memory.tread!(byte)(addr); }
	uint MEMORY_READ_LH (uint addr) { return lastCpu.memory.tread!(short)(addr); }
	uint MEMORY_READ_LBU(uint addr) { return lastCpu.memory.tread!(ubyte)(addr); }
	uint MEMORY_READ_LHU(uint addr) { return lastCpu.memory.tread!(ushort)(addr); }
	uint MEMORY_READ_LW (uint addr) { return lastCpu.memory.tread!(uint)(addr); }
	
	void JUMP_PC(uint PC) {
		lastCpu.registers.pcSet = PC;
	}

	void SYSCALL(uint PC, uint code) {
		lastCpu.registers.pcSet = PC + 4;
		//writefln("SYSCALL PC(%08X) -> CODE(%08X)", PC, code);
		lastCpu.syscall(code);
	}
}

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

class UnknownOperationException : Exception {
	uint PC;
	this(uint PC, string str) {
		this.PC = PC;
		super(str);
	}
}

template SimplifyInstructionAccess() {
	Register RS() { return cast(Register)instruction.RS; }
	Register RT() { return cast(Register)instruction.RT; }
	Register RD() { return cast(Register)instruction.RD; }
	ushort IMMU() { return cast(ushort)instruction.IMMU; }
	int    IMM () { return cast(int)instruction.IMM; }
	ubyte  POS () { return cast(ubyte)instruction.POS; }
}

class CpuDynaRec : Cpu {
	alias EmiterMipsToX86.MipsRegisters Register;
	alias EmiterX86.Register32 Register32;

	struct InstructionInfo {		
		uint PC;
		//InstructionDefinition instructionDefinition;
		Instruction instruction;
		bool isJump, jumpAlways, isLikely, jumpLink, isEndOfBranch;
		bool follow;
		uint jumpAddress;
		bool inDelayedBranch;
		int count = 0;

		enum Likely { NO, YES }
		enum Link   { NO, YES }

		void set(uint PC, uint v) {
			this.PC = PC; instruction.v = v;
		}

		mixin SimplifyInstructionAccess;

		void parseJumps() {
			auto instruction = this.instruction;
			
			static pure nothrow string BRANCH(Likely likely, Link link, string alwaysCondition) {
				return (
					"isJump = true;"
					"follow = true;"
					"isLikely   = " ~ (likely ? "true" : "false") ~ ";"
					"jumpLink   = " ~ (link   ? "true" : "false") ~ ";"
					"jumpAlways = " ~ alwaysCondition ~ ";"
					//"isEndOfBranch = " ~ alwaysCondition ~ ";" // To optimize! (and avoid exploring wrong code)
					"isEndOfBranch = false;"
					"jumpAddress = PC + instruction.OFFSET2 + 4;"
				);
			}
			static pure nothrow string BRANCH_S(Likely likely, string condition) { return BRANCH(likely, Link.NO, condition); }

			void OP_BEQ    () { mixin(BRANCH(Likely.NO , Link.NO , "RS == RT")); }
			void OP_BEQL   () { mixin(BRANCH(Likely.YES, Link.NO , "RS == RT")); }
			void OP_BGEZ   () { mixin(BRANCH(Likely.NO , Link.NO , "RS == 0")); }
			void OP_BGEZAL () { mixin(BRANCH(Likely.NO , Link.YES, "RS == 0")); }
			void OP_BGEZALL() { mixin(BRANCH(Likely.YES, Link.YES, "RS == 0")); }
			void OP_BGEZL  () { mixin(BRANCH(Likely.YES, Link.NO , "RS == 0")); }
			void OP_BGTZ   () { mixin(BRANCH(Likely.NO , Link.NO , "false")); }
			void OP_BGTZL  () { mixin(BRANCH(Likely.YES, Link.NO , "false")); }
			void OP_BLEZ   () { mixin(BRANCH(Likely.NO , Link.NO , "RS == 0")); }
			void OP_BLEZL  () { mixin(BRANCH(Likely.YES, Link.NO , "RS == 0")); }
			void OP_BLTZ   () { mixin(BRANCH(Likely.NO , Link.NO , "false")); }
			void OP_BLTZL  () { mixin(BRANCH(Likely.YES, Link.NO , "false")); }
			void OP_BLTZAL () { mixin(BRANCH(Likely.NO , Link.YES, "false")); }
			void OP_BLTZALL() { mixin(BRANCH(Likely.YES, Link.YES, "false")); }
			void OP_BNE    () { mixin(BRANCH(Likely.NO , Link.NO , "false")); }
			void OP_BNEL   () { mixin(BRANCH(Likely.YES, Link.NO , "false")); }

			void OP_BC1F   () { mixin(BRANCH_S(Likely.NO,  "false")); }
			void OP_BC1FL  () { mixin(BRANCH_S(Likely.YES, "false")); }
			void OP_BC1T   () { mixin(BRANCH_S(Likely.NO,  "false")); }
			void OP_BC1TL  () { mixin(BRANCH_S(Likely.YES, "false")); }

			void OP_J   () { isJump = true; jumpAlways = true; isEndOfBranch = true ; jumpAddress = instruction.JUMP2; follow = true; }
			void OP_JR  () { isJump = true; jumpAlways = true; isEndOfBranch = true ; jumpAddress = -1; follow = false; }
			void OP_JAL () { isJump = true; jumpAlways = true; isEndOfBranch = false; jumpAddress = instruction.JUMP2; follow = false; }
			void OP_JALR() { isJump = true; jumpAlways = true; isEndOfBranch = false; jumpAddress = -1; follow = false; }

			void OP_UNK() {
				follow = isJump = jumpAlways = isLikely = jumpLink = isEndOfBranch = false;
				jumpAddress = -1;
				//writefln("UNK");
			}

			count++;
			mixin(genSwitch(PspInstructions_BCU));
		}
		
		void emitNonDelayed(EmiterMipsToX86 emiter) {
			auto instruction = this.instruction;
			auto inDelayedBranch = this.inDelayedBranch;
			
			mixin SimplifyInstructionAccess;

			void OP_UNK() {
				throw(new UnknownOperationException(PC, "Unknown instruction"));
				writefln("Unknown instruction 0x%08X at 0x%08X", instruction.v, PC);
			}
			
			mixin Cpu_Alu;
			mixin Cpu_Memory;

			void OP_SYSCALL() {
				debug (DEBUG_DYNA_CODE_GEN) writefln("SYSCALL 0x%08X", instruction.CODE);
				emiter.MIPS_SYSCALL(PC, instruction.CODE);
			}
			mixin(genSwitch(PspInstructions));
		}
		
		/*
			Non Likely branches:
				- Executes always delayed slot before branch.
			Likely branches:
				- When branches, executes delayed slot.
				- When no branches, skips delayed slot.
		*/
		
		void emitBranchFalse(EmiterMipsToX86 emiter, Emiter.Label* labelFalse) {
			void CompareBase() {
				if (isLikely) {
					emiter.MOV(Register32.EAX, emiter.MIPS_GET_REGISTER(RS));
				} else {
					emiter.MOV(Register32.EAX, emiter.MIPS_GET_CMP(0));
				}
				emiter.CMP(Register32.EAX, Register32.ECX);
			}
			void CompareNormal() {
				if (isLikely) {
					emiter.MOV(Register32.ECX, emiter.MIPS_GET_REGISTER(RT)); // @TODO: This instruciton is likely to be broken.
				} else {
					emiter.MOV(Register32.ECX, emiter.MIPS_GET_CMP(1));
				}
				CompareBase();
			}
			void CompareZero() {
				emiter.MOV(Register32.ECX, 0);
				CompareBase();
			}

			void OP_UNK() {
				throw(new UnknownOperationException(PC, "Unknown jump"));
				//debug (DEBUG_DYNA_CODE_GEN) writefln("Unknown jump!");
			}
			// Invert jumps.
			void OP_BEQ () { CompareNormal(); emiter.JNE (labelFalse); } alias OP_BEQ OP_BEQL;
			void OP_BNE () { CompareNormal(); emiter.JE  (labelFalse); }
			void OP_BGEZ() { CompareZero  (); emiter.JNGE(labelFalse); }
			mixin(genSwitch(PspInstructions));
		}
		
		void emitPreDelayed(uint PC, uint JumpPC, EmiterMipsToX86 emiter, Emiter.Label* labelTrue, Emiter.Label* labelFalse) {
			emiter.MIPS_TICK(PC, count); count = 0;

			if (!jumpAlways) {
				if (isLikely) {
					emitBranchFalse(emiter, labelFalse);
				} else {
					emiter.MOV(Register32.EAX, emiter.MIPS_GET_REGISTER(RS)); emiter.MOV(emiter.MIPS_GET_CMP(0), Register32.EAX);
					emiter.MOV(Register32.EAX, emiter.MIPS_GET_REGISTER(RT)); emiter.MOV(emiter.MIPS_GET_CMP(1), Register32.EAX);
				}
			}
		}

		void emitPostDelayed(uint PC, uint JumpPC, EmiterMipsToX86 emiter, Emiter.Label* labelTrue, Emiter.Label* labelFalse) {
			if (!jumpAlways) {
				if (!isLikely) emitBranchFalse(emiter, labelFalse);
			}
			
			void OP_UNK() {
				if (jumpAddress == -1) {
					throw(new Exception("emitPostDelayed unknown address?"));
				} else {
					emiter.JMP(labelTrue);
				}
			}
			
			string Link() { return q{
				emiter.MOV(emiter.MIPS_GET_REGISTER(Register.RA), PC + 8);
			}; }
			
			string JumpRegister() { return q{
				emiter.PUSH(emiter.MIPS_GET_REGISTER(RS));
				emiter.CALL(&JUMP_PC);
				emiter.ADD(Register32.ESP, 4);
				emiter.RET();
			}; }
			
			string JumpAddress() { return q{
				emiter.PUSH(JumpPC);
				emiter.CALL(&JUMP_PC);
				emiter.ADD(Register32.ESP, 4);
				emiter.RET();
			}; }
			
			void OP_J() {
				emiter.JMP(labelTrue);
			}
			void OP_JAL() { mixin(Link ~ JumpAddress); }
			void OP_JALR() { mixin(Link ~ JumpRegister); }
			void OP_JR() { mixin(JumpRegister); }
			mixin(genSwitch(PspInstructions));
			
		}
	}

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
			} catch (Object o) {
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