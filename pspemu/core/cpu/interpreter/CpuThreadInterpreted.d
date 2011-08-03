module pspemu.core.cpu.interpreter.CpuThreadInterpreted;

import std.stdio;
import std.math;

import pspemu.core.ThreadState;

import pspemu.core.cpu.CpuThreadBase;
import pspemu.core.cpu.Registers;

import pspemu.core.exceptions.HaltException;
import pspemu.core.exceptions.NotImplementedException;

import pspemu.core.cpu.interpreter.ops.Cpu_Alu;
import pspemu.core.cpu.interpreter.ops.Cpu_Memory;
import pspemu.core.cpu.interpreter.ops.Cpu_Branch;
import pspemu.core.cpu.interpreter.ops.Cpu_Special;
import pspemu.core.cpu.interpreter.ops.Cpu_Jump;
import pspemu.core.cpu.interpreter.ops.Cpu_Fpu;
import pspemu.core.cpu.interpreter.ops.Cpu_VFpu;

import pspemu.core.cpu.tables.Table;
import pspemu.core.cpu.tables.SwitchGen;
import pspemu.core.cpu.tables.DummyGen;
import pspemu.core.cpu.interpreter.Utils;
import pspemu.core.cpu.Instruction;
import pspemu.core.ThreadState;
import pspemu.core.Memory;

import pspemu.utils.Logger;
import core.thread;

import pspemu.core.cpu.InstructionHandler;
import pspemu.extra.Cheats;

//version = VERSION_SHIFT_ASM;

//import pspemu.utils.Utils;

class CpuThreadInterpreted : CpuThreadBase {
	public this(ThreadState threadState) {
		super(threadState);
	}
	
	public CpuThreadBase createCpuThread(ThreadState threadState) {
		auto cpuThreadBase = new CpuThreadInterpreted(threadState);
		cpuThreadBase.trace = this.trace;
		return cpuThreadBase;
	}
	
	void execute(bool trace = false) {
		TerminateCallbackException terminateCallbackExceptionCopy;
		HaltException haltExceptionCopy;
		HaltAllException haltAllExceptionCopy;
		Throwable throwableExceptionCopy;
		
		CpuThreadBase cpuThread = this.cpuThread;
		Instruction instruction;
		ThreadState threadState = this.threadState;
		Registers registers = this.registers;
		Memory memory = this.memory;
		
		void OP_UNK() {
			registers.pcAdvance(4);
			Logger.log(Logger.Level.CRITICAL, "CpuThreadInterpreted", "Thread(%d): PC(%08X): OP_UNK 0x%08X", threadState.thid, registers.PC, instruction.v);
		}

		mixin TemplateCpu_ALU;
		mixin TemplateCpu_MEMORY;
		mixin TemplateCpu_BRANCH;
		mixin TemplateCpu_JUMP;
		mixin TemplateCpu_SPECIAL;
		mixin TemplateCpu_FPU;
		mixin TemplateCpu_VFPU;
		
		threadState.setInCurrentThread();
		
		void dumpCallstack() {
			synchronized {
		    	.writefln("CALLSTACK:");
		    	scope uint[] callStack = registers.RealCallStack.dup;
		    	callStack ~= registers.PC;
		    	foreach (callPC; callStack) {
		    		//.writef("   ");
		    		.writef("   %08X", callPC);
		    		bool printed = false;
		    		try {
			    		if (threadState.threadModule !is null) {
			    			if (threadState.threadModule.dwarf !is null) {
			    				auto state = threadState.threadModule.dwarf.find(callPC);
			    				if (state !is null) {
			    					writef(":%s", (*state).toString);
			    					printed = true;
			    				}
			    			}
			    		}
			    	} catch {
			    		.writefln("Error writing threadState");
			    	}
		    		if (!printed) {
		    			//.writef("%08X", callPC);
		    		}
		    		.writefln("");
		    	}
			}
		}
		
		void dumpRegisters() {
			synchronized {
		    	//.,writefln();
		    	.writefln("REGISTERS:");
		    	foreach (k, value; registers.R) {
		    		//.writef("   r%2d: %08X", k, value);
		    		.writef("   %s: %08X", Registers.aliasesInv[k], value);
		    		if ((k % 4) == 3) .writefln("");
		    	}
		    	.writefln("   pc: %08X", registers.PC);
		    }
		}
		
		void dumpHeader() {
	    	.writefln("at 0x%08X : %s", registers.PC, threadState);
	    	.writefln("THREADSTATE: %s", threadState);
	    	.writefln("MODULE: %s", threadState.threadModule);
		}

		void dumpThreads(Throwable exception) {
	    	dumpHeader();
	    	dumpCallstack();
	    	dumpRegisters();
	    	
	    	.writefln("%s", exception);
	    	.writefln("%s", this);
	    	
	    	//cpuThread.threadState.emulatorState.runningState.stop();
		}
		
		bool isUnittesting() {
			try {
				return (threadState !is null) && threadState.emulatorState.unittesting;
			} catch {
				return false;
			}
		}
		
    	try {
			//Logger.log(Logger.Level.TRACE, "CpuThreadBase", "NATIVE_THREAD: START (%s)", Thread.getThis().name);
			//Logger.log(Logger.Level.INFO, "CpuThreadBase", "NATIVE_THREAD: START (%s)", Thread.getThis().name);
			
			/*
			if (threadState.name == "mainCpuThread") {
				//trace = true;
				//threadState.registers.dump();
			}
			*/
			
			if (globalCheats.mustTraceThreadName(threadState.name)) trace = true;
			//if (threadState.name == "BGM thread") trace = true;
			
			//trace = true;
    		
	    	while (running) {
		    	instruction.v = memory.tread!(uint)(registers.PC);
		    	
		    	if (trace) {
		    		writefln("%s :: nPC:%08X: INSTRUCTION:%08X : RA:%08X", threadState, registers.nPC, instruction.v, registers.RA);
		    	}
		    	
		    	mixin(genSwitchAll());
		    	//executedInstructionsCount++;
		    	registers.EXECUTED_INSTRUCTION_COUNT_THIS_THREAD++;
		    }
			Logger.log(Logger.Level.TRACE, "CpuThreadBase", "!running: %s", this);
		} catch (TerminateCallbackException _terminateCallbackException) {
			terminateCallbackExceptionCopy = _terminateCallbackException;
			// Do nothing.
	    } catch (HaltException _haltException) {
	    	haltExceptionCopy = _haltException;

	    	try {
	    		/*
		    	Logger.exclusiveLock({
					Logger.log(Logger.Level.INFO, "CpuThreadBase", "halted thread: %s", this);
					//dumpThreads(haltException);
					
					if (!isUnittesting) {
				    	dumpHeader();
				    	dumpCallstack();
				    	Logger.log(Logger.Level.INFO, "CpuThreadBase", haltException);
				    }
				});
	    		*/
			} catch (Throwable o) {
				.writefln("REALLY FATAL ERROR: Error on HaltException Error!! '%s'", o);
			}
	    	
	    	//.writefln("%s", this);
	    	//throw(haltException);
	    	//running = false;
	    } catch (HaltAllException _haltAllException) {
	    	haltAllExceptionCopy = _haltAllException;
	    	
	    	try {
		    	Logger.exclusiveLock({
					Logger.log(Logger.Level.INFO, "CpuThreadBase", "halted all threads: %s", this);
					//dumpThreads(haltException);
					
					if (!isUnittesting) {
				    	dumpHeader();
				    	dumpCallstack();
				    	Logger.log(Logger.Level.INFO, "CpuThreadBase", haltAllExceptionCopy);
				    }
				});
			} catch (Throwable o) {
				.writefln("REALLY FATAL ERROR: Error on HaltAllException Error!! '%s'", o);
			}
			threadState.emulatorState.runningState.stopCpu();
	    } catch (Throwable _throwableException) {
	    	throwableExceptionCopy = _throwableException;

	    	try {
		    	Logger.exclusiveLock({
		    		writefln("Fatal Error. Halting all threads :: Exception:'%s'", throwableExceptionCopy);
			    	dumpThreads(throwableExceptionCopy);
		    	});
			} catch (Throwable o) {
				.writefln("REALLY FATAL ERROR: Error on Error '%s'!! :: %s", throwableExceptionCopy, o);
			}
			threadState.emulatorState.runningState.stopCpu();
	    } finally {
			Logger.log(Logger.Level.TRACE, "CpuThreadBase", "NATIVE_THREAD: END (%s)", Thread.getThis().name);
	    }
    }
}
