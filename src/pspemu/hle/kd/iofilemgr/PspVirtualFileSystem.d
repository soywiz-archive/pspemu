module pspemu.hle.kd.iofilemgr.PspVirtualFileSystem;

class PspVirtualFileSystem : VirtualFileSystem {
	HleEmulatorState hleEmulatorState;
	string name;
	PspIoDrv* pspIoDrv;
	PspIoDrvFuncs* funcs;

	PspIoDrvArg* pspIoDrvArg;
	PspIoDrvFileArg* pspIoDrvFileArg;
	char* tmpString;
	
	@property PspIoDrvArg* pspIoDrvArgGuest() {
		return hleEmulatorState.memoryManager.memory.ptrHostToGuest(pspIoDrvArg);
	}

	@property char* tmpStringGuest() {
		return hleEmulatorState.memoryManager.memory.ptrHostToGuest(tmpString);
	}

	@property PspIoDrvFileArg* pspIoDrvFileArgGuest() {
		return hleEmulatorState.memoryManager.memory.ptrHostToGuest(pspIoDrvFileArg);
	}
	
	@property PspIoDrv* pspIoDrvGuest() {
		return hleEmulatorState.memoryManager.memory.ptrHostToGuest(pspIoDrv);
	}

	this(HleEmulatorState hleEmulatorState, string name, PspIoDrv* pspIoDrv, PspIoDrvFuncs* funcs) {
		this.hleEmulatorState = hleEmulatorState;
		this.name  = name;
		this.pspIoDrv   = pspIoDrv;
		this.funcs = funcs;
		//writefln("Created PspVirtualFileSystem('%s')", name);
		
		init();
	}
	
	void init() {
		pspIoDrvArg = cast(PspIoDrvArg*)hleEmulatorState.memoryManager.memory.getPointerOrNull(hleEmulatorState.memoryManager.alloc(PspPartition.Kernel0, "pspIoDrvArg", PspSysMemBlockTypes.PSP_SMEM_Low, PspIoDrvArg.sizeof));
		pspIoDrvFileArg = cast(PspIoDrvFileArg*)hleEmulatorState.memoryManager.memory.getPointerOrNull(hleEmulatorState.memoryManager.alloc(PspPartition.Kernel0, "PspIoDrvFileArg", PspSysMemBlockTypes.PSP_SMEM_Low, PspIoDrvFileArg.sizeof));
		tmpString = cast(char *)hleEmulatorState.memoryManager.memory.getPointerOrNull(hleEmulatorState.memoryManager.alloc(PspPartition.Kernel0, "tmpString", PspSysMemBlockTypes.PSP_SMEM_Low, 0x1000));
		
		pspIoDrvArg.drv = pspIoDrvGuest;
		pspIoDrvArg.arg = null;
		
		//writefln("init()");
		Module.executeGuestCode(hleEmulatorState, cast(uint)funcs.IoInit, [cast(uint)pspIoDrvArgGuest]);
	}
	
	void exit() {
		// @TODO! MUST FREE MEMORY!
		//writefln("exit()");
		Module.executeGuestCode(hleEmulatorState, cast(uint)funcs.IoExit, [cast(uint)pspIoDrvArgGuest]);
	}
	
	FileHandle open(string file, FileOpenMode flags, FileAccessMode mode) {
		//writefln("open()");
		
		pspIoDrvFileArg.unk1 = 0;
		pspIoDrvFileArg.fs_num = 0;
		pspIoDrvFileArg.drv = pspIoDrvArgGuest;
		pspIoDrvFileArg.unk2 = 0;
		pspIoDrvFileArg.arg = null;
		
		tmpString[0..file.length] = file[0..file.length];
		tmpString[file.length] = 0;
		
		//hleEmulatorState.currentThreadState().registers.A0

		// int (*IoOpen)(PspIoDrvFileArg *arg, char *file, int flags, SceMode mode); 
		uint result = Module.executeGuestCode(hleEmulatorState, cast(uint)funcs.IoOpen, [cast(uint)pspIoDrvFileArgGuest, cast(uint)tmpStringGuest, cast(uint)flags, cast(uint)mode]);
		
		return new FileHandle(this);
	}
	
	string toString() {
		return std.string.format("PspVirtualFileSystem('%s')", name);
	}
}
