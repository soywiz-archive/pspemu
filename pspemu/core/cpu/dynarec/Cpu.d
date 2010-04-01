module pspemu.core.cpu.dynarec.Cpu;

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

class EmiterMipsToX86 : EmiterX86 {
	enum MipsRegisters : uint {
		// +00 +01 +02 +03 +04 +05 +06 +07
		    ZR, AT, V0, V1, A0, A1, A2, A3, // +00
		    T0, T1, T2, T3, T4, T5, T6, T7, // +08
		    S0, S1, S2, S3, S4, S5, S6, S7, // +16
		    T8, T9, K0, K1, GP, SP, FP, RA, // +24
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
		/*
		if (value & ~0xFFFF) {
			MIPS_LUI(rt, value >> 16);
			MIPS_ORI(rt, rt, value & 0xFFFF);
		} else {
			MIPS_ORI(rt, MipsRegisters.ZR, value & 0xFFFF);
		}
		*/
	}
	
	void MIPS_NOP() {
	}

	void MIPS_ADDU(MipsRegisters rd, MipsRegisters rs, MipsRegisters rt) {
		if (rd == 0) return;
		MIPS_LOAD_REGISTER(Register32.EAX, rs);
		MIPS_LOAD_REGISTER(Register32.EDX, rt);
		ADD(Register32.EAX, Register32.EDX);
		MIPS_STORE_REGISTER(Register32.EAX, rd);
	}

	void MIPS_ADDIU(MipsRegisters rd, MipsRegisters rs, uint value) {
		if (rd == 0) return;
		if (rs == 0) {
			MIPS_STORE_REGISTER_VALUE(value, rd);
		} else {
			MIPS_LOAD_REGISTER(Register32.EAX, rs);
			ADD_EAX(value);
			MIPS_STORE_REGISTER(Register32.EAX, rd);
		}
	}

	void MIPS_ORI(MipsRegisters rd, MipsRegisters rs, ushort value) {
		if (rd == 0) return;
		if (rs == 0) {
			MIPS_STORE_REGISTER_VALUE(value, rd);
		} else {
			MIPS_LOAD_REGISTER(Register32.EAX, rs);
			if (value != 0) OR_AX(value);
			MIPS_STORE_REGISTER(Register32.EAX, rd);
		}
	}

	void MIPS_LUI(MipsRegisters rt, ushort value) {
		/*
		MOV(Register32.EAX, 0);
		OR_AX(value);
		SHL(Register32.EAX, 16);
		MIPS_STORE_REGISTER(Register32.EAX, rt);
		*/
		MIPS_STORE_REGISTER_VALUE((value << 16), rt);
	}

	void MIPS_SB(MipsRegisters rt, MipsRegisters rs, short offset) {
		// Value
		MIPS_LOAD_REGISTER(Register32.EAX, rt);
		PUSH(Register32.EAX);

		// Address
		MIPS_LOAD_REGISTER(Register32.EAX, rs);
		if (offset != 0) ADD_EAX(cast(int)offset);
		PUSH(Register32.EAX);
		{
			CALL(createLabelToFunction(&MEMORY_WRITE_8));
		}
		ADD(Register32.ESP, 8);
	}

	void MIPS_SYSCALL(uint code) {
		PUSH(code);
		CALL(createLabelToFunction(&SYSCALL));
		ADD(Register32.ESP, 4);
	}

	void MIPS_PREPARE_CMP(MipsRegisters rs, MipsRegisters rt) {
		MIPS_LOAD_REGISTER(Register32.EAX, rs);
		MIPS_LOAD_REGISTER(Register32.EDX, rt);
		CMP(Register32.EAX, Register32.EDX);
	}

	void MIPS_BNE(Label* label) {
		JNE(label);
	}

	void MIPS_J(Label* label) {
		JMP(label);
	}
}

//static Memory lastMemory;
//static ISyscall lastSyscall;
static Cpu lastCpu;

static extern(C) void MEMORY_WRITE_8(uint addr, ubyte value) {
	writefln("WRITE(%08X) <- %02X", addr, value);
	//lastCpu.memory[addr] = value;
	lastCpu.memory.write8(addr, value);
}

static extern(C) void SYSCALL(uint code) {
	writefln("SYSCALL %08X", code);
	lastCpu.syscall(code);
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

		enum Likely { NO, YES }
		enum Link   { NO, YES }

		void set(uint PC, uint v) {
			this.PC = PC; instruction.v = v;
		}

		void parseJumps() {
			void OP_UNK() {
				isJump = jumpAlways = isLikely = jumpLink = isEndOfBranch = false;
				jumpAddress = -1;
				//writefln("UNK");
			}
			
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

			void OP_BEQ () { mixin(BRANCH(Likely.NO , Link.NO , "instruction.RS == instruction.RT")); }
			void OP_BEQL() { mixin(BRANCH(Likely.YES, Link.NO , "instruction.RS == instruction.RT")); }
			void OP_BGEZ  () { mixin(BRANCH(Likely.NO , Link.NO , "instruction.RS == 0")); }
			void OP_BGEZAL() { mixin(BRANCH(Likely.NO , Link.YES, "instruction.RS == 0")); }
			void OP_BGEZL () { mixin(BRANCH(Likely.YES, Link.NO , "instruction.RS == 0")); }
			void OP_BGTZ () { mixin(BRANCH(Likely.NO , Link.NO , "false")); }
			void OP_BGTZL() { mixin(BRANCH(Likely.YES, Link.NO , "false")); }
			void OP_BLEZ () { mixin(BRANCH(Likely.NO , Link.NO , "instruction.RS == 0")); }
			void OP_BLEZL() { mixin(BRANCH(Likely.YES, Link.NO , "instruction.RS == 0")); }
			void OP_BLTZ   () { mixin(BRANCH(Likely.NO , Link.NO , "false")); }
			void OP_BLTZL  () { mixin(BRANCH(Likely.YES, Link.NO , "false")); }
			void OP_BLTZAL () { mixin(BRANCH(Likely.NO , Link.YES, "false")); }
			void OP_BLTZALL() { mixin(BRANCH(Likely.YES, Link.YES, "false")); }
			void OP_BNE () { mixin(BRANCH(Likely.NO , Link.NO , "false")); }
			void OP_BNEL() { mixin(BRANCH(Likely.YES, Link.NO , "false")); }

			void OP_BC1F () { mixin(BRANCH_S(Likely.NO,  "false")); }
			void OP_BC1FL() { mixin(BRANCH_S(Likely.YES, "false")); }
			void OP_BC1T () { mixin(BRANCH_S(Likely.NO,  "false")); }
			void OP_BC1TL() { mixin(BRANCH_S(Likely.YES, "false")); }

			void OP_J() { isJump = true; jumpAlways = true; isEndOfBranch = true; jumpAddress = instruction.JUMP2; }
			void OP_JR() { isJump = true; jumpAlways = true; isEndOfBranch = true; jumpAddress = -1; }
			void OP_JAL() { isJump = true; jumpAlways = true; isEndOfBranch = false; jumpAddress = instruction.JUMP2; }
			void OP_JALR() { isJump = true; jumpAlways = true; isEndOfBranch = false; jumpAddress = -1; }

			mixin(genSwitch(PspInstructions));
		}
		
		void emitNonDelayed(EmiterMipsToX86 emiter) {
			void OP_UNK() { writefln("Unknown instruction 0x%08X at 0x%08X", instruction.v, PC); }
			void OP_LUI() {
				writefln("LUI r%d, %04X", instruction.RT, cast(ushort)instruction.IMMU);
				emiter.MIPS_LUI(cast(Register)instruction.RT, cast(ushort)instruction.IMMU);
			}
			void OP_ORI() {
				writefln("ORI r%d, r%d, %04X", instruction.RT, instruction.RS, cast(ushort)instruction.IMMU);
				emiter.MIPS_ORI(cast(Register)instruction.RT, cast(Register)instruction.RS, cast(ushort)instruction.IMMU);
			}
			void OP_ADDI() {
				writefln("ADDI r%d, r%d, %d", instruction.RT, instruction.RS, cast(short)instruction.IMM);
				emiter.MIPS_ADDIU(cast(Register)instruction.RT, cast(Register)instruction.RS, cast(int)instruction.IMM);
			}
			alias OP_ADDI OP_ADDIU;
			void OP_SB() {
				writefln("SB r%d, %d(r%d)", instruction.RT, cast(short)instruction.OFFSET, instruction.RS);
				emiter.MIPS_SB(cast(Register)instruction.RT, cast(Register)instruction.RS, cast(ushort)instruction.OFFSET);
			}
			void OP_SYSCALL() {
				writefln("SYSCALL 0x%08X", instruction.CODE);
				emiter.MIPS_SYSCALL(instruction.CODE);
			}
			void OP_SLL() {
				writefln("Not implemented SLL!");
			}
			mixin(genSwitch(PspInstructions));
		}
		
		void emitPreDelayed(EmiterMipsToX86 emiter, Emiter.Label* label) {
			if (jumpAlways) {
				return;
			}

			void OP_UNK() {
				writefln("CMP r%d, r%d", instruction.RS, instruction.RT);
				emiter.MIPS_PREPARE_CMP(cast(Register)instruction.RS, cast(Register)instruction.RT);
			}
			void OP_J() {
			}
			mixin(genSwitch(PspInstructions));
		}

		void emitPostDelayed(EmiterMipsToX86 emiter, Emiter.Label* label) {
			void OP_UNK() {
				writefln("Unknown jump!");
			}
			void OP_BNE() {
				emiter.MIPS_BNE(label);
			}
			void OP_J() {
				emiter.MIPS_J(label);
			}
			mixin(genSwitch(PspInstructions));
		}
	}

	void analyzeFunction(uint PC) {
		InstructionMarker explored = new InstructionMarker;
		InstructionInfo instructionInfo, delayedInstructionInfo;
		bool[uint] branchesToExplore;
		auto emiter = new EmiterMipsToX86;
		Emiter.Label*[uint] labels;
		uint StartPC = PC;
		
		enum Pass { ANALYZE = 0, EMIT = 1 }
		
		//emiter.INT3(); // Debugger
		emiter.MIPS_LOAD_REGISTER_TABLE(cast(uint)&registers.R[0]);

		// Two passes.
		foreach (pass; [Pass.ANALYZE, Pass.EMIT]) {
			branchesToExplore[StartPC] = true;
			explored.reset();
			while (branchesToExplore.length) {
				// Extract a PC to start processing.
				PC = branchesToExplore.keys[0]; branchesToExplore.remove(PC);

				// If we are analyzing and we didn't set this address. We will create a label for it.
				if (pass == Pass.ANALYZE) {
					if ((PC in labels) is null) {
						labels[PC] = emiter.createLabel;
					}
				}

				for (; !explored.marked(PC); PC += 4) {
					explored.mark(PC);

					if (pass == Pass.EMIT) {
						if (PC in labels) {
							emiter.setLabelHere(labels[PC]);
						}
					}

					instructionInfo.set(PC, memory.read32(PC));
					instructionInfo.parseJumps();

					if (pass == Pass.EMIT) {
						//writefln("EMIT:%08X", PC);
						// Jump.
						if (instructionInfo.isJump) {
							Emiter.Label* label = labels[instructionInfo.jumpAddress];

							//auto dis = new AllegrexDisassembler(memory); writefln(":::%s", dis.dissasm(PC, memory));

							instructionInfo.emitPreDelayed(emiter, label);
							delayedInstructionInfo.set(PC + 4, memory.read32(PC + 4));
							delayedInstructionInfo.emitNonDelayed(emiter);
							instructionInfo.emitPostDelayed(emiter, label);
							PC += 4;
						}
						// No jump.
						else {
							instructionInfo.emitNonDelayed(emiter);
						}
					}

					if (instructionInfo.isJump) {
						//writefln(" EXP: %08X", instructionInfo.jumpAddress);
						branchesToExplore[instructionInfo.jumpAddress] = true;
					}

					if (instructionInfo.isEndOfBranch) {
						break;
					}
				}
			}
		}
		
		//std.file.write("test.bin", emiter.writedCode);
		lastCpu = this;
		//lastMemory  = memory;
		//lastSyscall = syscall;
		emiter.execute();
	}

	void execute(uint count) {
		analyzeFunction(registers.PC);
		throw(new Exception("Oh, noes!"));
	}
}