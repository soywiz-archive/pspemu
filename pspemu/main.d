module pspemu.main;

import std.traits;

import pspemu.core.EmulatorState;
import pspemu.utils.Path;
import pspemu.utils.sync.WaitEvent;

import std.c.windows.windows;

import core.thread;
import core.time;
import core.memory;

import std.stdio;
import std.conv;
import std.c.stdlib;
import std.stream;
import std.file;
import std.path;
import std.datetime;
import std.process;
import std.string;
import std.array;
import std.regex;

import pspemu.tests.MemoryPartitionTests;

import pspemu.Emulator;
import pspemu.EmulatorHelper;

import std.getopt;

import pspemu.gui.GuiBase;
import pspemu.gui.GuiNull;
import pspemu.gui.GuiSdl;
import pspemu.gui.GuiDfl;

import pspemu.utils.Logger;

import pspemu.hle.kd.sysmem.KDebug;

import pspemu.hle.vfs.VirtualFileSystem;
import pspemu.hle.vfs.MountableVirtualFileSystem;
import pspemu.hle.vfs.LocalFileSystem;
import pspemu.hle.vfs.IsoFileSystem;

import pspemu.formats.Pgf;
import pspemu.formats.iso.Iso;
import pspemu.formats.iso.IsoFactory;
import pspemu.formats.DetectFormat;
import pspemu.core.gpu.GpuState;
import pspemu.core.gpu.Types;

import pspemu.hle.kd.all;

import pspemu.utils.Diff;

import pspemu.utils.SvnVersion;
import pspemu.extra.Cheats;
import pspemu.utils.UpdateChecker;

import pspemu.core.gpu.impl.gl.GpuOpengl;
import pspemu.core.gpu.Commands;


void executeSandboxTests(string[] args) {
	auto localFileSystem = new LocalFileSystem("__unexistant_path__");
	auto opened = localFileSystem.dopen("aaaa");
}

void executeIsoListing(string[] args) {
	Iso iso = IsoFactory.getIsoFromStream(args[1]);
	writefln("%s", iso);
	foreach (node; iso.descendency) {
		writefln("%s", node);
	}
	
	if (args.length >= 3) {
		writefln("Extracting '%s'...", args[2]);
		auto nodeToExtract = iso.locate(args[2]); 
		writefln("     '%s'...", nodeToExtract);
		nodeToExtract.saveTo();
	}
}

void doUnittest() {
	(new MemoryPartitionTests()).test();
}

unittest {
	doUnittest();
}

void init(string[] args) {
	Thread.getThis.name = "MainThread";
	
	ApplicationPaths.initialize(args);
	
	void requireDirectory(string directory) {
		try { std.file.mkdirRecurse(ApplicationPaths.exe ~ "/" ~ directory); } catch { }
	}
	
	requireDirectory("pspfs/flash0/font");
	requireDirectory("pspfs/flash0/kd");
	requireDirectory("pspfs/flash0/vsh");
	requireDirectory("pspfs/flash1");
	requireDirectory("pspfs/temp");
	requireDirectory("pspfs/ms0/PSP/GAME/virtual");
	requireDirectory("pspfs/ms0/PSP/PHOTO");
	requireDirectory("pspfs/ms0/PSP/SAVEDATA");
}


int main2(string[] args) {
	//core.memory.GC.disable();
	
	init(args);
	
	//writefln("%d, %d", getLastOnlineVersion, SvnVersion.revision);
	
	/*
	writefln("[1]");
	auto handle = curl_easy_init();
	curl_easy_setopt(handle, CurlOption.url, "http://pspemu.googlecode.com/svn/");
	curl_easy_perform(handle);
	writefln("[2]");
	curl_easy_cleanup(handle);
	*/
	
	/*
	auto root = new MountableVirtualFileSystem(new VirtualFileSystem());
	root.mount("ms0:", new LocalFileSystem(r"C:\temp\SDL-1.2.14"));

	auto f = root.open("ms0:/../SDL.spec", octal!777, FileOpenMode.In);
	ubyte[] data;
	data.length = 100;
	root.read(f, data);
	writefln("%s", data);
	root.close(f);
	return 0;
	*/
	
	bool isolist;
	bool doSandboxTests;
	bool doUnitTests;
	bool doTestsEx;
	bool showHelp;
	bool nolog, log, trace;
	bool forceCheckForUpdates = false;
	
	void disableLogComponent(string opt, string component) { Logger.disableLogComponent(component); }
	void enableLogComponent(string opt, string component) { Logger.enableLogComponent(component); }
	void addCheat8(string opt, string component) { globalCheats.addCheatString(component, 8); }
	void addCheat16(string opt, string component) { globalCheats.addCheatString(component, 16); }
	void addCheat32(string opt, string component) { globalCheats.addCheatString(component, 32); }
	void addTraceThread(string opt, string name) { globalCheats.addTraceThread(name); }
	
	void associateExtensions(string opt) {	
		std.windows.registry.Registry.classesRoot.createKey(".elf").setValue(null, "dpspemu.executable");
		std.windows.registry.Registry.classesRoot.createKey(".pbp").setValue(null, "dpspemu.executable");
		std.windows.registry.Registry.classesRoot.createKey(".cso").setValue(null, "dpspemu.executable");
		std.windows.registry.Registry.classesRoot.createKey(".prx").setValue(null, "dpspemu.executable");
		
		auto reg = std.windows.registry.Registry.classesRoot.createKey("dpspemu.executable");
		reg.setValue(null, "PSP executable file (.elf, .pbp, .cso, .prx)");
		reg.createKey("DefaultIcon").setValue(null, "\"" ~ ApplicationPaths.executablePath ~ "\",0");
		reg.createKey("shell").createKey("open").createKey("command").setValue(null, "\"" ~ ApplicationPaths.executablePath ~ "\" \"%1\"");
		std.c.stdlib.exit(0);
	}
	
	void loadgpuDump(string opt, string component) {
		//GpuState gpuState; writefln("emptyGpuState: %s", gpuState);
		for (int n = 0; ; n++) {
			string dumpFilename = std.string.format("%s/%d.bin", component, n);
			if (!std.file.exists(dumpFilename)) break;
			GpuOpengl.DumpStruct dumpStruct = GpuOpengl.loadDump(cast(ubyte[])std.file.read(dumpFilename));
			dumpStruct.dump();
		}
		std.c.stdlib.exit(0);
	}
	
	getopt(
		args,
		"help|h|?", &showHelp,
		"sandbox_tests", &doSandboxTests,
		"unit_tests", &doTestsEx,
		"extended_tests", &doTestsEx,
		"nolog", &nolog,
		"isolist", &isolist,
		"trace", &trace,
		"log", &log,
		"nologmod", &disableLogComponent,
		"enlogmod", &enableLogComponent,
		"loadgpu", &loadgpuDump,
		"cheat32", &addCheat32,
		"cheat16", &addCheat16,
		"cheat8", &addCheat8,
		"trace_thread", &addTraceThread,
		"associate_extensions", &associateExtensions,
		"check_for_updates", &forceCheckForUpdates
	);
	
	void displayHelp() {
		writefln("DPspEmulator 0.3.1.0 r%d", SvnVersion.revision);
		writefln("");
		writefln("pspemu.exe [<args>] [<file>]");
		writefln("");
		writefln("Arguments:");
		writefln("  --help              - Show this help");
		writefln("  --sandbox_tests     - Run test sandbox code (only for developers)");
		writefln("  --unit_tests        - Run unittestson 'pspautotests' folder (only for developers)");
		writefln("  --extended_tests    - Run unittestson 'pspautotests' folder (only for developers)");
		writefln("  --trace             - Enables cpu tracing at start");
		writefln("  --log               - Enables logging");
		writefln("  --nolog             - Disables logging");
		writefln("  --nologmod=MOD      - Disables logging of a module");
		writefln("  --enlogmod=MOD      - Enables logging of a module");
		writefln("  --trace_thread=NAME - Starts tracing a thread by name");
		writefln("  --cheat32=ADDR:VAL  - Adds a memory write every frame (addresses are relative to 0x08000000, the memory.dump start).");
		writefln("  --isolist           - Allow to list an iso file and (optionally) to extract a single file");
		writefln("  --loadgpu=folder    - Loads a gpu dump and displays it");
		writefln("  --check_for_updates - Forces checking for updates");
		writefln("");
		writefln("Examples:");
		writefln("  pspemu.exe --help");
		writefln("  pspemu.exe --test");
		writefln("  pspemu.exe --isolist mygame.iso");
		writefln("  pspemu.exe --isolist mygame.iso /UMD_DATA.BIN");
		writefln("  pspemu.exe --cheat32=0xB98320:3");
		writefln("  pspemu.exe --trace_thread=\"BGM thread\"");
		writefln("  pspemu.exe \"isos/My Game.cso\"");
		writefln("  pspemu.exe game/EBOOT.PBP");
		writefln("");
		std.c.stdlib.exit(-1);
	}
	
	if (showHelp) {
		displayHelp();
		return -1;
	}
	
	if (isolist) {
		executeIsoListing(args);
		return 0;
	}

	if (doSandboxTests) {
		executeSandboxTests(args);
		return 0;
	}

	if (doUnitTests) {
		doUnittest();
		return 0;
	}

	if (doTestsEx) {
		EmulatorHelper emulatorHelper = new EmulatorHelper(new Emulator());
		emulatorHelper.initComponents();
		if (log) {
			Logger.setLevel(Logger.Level.TRACE);
		} else {
			Logger.setLevel(Logger.Level.CRITICAL);
		}

		WaitEvent testCompletedEvent = new WaitEvent("testCompletedEvent");
		
		bool runningTests = true;
		int testStep = 0;
		
		//new Thread("HangDetector");
		Thread hangThread = new Thread(delegate() {
			while (runningTests) {
				if (testCompletedEvent.wait(2000) is null) {
					writefln("tests hanged on %d!", testStep);
				}
			}
		});
		hangThread.name = "HangDetector";
		hangThread.start();
		
		// Remove the first argument.
		auto filterExpressionStrings = args[1..$];
		typeof(regex(""))[] filterExpressionRegexs;
		foreach (filterExpressionString; filterExpressionStrings) {
			filterExpressionRegexs ~= regex("^.*" ~ filterExpressionString ~ ".*$");
		}
		
		writefln("%s", args);
		
		foreach (std.file.DirEntry dirEntry; dirEntries(r"pspautotests", SpanMode.depth, true)) {
			if (std.string.indexOf(dirEntry.name, ".svn") != -1) continue;
			if (std.path.getExt(dirEntry.name) != "expected") continue;
			bool filter = false;
			foreach (filterExpressionRegex; filterExpressionRegexs) {
				if (!match(dirEntry.name, filterExpressionRegex).empty) {
					filter = false;
					break;
				} else {
					filter = true;
				}
			}
			if (filter) continue;
			
			//writefln("[0]");
			
			testStep = 0;
			
			emulatorHelper.loadAndRunTest(dirEntry.name);
			
			testStep = 1;
			
			testCompletedEvent.signal();
			//writefln("[1]");
			
			try {
				emulatorHelper.reset();
			} catch (Throwable o) {
				writefln("ERROR Reseting (%s)", o);
			}
			
			testStep = 2;
			
			//writefln("[2]");
		}
		emulatorHelper.stop();
		
		runningTests = false;
		
		return 0;
	}
	
	/*if (args.length == 1) {
		OPENFILENAMEW openfl;
		GetOpenFileNameW(&openfl);
	}*/
	
	
	if (nolog) {
		//Logger.setLevel(Logger.Level.WARNING);
		Logger.setLevel(Logger.Level.NONE);
	} else {
		if (log) {
			Logger.setLevel(Logger.Level.TRACE);
		} else {
			Logger.setLevel(Logger.Level.INFO);
		}
	}
	EmulatorHelper emulatorHelper = new EmulatorHelper(new Emulator());
	if (nolog) {
		emulatorHelper.emulator.hleEmulatorState.kPrint.outputKprint = true;
	}
	emulatorHelper.initComponents();
	emulatorHelper.waitComponentsInitialized();

	//GuiBase gui = new GuiSdl(emulatorHelper.emulator.hleEmulatorState);
	GuiBase gui = new GuiDfl(emulatorHelper);
	gui.start();
	emulatorHelper.emulator.mainCpuThread.trace = trace;
	
	if (args.length > 1) {
		emulatorHelper.loadMainModule(args[1]);
		emulatorHelper.start();
		return 0;
	} else {
		Logger.setLevel(Logger.Level.WARNING);
	}

	UpdateChecker.tryCheckBackground(null, forceCheckForUpdates);
	
	//displayHelp();
	writefln("No specified file to execute");
	return -1;
}


int main(string[] args) {
	try {
		return main2(args);
	} catch (Throwable o) {
		writefln("FATAL ERROR");
		writefln("FATAL ERROR: %s", o);
		return -1;
	}
}