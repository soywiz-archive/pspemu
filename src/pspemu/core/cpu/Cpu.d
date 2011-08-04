module pspemu.core.cpu.Cpu;

import std.stdio;
import core.thread;
import core.time;
import std.datetime;

import pspemu.core.Interrupts;
import pspemu.Exceptions;

import pspemu.core.cpu.tables.Table;
import pspemu.core.cpu.tables.SwitchGen;
import pspemu.core.cpu.tables.DummyGen;
import pspemu.core.cpu.Instruction;
import pspemu.core.cpu.Registers;

public import pspemu.core.Memory;
public import pspemu.interfaces.ISyscall;
public import pspemu.interfaces.IInterruptable;

import pspemu.utils.Logger;

import pspemu.hle.kd.threadman.Types;

abstract class Cpu : IInterruptable{
	ISyscall   syscall;
	Interrupts interrupts;
	Memory     memory;
	bool       running;
	bool       trace;
	
	public this(Memory memory, ISyscall syscall, Interrupts interrupts) {
		this.memory     = memory;
		this.syscall    = syscall;
		this.interrupts = interrupts;
		this.running    = true;
	}

	void interrupt() {
		this.running = false;
	}

    public void execute_loop(Registers registers, uint maxInstructions);
    
	public void execute_loop(Registers registers) {
		while (running) {
			execute_loop(registers, 0xFFFFFFFF);
		}
	}
	
	void execute(Registers registers/*, bool trace = false*/) {
		TerminateCallbackException terminateCallbackExceptionCopy;
		HaltException haltExceptionCopy;
		HaltAllException haltAllExceptionCopy;
		Throwable throwableExceptionCopy;
		
		try {
			execute_loop(registers);
		} catch (TerminateCallbackException _terminateCallbackException) {
		} catch (HaltException _haltException) {
		} catch (HaltAllException _haltAllException) {
		}
		
		/+
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
		
		void dumpHeader() {
	    	.writefln("at 0x%08X : %s", registers.PC, threadState);
	    	.writefln("THREADSTATE: %s", threadState);
	    	.writefln("MODULE: %s", threadState.threadModule);
		}

		void dumpThreads(Throwable exception) {
	    	dumpHeader();
	    	dumpCallstack();
	    	registers.dump();
	    	
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
		+/
    }

    
    string toString() { return "Cpu()"; }
    
	static string genSwitchBranch() {
		return mixin("pspemu.core.cpu.tables.SwitchGen.genSwitch(" ~ PspInstructionsBranchString ~ ")");
	}
	
	static string genSwitchAll() {
		return mixin("pspemu.core.cpu.tables.SwitchGen.genSwitch(" ~ PspInstructionsAllString ~ ")");
	}
}