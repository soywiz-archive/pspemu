module psp.cpu;

import std.stream;
import std.stdio;
import std.c.string;
import std.c.time;
import std.random;
import std.math;

import psp.memory;
import psp.disassembler.cpu;
import psp.controller;
import psp.gpu;

//debug = used_i; // Register used instructions
//debug = used_a; // Register used addresses
//version = fake_registers; // Ignore zr writting
//version = fast_pc_read;   // Executing only from main ram (ignoring bad addresses)

debug (used_i) ulong[char[]] used_i_table;
debug (used_a) ulong[uint  ] used_a_table;

static final int MASK(byte bits) {
	return ((1 << bits) - 1);
}

class InterruptException : Exception { this(char[] s) { super(s); } }
class ExitException : Exception { this() { super("ExitException"); } }

interface IBIOS {
	void jump0(uint addr);
	void syscall(uint code);
	char[] addInfo(uint addr);
}

static final class CPU {
	static Memory mem;
	static Registers regs;
	static Controller ctrl;
	static IBIOS bios;
	static GPU gpu;
	static bool interrupt = false;	
	static bool stopped = true;
	static bool paused = true;
	static bool ignoreErrors = false;
	
	static const char[] inc_pc = "PC = nPC; nPC += 4;";
	
	static this() {
		writefln("CPU.static this()");
		mem = new Memory();
		regs = mem.regs;
		ctrl = new Controller();		
		gpu = new GPU(mem);
	}
	
	static uint[0x1000] callstack;
	static uint callstack_length;
	
	static void _return() {
		regs._PC = regs[Registers.R.ra];
		if (callstack_length > 0) callstack_length--;
	}

	static ulong tick;
	static bool stop = false;
	static bool updateDebug = false;
	static bool next = false;
	static bool nextOver = false;
	static uint pauseAt;
	
	static char[] disasm(uint PC) {
		writefln("%08X: %s", PC, CPU_Disasm.disasm(PC, mem.read4(PC)).text);		
		return "";
	}
	
	static void dumpRegs(bool simplify = true) {
		regs.dump(simplify);
	}
	
	static void pauseExtern() {
		pauseAt = 0;
		interrupt = true;
		//next = 0;
		
		debug (used_i) {
			writefln("used_i_table {");
			foreach (k, c; used_i_table) {
				writefln("  ", k, " : ", c);
			}
			writefln("}");
			used_i_table = null;
		}
		
		debug (used_a) {
			writefln("used_i_table {");
			foreach (k; used_a_table.keys.sort) { ulong c = used_a_table[k];
				writefln("  0x%08X : ", k, c, " | ", CPU_Disasm.disasm(k, mem.read4(k)).text);
			}
			writefln("}");
			used_a_table = null;
		}

		if (stopped) return;
		while (!paused) {
			//printf("<");
			usleep(1000);
		}
	}
	
	static void resumeExtern() {
		interrupt = false;
	}
	
	static void resetExtern() {
		//callstack = [regs.PC];
		callstack_length = 0;
	}
	
	static void _run() {
		scope (exit) { .writefln("CPU._run.exit()"); sync_out(); updateDebug = stopped = paused = true; }
		
		int count = 0;		
		uint OP   = void;
		bool LOG  = false;
		uint PC, nPC;	
		
		uint*  regs_p  = regs.r.ptr;
		float* regs_f  = regs.f.ptr;
		int* intQueued = &mem.interrupts.queued;

		uint RTU() { return regs_p[(OP >> 16) & 0x1F]; }
		uint RSU() { return regs_p[(OP >> 21) & 0x1F]; }
		uint RDU() { return regs_p[(OP >> 11) & 0x1F]; }
		int  RT () { return regs_p[(OP >> 16) & 0x1F]; }
		int  RS () { return regs_p[(OP >> 21) & 0x1F]; } 
		int  RD () { return regs_p[(OP >> 11) & 0x1F]; }	
		
		version (fake_registers) {
			void sRT(uint v) { regs_p[(OP >> 16) & 0x1F] = v; }
			void sRS(uint v) { regs_p[(OP >> 21) & 0x1F] = v; }
			void sRD(uint v) { regs_p[(OP >> 11) & 0x1F] = v; }
		} else {		
			void sRD(uint v) { regs[(OP >> 11) & 0x1F] = v; }
			void sRT(uint v) { regs[(OP >> 16) & 0x1F] = v; }
			void sRS(uint v) { regs[(OP >> 21) & 0x1F] = v; }
		}
		
		void sRA(uint v) {
			regs_p[31] = v;
			if (nextOver) {
				nextOver = false;
				pauseAt = v;
				next = false;
			}
		}

		float FD() { return regs_f[(OP >>  6) & 0x1F]; }	
		float FT() { return regs_f[(OP >> 16) & 0x1F]; }
		float FS() { return regs_f[(OP >> 11) & 0x1F]; } 

		double FD_d() { return *(cast(double *)&regs_f[(OP >>  6) & 0x1F]); }	
		double FT_d() { return *(cast(double *)&regs_f[(OP >> 16) & 0x1F]); }
		double FS_d() { return *(cast(double *)&regs_f[(OP >> 11) & 0x1F]); } 

		void sFD(float v) { regs_f[(OP >>  6) & 0x1F] = v; }
		void sFT(float v) { regs_f[(OP >> 16) & 0x1F] = v; }
		void sFS(float v) { regs_f[(OP >> 11) & 0x1F] = v; }

		void sFD_d(double v) { *(cast(double *)&regs_f[(OP >>  6) & 0x1F]) = v; }
		void sFT_d(double v) { *(cast(double *)&regs_f[(OP >> 16) & 0x1F]) = v; }
		void sFS_d(double v) { *(cast(double *)&regs_f[(OP >> 11) & 0x1F]) = v; }
		
		short  IMM () { return (OP & 0xFFFF); }
		ushort IMMU() { return (OP & 0xFFFF); }		

		uint SA()   { return ((OP >> 6)  & 0x1F); }
		uint SIZE() { return ((OP >> 11) & 0x1F); }
		uint POS()  { return ((OP >> 6)  & 0x1F); }			
		
		uint CODE() { return ((OP >> 6) & 0xFFFFF); }
		uint JUMP() { return ((PC & 0xF0000000) | ((OP & 0x3FFFFFF) << 2)); }		
		uint CO() { return (OP >> 26) & 0b_111111; }
		
		void sync_out() {
			regs.PC = PC;
			regs.nPC = nPC;
		}

		void sync_in() {
			PC = regs.PC;
			nPC = regs.nPC;
		}
		
		ubyte REV1(ubyte b) { return ((b * 0x0802LU & 0x22110LU) | (b * 0x8020LU & 0x88440LU)) * 0x10101LU >> 16;  }
		uint  REV4(uint  v) { return (REV1((v >>  0) & 0xFF) << 24) | (REV1((v >>  8) & 0xFF) << 18) | (REV1((v >> 16) & 0xFF) <<  8) | (REV1((v >> 24) & 0xFF) <<  0); }
		
		uint ROTR(uint a, uint b) { b = (b & 0x1F);
			asm { mov EAX, a; mov ECX, b; ror EAX, CL; mov a, EAX; }
			return a;
		}
		
		uint SLL(int a, int b) { asm { mov EAX, a; mov ECX, b; shl EAX, CL; mov a, EAX; } return a; }
		uint SRL(int a, int b) { asm { mov EAX, a; mov ECX, b; shr EAX, CL; mov a, EAX; } return a; }
		uint SRA(int a, int b) { asm { mov EAX, a; mov ECX, b; sar EAX, CL; mov a, EAX; } return a; }
		uint SLA(int a, int b) { asm { mov EAX, a; mov ECX, b; sal EAX, CL; mov a, EAX; } return a; }
		uint MIN(int a, int b) { return (a < b) ? a : b; }
		uint MAX(int a, int b) { return (a > b) ? a : b; }
		void MULT (int  a, int  b) { int l, h; asm { mov EAX, a; mov EBX, b; imul EBX; mov l, EAX; mov h, EDX; } regs.LO = l; regs.HI = h; }
		void MULTU(uint a, uint b) { int l, h; asm { mov EAX, a; mov EBX, b; mul EBX; mov l, EAX; mov h, EDX; } regs.LO = l; regs.HI = h; }
		void DIV (int  a, int  b) { regs.LO = a / b; regs.HI = a % b; }
		void DIVU(uint a, uint b) { regs.LO = a / b; regs.HI = a % b; }
		void EXT() { sRT = (RS >> POS) & MASK(SIZE + 1); }
		void INS() { uint mask = MASK(SIZE - POS + 1); sRT = (RT & ~(mask << POS)) | ((RS & mask) << POS); }
		uint SEB(ubyte r0) { uint r1; asm { xor EAX, EAX; mov AL, r0; movsx EBX, AL; mov r1, EBX; } return r1; }
		uint SEH(ushort r0) { uint r1; asm { xor EAX, EAX; mov AX, r0; movsx EBX, AX; mov r1, EBX; } return r1; }
		void MADD() { int rs = RS, rt = RT, lo = regs.LO, hi = regs.HI; asm { mov EAX, rs; imul rt; add lo, EAX; adc hi, EDX; } regs.LO = lo; regs.HI = hi; }
		void TRUNC_W_S() { float s = FS, d = void; asm { movss XMM0, s; cvttss2si EAX, XMM0; mov d, EAX; } sFD = d; }
		void CVT_S_W() { float s = FS; float d = void; asm { cvtsi2ss XMM0, s; movss d, XMM0; } sFD = d; }
		bool QNAN() { return (isnan(FS) || isnan(FT)); }
		
		void UNK_OP() { throw(new Exception(std.string.format("UNK_OP: 0x%08X", OP))); }
		void UNI_OP(char[] n = "unknown") { throw(new Exception(std.string.format("UNI_OP: 0x%08X ('%s')", OP, n))); }
		void UNK_OP_P(uint p) { throw(new Exception(std.string.format("UNK_OP_P: 0x%08X : 0x%08X", OP, p))); }
		
		sync_in();
		
		paused = false;
		stopped = false;
		stop = false;
		interrupt = true;
		pauseAt = 0;

		uint delegate(uint) pc_read = void;
		
		version (fast_pc_read) {
			pc_read = &mem._read4;
		} else {
			pc_read = &mem.read4;
		}
		
		while (true) { try { while (true) {		
			//if (*interruptFlags) processInterrupts();
			
			tick++;
			
			if ((tick % 40000) == 0) mem.interrupts.queue(INTS.THREAD0);
			
			if (*intQueued) {
				sync_out();
				{
					mem.interrupts.process();
				}
				sync_in();
			}

			if (interrupt) {
				if (stop) {
					sync_out();
					updateDebug = true;
					return;
				}
				
				if (!pauseAt || pauseAt == PC) {
					pauseAt = 0;
				
					sync_out();
					{						
						updateDebug = true;
						paused = true;						
						while (!next && interrupt) usleep(10000);
						paused = false;
					}
					sync_in();
					
					next = false;					
				}
			}
			
			debug (used_a) {
				if ((PC in used_a_table) is null) used_a_table[PC] = 0;
				used_a_table[PC]++;
			}
			
			OP = pc_read(PC);
			
			//mixin(import("cpu_switch.back.d"));
			mixin(import("cpu_switch.d"));
			
		} } catch (ExitException e) {
			writefln("Program end");
			return;
		} catch (Exception e) {
			ErrorResult retval =  ErrorResult.ABORT;
			
			if (e.classinfo.name == InterruptException.classinfo.name) {
				interrupt = true;
				sync_in();
			}
		
			sync_out();
			{
				updateDebug = true;
				paused = true;
				
				char[] str = e.toString;
				
				try {
					str = std.string.format("%s\n\n%08X: %s", e.toString, PC, CPU_Disasm.disasm(PC, mem.read4(PC)));				
					disasm(PC);
				} catch {
				}
				
				writefln("--------------------------------------------------------------");
				writefln("ERROR: %s (OP:0x%08X)", str, OP);
				disasm(PC);
				writefln("--------------------------------------------------------------");
				
				if (onError != null) {
					if (ignoreErrors) {
						retval = ErrorResult.IGNORE;
					} else{
						retval = onError(str);
					}
				}
			}
			sync_in();

			paused = false;
			
			switch (retval) {
				case ErrorResult.ABORT: return;
				case ErrorResult.RETRY: continue;
				case ErrorResult.IGNORE: paused = false; PC = nPC; nPC += 4; continue;
			}
			
			return;
		} }
	}
	
	static void disasmBlock(uint PC) {
		for (int n = 0; n < 32; n++, PC += 4) disasm(PC);
		writefln();
	}
	
	static bool _exit = false;
	
	static void run() {
		scope (exit) writefln("CPU.run() terminated");
		//disasmBlock(PC);
		while (!_exit) {
			_run();		
			//dumpRegs();
		}
		//mem.reset();
	}
	
	static void stateSave(Stream s, bool resume = false) {
		pauseExtern();
		{
			s.writeString("PSPEMUSTATE");
			mem.save(s);
			regs.save(s);
			s.close();
		}
		if (resume) resumeExtern();		
	}

	static void stateLoad(Stream s, bool resume = false) {
		pauseExtern();
		{
			if (s.readString(11) != "PSPEMUSTATE") s.position = 0;
			mem.load(s);
			regs.load(s);
			s.close();
		}
		resetExtern();
		if (resume) resumeExtern();		
	}

	enum ErrorResult { ABORT, RETRY, IGNORE }
	
	static ErrorResult function(char[] msg) onError;
}

alias CPU cpu;
