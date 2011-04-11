module pspemu.exe.Pspemu;

//version = TRACE_FROM_BEGINING;
//version = USE_CPU_DYNAREC;

import pspemu.All;

class PspDisplay : Display {
	Memory memory;

	this(Memory memory) {
		this.memory = memory;
	}

	void* frameBufferPointer() { return memory.getPointer(info.topaddr); }
}

int main(string[] args) {
	if (args.length >= 2 && args[1] == "/register") {
		std.windows.registry.Registry.classesRoot.createKey(".elf").setValue(null, "dpspemu.executable");
		std.windows.registry.Registry.classesRoot.createKey(".pbp").setValue(null, "dpspemu.executable");
		std.windows.registry.Registry.classesRoot.createKey(".cso").setValue(null, "dpspemu.executable");
		std.windows.registry.Registry.classesRoot.createKey(".prx").setValue(null, "dpspemu.executable");

		auto reg = std.windows.registry.Registry.classesRoot.createKey("dpspemu.executable");
		reg.setValue(null, "PSP executable file (.elf, .pbp, .cso, .prx)");
		reg.createKey("DefaultIcon").setValue(null, "\"" ~ Application.executablePath ~ "\",0");
		reg.createKey("shell").createKey("open").createKey("command").setValue(null, "\"" ~ Application.executablePath ~ "\" \"%1\"");
		return 0;
	}
	//Thread.getThis.priority = +1;
	
	try { std.file.mkdirRecurse(ApplicationPaths.exe ~ "/pspfs/flash0/font"); } catch { }
	try { std.file.mkdirRecurse(ApplicationPaths.exe ~ "/pspfs/flash0/kd"); } catch { }
	try { std.file.mkdirRecurse(ApplicationPaths.exe ~ "/pspfs/flash0/vsh"); } catch { }
	try { std.file.mkdirRecurse(ApplicationPaths.exe ~ "/pspfs/flash1"); } catch { }
	try { std.file.mkdirRecurse(ApplicationPaths.exe ~ "/pspfs/ms0/PSP/GAME/virtual"); } catch { }
	try { std.file.mkdirRecurse(ApplicationPaths.exe ~ "/pspfs/ms0/PSP/PHOTO"); } catch { }
	try { std.file.mkdirRecurse(ApplicationPaths.exe ~ "/pspfs/ms0/PSP/SAVEDATA"); } catch { }

	// No file specified.
	// Check if there is a file in the directory
	// with the same name as the executable (with elf, iso, cso, asm or pbp extension) so we can open it.
	if (args.length < 2) {
		auto baseName = std.path.getName(args[0]);
		foreach (extension; ["iso", "cso", "asm", "elf", "pbp"]) {
			auto currentFullName = baseName ~ '.' ~ extension;
			if (std.file.exists(currentFullName)) {
				args ~= currentFullName;
				goto file_to_execute_found;
			}
		}

		// Still didn't found. Try several more files:
		foreach (currentFullName; ["BOOT.PBP", "EBOOT.PBP"]) {
			if (std.file.exists(currentFullName)) { args ~= currentFullName; goto file_to_execute_found; }
		}

		file_to_execute_found:;
		//writefln("%s", args);
	}
	
	if ((args.length >= 2) && std.file.exists(args[1]) && std.file.isdir(args[1])) {
		foreach (currentName; ["BOOT.PBP", "EBOOT.PBP"]) {
			auto currentFullName = args[1] ~ "/" ~ currentName;
			if (std.file.exists(currentFullName)) {
				args[1] = currentFullName;
				break;
			}
		}
	}


	// Components.
	auto memory        = new Memory;
	auto controller    = new Controller();
	auto display       = new PspDisplay(memory);
	auto gpu           = new Gpu(new GpuOpengl, memory);
	version (USE_CPU_DYNAREC) {
		//auto cpu       = new CpuDynaRec(memory, gpu, display, controller);
	} else {
		auto cpu       = new CpuInterpreted(memory, gpu, display, controller);
	}
	auto dissasembler  = new AllegrexDisassembler(memory);

	// HLE.
	auto moduleManager = new ModuleManager(cpu);
	auto loader        = new Loader(cpu, moduleManager);
	auto syscall       = new Syscall(cpu, moduleManager);

	bool showMainMenu  = true;

	cpu.errorHandler = (Cpu cpu, Object error) {
		writefln("------------------------------------------------");
		writefln("CPU Error: %s", error.toString());
		executionState.registers.dump();
		auto dissasembler = new AllegrexDisassembler(executionState.memory.;
		dissasembler.registersType = AllegrexDisassembler.RegistersType.Symbolic;
		dissasembler.dump(executionState.registers.PC, -3, +3);
		dissasembler.dump(cpu.lastValidPC, -3, +3);
		moduleManager.get!(ThreadManForUser).threadManager.dumpThreads();
		moduleManager.get!(ThreadManForUser).semaphoreManager.dumpSemaphores();
		writefln("CPU Error: %s", error.toString());
		writefln("------------------------------------------------");
	};
	
	cpu.init();
	gpu.init();
	
	version (TRACE_FROM_BEGINING) {
		cpu.traceStep = true;
		cpu.checkBreakpoints = true;
	}

	/*
	cpu.checkBreakpoints = true;
	cpu.addBreakpoint(cpu.BreakPoint(
		//0x0895A9E4
		//0x0895ACAC
		//0x0895ACD4
		0x0895A914
	, [], true, {
		cpu.traceStep = true;
		cpu.checkBreakpoints = true;
	}));
	*/
	
	//cpu.addBreakpoint(cpu.BreakPoint(0x08900130 + 4, ["t1", "t2", "v0"]));

	// Start running.
	if (args.length >= 2) {
		loader.loadAndExecute(args[1]);
	}

	int retval = 0;
	try {
		Application.enableVisualStyles();
		Application.run(new DisplayForm(showMainMenu, loader, moduleManager, cpu, display, controller));
	} catch (Object o) {
		msgBox(o.toString(), "Fatal Error", MsgBoxButtons.OK, MsgBoxIcon.ERROR);
		retval = -1;
	}
	
	cpu.stop();
	gpu.stop();

	Application.exit();
	return retval;
}
