module pspemu.core.cpu.dynarec.InstructionInfo;

import pspemu.core.cpu.Instruction;
import pspemu.core.cpu.Registers;
import pspemu.core.cpu.dynarec.EmiterX86;
import pspemu.core.cpu.dynarec.EmiterMipsToX86;

import pspemu.core.cpu.tables.Table;
import pspemu.core.cpu.tables.SwitchGen;
import pspemu.core.cpu.tables.DummyGen;

alias EmiterMipsToX86.MipsRegisters Register;
alias EmiterX86.Register32 Register32;

template SimplifyInstructionAccess() {
	Register RS() { return cast(Register)instruction.RS; }
	Register RT() { return cast(Register)instruction.RT; }
	Register RD() { return cast(Register)instruction.RD; }
	ushort IMMU() { return cast(ushort)instruction.IMMU; }
	int    IMM () { return cast(int)instruction.IMM; }
	ubyte  POS () { return cast(ubyte)instruction.POS; }
}

/+
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
+/