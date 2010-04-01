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

class EmiterMipsToX86 : EmiterX86 {
	enum MipsRegisters : uint {
		// +00 +01 +02 +03 +04 +05 +06 +07
		    ZR, AT, V0, V1, A0, A1, A2, A3, // +00
		    T0, T1, T2, T3, T4, T5, T6, T7, // +08
		    S0, S1, S2, S3, S4, S5, S6, S7, // +16
		    T8, T9, K0, K1, GP, SP, FP, RA, // +24
	}

	void execute(uint offset = 0) {
		writeLabels();
		auto func = buffer.ptr + offset;
		//asm { int 3; }
		asm { mov EAX, func; call EAX; }
	}

	void execute(uint registers, uint offset = 0) {
		writeLabels();
		auto func = buffer.ptr + offset;
		//asm { int 3; }
		asm { mov ECX, registers; mov EAX, func; call EAX; }
	}
	
	void execute(Registers registers, Label* label = null) {
		execute(cast(uint)&registers.R, (label !is null) ? label.address : 0);
	}

	void MIPS_LOAD_REGISTER_TABLE(uint register_table) {
		MOV(Register32.ECX, register_table);
	}

	byte MIPS_GET_DISPLACEMENT(MipsRegisters mipsRegister) {
		return cast(byte)(4 * (mipsRegister & 31));
	}

	void MIPS_LOAD_REGISTER(Register32 x32RegTo, MipsRegisters mipsRegFrom) {
		if (mipsRegFrom == 0) {
			MOV(x32RegTo, 0);
		} else {
			MOV_FROMPTR(Register32.ECX, x32RegTo, MIPS_GET_DISPLACEMENT(mipsRegFrom));
		}
	}

	void MIPS_STORE_REGISTER(Register32 x32RegFrom, MipsRegisters mipsRegTo) {
		if (mipsRegTo == 0) return;
		MOV_TOPTR(Register32.ECX, x32RegFrom, MIPS_GET_DISPLACEMENT(mipsRegTo));
	}

	void MIPS_STORE_REGISTER_VALUE(uint value, MipsRegisters mipsRegTo) {
		if (mipsRegTo == 0) return;
		MOV_TOPTR(Register32.ECX, value, MIPS_GET_DISPLACEMENT(mipsRegTo));
	}

	void MIPS_LI(MipsRegisters rt, uint value) {
		MIPS_STORE_REGISTER_VALUE(value, rt); return;
	}
	
	void MIPS_NOP() {
	}

	mixin Cpu_Alu_Emiter;
	mixin Cpu_Memory_Emiter;

	void MIPS_SYSCALL(uint PC, uint code) {
		PUSH(Register32.ECX);
		{
			PUSH(code);
			PUSH(PC);
			CALL(createLabelToFunction(&SYSCALL));
			ADD(Register32.ESP, 8);
		}
		POP(Register32.ECX);
		RET();
	}

	void MIPS_PREPARE_CMP(MipsRegisters rs, MipsRegisters rt) {
		MIPS_LOAD_REGISTER(Register32.EAX, rs);
		MIPS_LOAD_REGISTER(Register32.EDX, rt);
		CMP(Register32.EAX, Register32.EDX);
	}

	void MIPS_TICK(uint PC, uint count = 1) {
		PUSH(Register32.ECX);
		PUSH(PC);
		PUSH(count);
		CALL(createLabelToFunction(&SYSTEM_TICK));
		ADD(Register32.ESP, 8);
		POP(Register32.ECX);
		CMP(Register32.EAX, 0);
		JE(1);
		RET();
	}
}

static Cpu lastCpu;

static extern(C) {
	bool SYSTEM_TICK(uint COUNT, uint PC) {
		static uint count = 0;
		lastCpu.registers.PC = PC;
		lastCpu.registers.nPC = PC + 4;
		count += COUNT;
		if (!(count & 0xFFFF)) {
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

		//std.c.stdio.printf("%08X\n", PC);
		return false;
	}

	void MEMORY_WRITE_8(uint addr, ubyte value) {
		//writefln("WRITE(%08X) <- %02X", addr, value);
		//lastCpu.memory[addr] = value;
		lastCpu.memory.write8(addr, value);
	}

	void SYSCALL(uint PC, uint code) {
		lastCpu.registers.PC  = PC + 4;
		lastCpu.registers.nPC = PC + 8;
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

class CpuDynaRec : Cpu {
	this(Memory memory, Gpu gpu, Display display, IController controller) {
		super(memory, gpu, display, controller);
	}

	alias EmiterMipsToX86.MipsRegisters Register;

	struct InstructionInfo {
		uint PC;
		//InstructionDefinition instructionDefinition;
		Instruction instruction;
		bool isJump, jumpAlways, isLikely, jumpLink, isEndOfBranch;
		uint jumpAddress;
		bool inDelayedBranch;
		int count = 0;

		enum Likely { NO, YES }
		enum Link   { NO, YES }

		void set(uint PC, uint v) {
			this.PC = PC; instruction.v = v;
		}

		void parseJumps() {
			auto instruction = this.instruction;
			
			static pure nothrow string BRANCH(Likely likely, Link link, string alwaysCondition) {
				return (
					"isJump = true;"
					"isLikely = " ~ (likely ? "true" : "false") ~ ";"
					"jumpLink   = " ~ (link ? "true" : "false") ~ ";"
					"jumpAlways = " ~ alwaysCondition ~ ";"
					//"isEndOfBranch = " ~ alwaysCondition ~ ";" // To optimize!
					"isEndOfBranch = false;"
					"jumpAddress = PC + instruction.OFFSET2 + 4;"
				);
			}
			static pure nothrow string BRANCH_S(Likely likely, string condition) { return BRANCH(likely, Link.NO, condition); }

			void OP_BEQ    () { mixin(BRANCH(Likely.NO , Link.NO , "instruction.RS == instruction.RT")); }
			void OP_BEQL   () { mixin(BRANCH(Likely.YES, Link.NO , "instruction.RS == instruction.RT")); }
			void OP_BGEZ   () { mixin(BRANCH(Likely.NO , Link.NO , "instruction.RS == 0")); }
			void OP_BGEZAL () { mixin(BRANCH(Likely.NO , Link.YES, "instruction.RS == 0")); }
			void OP_BGEZL  () { mixin(BRANCH(Likely.YES, Link.NO , "instruction.RS == 0")); }
			void OP_BGTZ   () { mixin(BRANCH(Likely.NO , Link.NO , "false")); }
			void OP_BGTZL  () { mixin(BRANCH(Likely.YES, Link.NO , "false")); }
			void OP_BLEZ   () { mixin(BRANCH(Likely.NO , Link.NO , "instruction.RS == 0")); }
			void OP_BLEZL  () { mixin(BRANCH(Likely.YES, Link.NO , "instruction.RS == 0")); }
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

			void OP_J   () { isJump = true; jumpAlways = true; isEndOfBranch = true ; jumpAddress = instruction.JUMP2; }
			void OP_JR  () { isJump = true; jumpAlways = true; isEndOfBranch = true ; jumpAddress = -1; }
			void OP_JAL () { isJump = true; jumpAlways = true; isEndOfBranch = false; jumpAddress = instruction.JUMP2; }
			void OP_JALR() { isJump = true; jumpAlways = true; isEndOfBranch = false; jumpAddress = -1; }

			void OP_UNK() {
				isJump = jumpAlways = isLikely = jumpLink = isEndOfBranch = false;
				jumpAddress = -1;
				//writefln("UNK");
			}

			count++;
			mixin(genSwitch(PspInstructions));
		}
		
		void emitNonDelayed(EmiterMipsToX86 emiter) {
			auto instruction = this.instruction;
			auto inDelayedBranch = this.inDelayedBranch;

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
		
		void emitPreDelayed(EmiterMipsToX86 emiter, Emiter.Label* label) {
			emiter.MIPS_TICK(PC, count); count = 0;

			if (jumpAlways) {
				//emiter.PUSHF();
				return;
			}

			void OP_UNK() {
				debug (DEBUG_DYNA_CODE_GEN) writefln("CMP r%d, r%d", instruction.RS, instruction.RT);
				emiter.MIPS_PREPARE_CMP(cast(Register)instruction.RS, cast(Register)instruction.RT);
				//emiter.PUSHF();
			}

			void OP_J() {
			}

			mixin(genSwitch(PspInstructions));
		}

		void emitPostDelayed(EmiterMipsToX86 emiter, Emiter.Label* label) {
			if (jumpAlways) {
				emiter.JMP(label);
				return;
			}
			
			//emiter.POPF();

			void OP_UNK() {
				throw(new UnknownOperationException(PC, "Unknown jump"));
				//debug (DEBUG_DYNA_CODE_GEN) writefln("Unknown jump!");
			}
			void OP_BNE() {
				emiter.JNE(label);
			}
			void OP_J() {
				emiter.JMP(label);
			}
			void OP_BGEZ() {
				emiter.JGE(label);
			}
			mixin(genSwitch(PspInstructions));
		}
	}

	struct CodeBlock {
		EmiterMipsToX86 emiter;
		Emiter.Label*[uint] labels;
		uint from, to;
		
		void execute(Registers registers, uint PC) {
			emiter.execute(registers, labels[PC]);
		}
	}
	
	CodeBlock*[uint] globalLabels;

	CodeBlock[uint] codeBlocks;

	void reset() {
		globalLabels = null;
		codeBlocks = null;
		super.reset();
	}

	/*CodeBlock* locateLabel(uint PC) {
		writefln("locateLabel");
		foreach (cPC, ref codeBlock; codeBlocks) {
			//writefln("  locateLabel(%08X, %08X-%08X)", PC, codeBlock.from, codeBlock.to);
			if (PC >= codeBlock.from && PC < codeBlock.to) {
				return &codeBlocks[cPC];
			}
		}
		return null;
	}*/

	void executePC(uint PC) {
		//auto block = locateLabel(PC);
		CodeBlock** block = (PC in globalLabels);
		
		// Miss.
		if (block is null) {
			analyzeFunction(PC);
			//block = locateLabel(PC);
			block = (PC in globalLabels);
		}
		
		(*block).execute(registers, PC);
	}

	void analyzeFunction(uint PC) {
		InstructionMarker explored = new InstructionMarker;
		InstructionInfo instructionInfo, delayedInstructionInfo;
		bool[uint] branchesToExplore;
		auto emiter = new EmiterMipsToX86;
		Emiter.Label*[uint] labels;
		uint StartPC = PC;
		uint maxPC = 0x00000000, minPC = 0xFFFFFFFF;
		
		Emiter.Label* getLabel(uint PC) {
			if ((PC in labels) is null) labels[PC] = emiter.createLabel();
			return labels[PC];
		}
		
		//emiter.MIPS_LOAD_REGISTER_TABLE(cast(uint)&registers.R[0]);

		try {
			branchesToExplore[StartPC] = true;
			explored.reset();
			while (branchesToExplore.length) {
				// Extract a PC to start processing.
				PC = branchesToExplore.keys[0]; branchesToExplore.remove(PC);
				if (PC < minPC) minPC = PC;

				for (; !explored.marked(PC); PC += 4) {
					explored.mark(PC);

					emiter.setLabelHere(getLabel(PC));

					//if (PC == StartPC) emiter.INT3(); // Debugger

					instructionInfo.set(PC, memory.read32(PC));
					instructionInfo.parseJumps();

					debug (DEBUG_DYNA_CODE_GEN) writefln("EMIT:%08X", PC);
					// Jump.
					if (instructionInfo.isJump) {
						Emiter.Label* label = getLabel(instructionInfo.jumpAddress);

						//auto dis = new AllegrexDisassembler(memory); writefln(":::%s", dis.dissasm(PC, memory));

						instructionInfo.emitPreDelayed(emiter, label);
						labels[PC + 4] = emiter.createLabelAndSetHere();
						delayedInstructionInfo.set(PC + 4, memory.read32(PC + 4));
						delayedInstructionInfo.inDelayedBranch = true;
						delayedInstructionInfo.emitNonDelayed(emiter);
						instructionInfo.emitPostDelayed(emiter, label);
						PC += 4;
					}
					// No jump.
					else {
						instructionInfo.emitNonDelayed(emiter);
					}

					if (instructionInfo.isJump) {
						debug (DEBUG_DYNA_CODE_GEN) writefln(" EXP: %08X", instructionInfo.jumpAddress);
						branchesToExplore[instructionInfo.jumpAddress] = true;
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
		
		foreach (cPC, label; labels) {
			//writefln("LABEL: %08X", cPC);
		}
		
		codeBlocks[minPC] = CodeBlock(emiter, labels.rehash, minPC, maxPC);
		codeBlocks = codeBlocks.rehash;

		CodeBlock* block = minPC in codeBlocks;
		
		foreach (cPC, label; labels) {
			//writefln("LABEL: %08X", cPC);
			globalLabels[cPC] = block;
		}
		
		globalLabels = globalLabels.rehash;
	}

	void execute(uint count) {
		lastCpu = this;

		while (true) {
			//writefln("execute: %08X", registers.PC);
			
			executePC(registers.PC);
		}
	}
}