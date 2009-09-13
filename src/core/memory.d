module psp.memory;

import std.stream;
import std.stdio;
import std.c.string;
import std.utf;
import std.windows.charset;

import psp.disassembler.cpu;

template TA(T) { ubyte[] TA(inout T t) { return (cast(ubyte *)&t)[0..T.sizeof]; } }

//version = mem_slim; // 64MB
version = mem_check;
//version = mem_check_alignment;
//version = mem_breakpoints;

class Registers {
	uint PC, nPC;
	uint HI, LO;
	uint[0x20] r;
	float[0x20] f;
	uint IC = 0xFFFFFFFF; // Interrupt Controller
	uint CC;
	
	void copy(Registers freg) {
		ubyte* s1 = cast(ubyte*)&freg.PC;
		ubyte* s2 = cast(ubyte*)&PC;
		int size = (cast(ubyte*)&CC - s2) + CC.sizeof;
		s2[0..size] = s1[0..size];
	}
	
	enum R {
		zr, at, v0, v1, a0, a1, a2, a3,
		t0, t1, t2, t3, t4, t5, t6, t7,
		s0, s1, s2, s3, s4, s5, s6, s7,
		t8, t9, k0, k1, gp, sp, fp, ra,
	}
	
	this() {
		writefln("Registers.this()");
	}
	
    uint opIndex(size_t n) { return r[n]; }
    uint opIndexAssign(uint v, size_t n) { if (n == 0) return 0; return r[n] = v; }
	
	void dump(bool simplify) {
		writefln("REGS {");
		foreach (k, v; r) {
			if (simplify && v == 0) continue;
			writefln("  %-3s: 0x%08X", CPU_Disasm.reg(k), v);
		}
		writefln("}");		
	}
	
	uint a(uint n) { return r[n + 4]; }	
	uint t(uint n) { return (n > 8) ? r[n + 24] : r[n + 8]; }
	uint s(uint n) { return r[n + 16]; }
	uint k(uint n) { return r[n + 26]; }
	
	uint sp() { return r[29]; }
	uint ra() { return r[31]; }
	
	uint v0(uint v) {
		return r[2] = v;
	}
	
	void _PC(uint PC) {
		this.PC = PC;
		this.nPC = PC + 4;
	}
	
	void save(Stream s) {
		s.write(PC);
		s.write(nPC);
		s.write(HI);
		s.write(LO);
		for (int n = 0; n < 32; n++) s.write(r[n]);
		for (int n = 0; n < 32; n++) s.write(f[n]);
		s.write(CC);
	}

	void load(Stream s) {
		s.read(PC);
		s.read(nPC);
		s.read(HI);
		s.read(LO);
		for (int n = 0; n < 32; n++) s.read(r[n]);
		for (int n = 0; n < 32; n++) s.read(f[n]);
		s.read(CC);
	}
}

enum INTS : int {
	GPIO      =  4, ATA       =  5, UMD       =  6,
	MSCM0     =  7, WLAN      =  8, AUDIO     = 10,
	I2C       = 12, SIRCS     = 14, SYSTIMER0 = 15,
	SYSTIMER1 = 16, SYSTIMER2 = 17, SYSTIMER3 = 18,
	THREAD0   = 19, NAND      = 20, DMACPLUS  = 21,
	DMA0      = 22, DMA1      = 23, MEMLMD    = 24,
	GE        = 25, VBLANK    = 30, MECODEC   = 31,
	HPREMOTE  = 36, MSCM1     = 60, MSCM2     = 61,
	THREAD1   = 65, INTERRUPT = 66,
}

class INT {
	Memory mem;
	
	this(Memory mem) {
		this.mem = mem;
	}

	void delegate()[66] callbacks;
	void delegate()[int] callbacksQueue;
	int minId = 0, maxId = 1;
	int queued;

	void queueHead(INTS i) {
		if ((mem.regs.IC & i) && callbacks[i]) { callbacksQueue[--minId] = callbacks[i]; minId--; queued++; }
	}
	
	void queue(INTS i) {
		if ((mem.regs.IC & i) && callbacks[i]) { callbacksQueue[++maxId] = callbacks[i]; maxId++; queued++; }
	}
	
	void process() {
		foreach (k, c; callbacksQueue) {
			callbacksQueue.remove(k); queued--;
			c();
		}
	}
}

class Memory : Stream {
	// +----------------------------------+
	// | Adress                           |
	// | 31.............................0 |
	// | ku0hp--------------------------- |
	// | k - Kernel (only in kern mode)   |
	// | u - Uncached Bit                 |
	// | h - Hardware DMA                 |
	// | p - Physical main mem            |
	// +----------------------------------+

	//_memory->DefineSegment( MemoryType::PhysicalMemory, "Main Memory", 0x08000000, 0x01FFFFFF );
	//_memory->DefineSegment( MemoryType::PhysicalMemory, "Hardware Vectors", 0x1FC00000, 0x000FFFFF );
	//_memory->DefineSegment( MemoryType::PhysicalMemory, "Scratchpad", 0x00010000, 0x00003FFF );
	//_memory->DefineSegment( MemoryType::PhysicalMemory, "Frame Buffer", 0x04000000, 0x001FFFFF );
	//_memory->DefineSegment( MemoryType::HardwareMapped, "Hardware IO 1", 0x1C000000, 0x03BFFFFF );
	//_memory->DefineSegment( MemoryType::HardwareMapped, "Hardware IO 2", 0x1FD00000, 0x002FFFFF );
	
	//_memory->DefineSegment( MemoryType::PhysicalMemory, "Kernel Memory", 0x88000000, 0x01FFFFFF );
	
	Registers regs;
	INT interrupts;
	
	version (mem_slim) {
		ubyte[] main; final const int main_addr = 0x08_000000, main_mask = 0x03FFFFFF; // Main Memory  | 64MB SLIM
	} else {
		ubyte[] main; final const int main_addr = 0x08_000000, main_mask = 0x01FFFFFF; // Main Memory  | 32MB FAT
	}
	ubyte[] frmb; final const int frmb_addr = 0x04_000000, frmb_mask = 0x001FFFFF; // Frame Buffer | 2MB
	ubyte[] spad; final const int spad_addr = 0x00_010000, spad_mask = 0x00003FFF; // Scratch Pad  | 16KB
	uint[] breakpoints;
	
	this() {
		version (mem_slim) {
			.writefln("Memory.this() // SLIM 64MB");
		} else {
			.writefln("Memory.this() // FAT 32MB");
		}
		
		regs = new Registers;
		interrupts = new INT(this);
		
		main.length = main_mask + 1; // 32MB FAT // 64MB SLIM
		spad.length = spad_mask + 1; // 16KB
		frmb.length = frmb_mask + 1; // 2MB
		
		seekable = writeable = readable = true;
	}	
	
	void reset() {
		static void zero(ubyte[] data) { memset(data.ptr, 0, data.length); }
		zero(main); zero(spad); zero(frmb);
		foreach (id; comments.keys) comments.remove(id);
	}
	
	void zero(uint addr, uint len) {
		ubyte* ptr = cast(ubyte *)gptr(addr);	
		if (ptr && len) {
			ubyte* ptr2 = cast(ubyte *)gptr(addr + len);
			if (ptr2 - len == ptr) memset(ptr, 0, len);
		}
	}
	
	// TRANSFER
	void* gptr(uint addr) {
		version (mem_breakpoints) {
			foreach (bp; breakpoints) {
				if (bp == addr) {
					throw(new Exception("test"));
				}
			}
		}
		
		//addr &= ~(0x40000000 | 0x80000000); // Ignore cached / kernel
		addr &= 0x1FFFFFFF; // Ignore last 3 bits (cache / kernel)
	
		switch (addr >> 24) {
			/////// hp
			case 0b_00000:
				version (mem_check) {
					if ((addr >= spad_addr) && (addr <= spad_addr | spad_mask)) return &spad[addr & spad_mask];				
				} else {
					return &spad[addr & spad_mask];				
				}
			break;
			/////// hp
			case 0b_00100:
				version (mem_check) {
					if ((addr >= frmb_addr) && (addr <= frmb_addr | frmb_mask)) return &frmb[addr & frmb_mask];
				} else {
					return &frmb[addr & frmb_mask];
				}
			break;
			/////// hp
			case 0b_01000:
			case 0b_01001:
			case 0b_01010: // SLIM ONLY
			case 0b_01011: // SLIM ONLY
				version (mem_check) {
					if ((addr >= main_addr) && (addr <= main_addr | main_mask)) return &main[addr & main_mask];
				} else {
					return &main[addr & main_mask];
				}
			break;
			/////// hp
			case 0b_11100: // HW IO1
			case 0b_11111: // HO IO2
				return null;
			break;
			default: break;
		}

		throw(new Exception(std.string.format("Invalid address 0x%08X", addr)));		
	}
	
	// TRANSFER : WRITTING
	
	ubyte write1(uint addr, ubyte v) {
		ubyte* ptr = cast(ubyte *)gptr(addr);		
		//.printf("write: 0x%08X\n", addr);
		version (mem_check) if (ptr == null) throw(new Exception(std.string.format("Hardware 0x%08X", addr)));
		return *ptr = v;						
	}

	ushort write2(uint addr, ushort v) {
		version (mem_check_alignment) if (addr & 0b01) throw(new Exception(std.string.format("Unaligned half writting 0x%08X", addr)));
		ushort* ptr = cast(ushort *)gptr(addr);				
		version (mem_check) if (ptr == null) throw(new Exception(std.string.format("Hardware 0x%08X", addr)));
		return *ptr = v;
	}

	uint write4(uint addr, uint v) {
		version (mem_check_alignment) if (addr & 0b11) throw(new Exception(std.string.format("Unaligned word writting 0x%08X", addr)));
		uint* ptr = cast(uint *)gptr(addr);				
		version (mem_check) if (ptr == null) throw(new Exception(std.string.format("Hardware 0x%08X", addr)));
		return *ptr = v;
	}
	
	void writed(uint addr, ubyte[] block) {
		ubyte* ptr = cast(ubyte *)gptr(addr);
		uint len = block.length;
		if (ptr && len) {
			ubyte* ptr2 = cast(ubyte *)gptr(addr + len);
			if (ptr2 - len == ptr) ptr[0..len] = block;
		}
	}
	
	void writed(uint addr, Stream s) {
		ubyte* ptr = cast(ubyte *)gptr(addr);
		uint len = s.size;
		if (ptr && len) {
			ubyte* ptr2 = cast(ubyte *)gptr(addr + len);
			if (ptr2 - len) s.read(ptr[0..len]);
		}
	}	
	
	// TRANSFER : READING
	
	ubyte read1(uint addr) {
		ubyte* ptr = cast(ubyte *)gptr(addr);				
		version (mem_check) if (ptr == null) throw(new Exception(std.string.format("Hardware 0x%08X", addr)));
		return *ptr;
	}

	ushort read2(uint addr) {
		version (mem_check_alignment) if (addr & 0b01) throw(new Exception(std.string.format("Unaligned half reading 0x%08X", addr)));
		ushort* ptr = cast(ushort*)gptr(addr);				
		version (mem_check) if (ptr == null) throw(new Exception(std.string.format("Hardware 0x%08X", addr)));		
		return *ptr;		
	}
	
	uint read4(uint addr) {
		version (mem_check_alignment) if (addr & 0b11) throw(new Exception(std.string.format("Unaligned half reading 0x%08X", addr)));
		uint* ptr = cast(uint*)gptr(addr);				
		version (mem_check) if (ptr == null) throw(new Exception(std.string.format("Hardware 0x%08X", addr)));		
		return *ptr;		
	}
	
	void readd(uint addr, ubyte[] block) {
		ubyte* ptr = cast(ubyte *)gptr(addr);
		uint len = block.length;
		if (ptr && len) {
			ubyte* ptr2 = cast(ubyte *)gptr(addr + len);
			if (ptr2 - len == ptr) block[0..len] = ptr[0..len];
		}		
	}
	
	uint _read4(uint addr) {
		return *cast(uint *)((addr & (main_mask & ~ 0b11)) + main.ptr);
	}
		
	char[] readsz(uint addr) {
		char[] r;
		while (true) {
			char c = read1(addr++);
			if (c == 0) break;
			r ~= c;
		}
		return r;
	}
	
	char[] readsz8(uint addr) {
		return fromMBSz(cast(char*)gptr(addr), 0);
	}
	
	// DEBUG
	
	void dump(uint addr) {		
		for (int y = 0; y < 16; y++) {
			printf("[");
			for (int x = 0; x < 16; x++) {
				if (x != 0) printf(" ");
				printf("%02X", read1(addr + x));
			}
			printf("] ");
			
			for (int x = 0; x < 16; x++) {
				char c = cast(char)read1(addr + x);
				printf("%c", (c > 0x20) ? c : '.');
			}
			
			printf("\n");
			addr += 16;
		}
	}	
	
	// VECTOR
	
    ubyte opIndex(uint addr) { return read1(addr); }	
    ubyte opIndexAssign(ubyte v, uint addr) { return write1(addr, v); }
	
	// STREAM
	
	ulong stream_pos = 0;
		
	override {
		override uint readBlock(void* buffer, uint size) {
			uint r = size; ubyte* b = cast(ubyte *)buffer;
			for (; size > 0; b++, size--, stream_pos++) try { *b = read1(stream_pos); } catch { *b = 0; }
			return r;
		}

		uint writeBlock(void* buffer, uint size) {	
			uint r = size; ubyte* b = cast(ubyte *)buffer;
			for (; size > 0; b++, size--, stream_pos++) try { write1(stream_pos, *b); } catch { }
			return r;
		}
		
		ulong seek(long offset, SeekPos whence) {			
			switch (whence) {
				default:
				case SeekPos.Set:     stream_pos = offset; break;
				case SeekPos.Current: stream_pos += offset; break;
				case SeekPos.End:     stream_pos = 0x_FF_FF_FF_FF + offset; break;
			}			
		
			return stream_pos;
		}
	}
	
	void save(Stream s) {
		s.write(main);		
		s.write(frmb);
		s.write(spad);
	}

	void load(Stream s) {
		s.read(main);		
		s.read(frmb);
		s.read(spad);
	}
	
	char[][uint] comments;
		
	void setComment(uint addr, char[] comment) {
		comments[addr] = comment;
	}

	char[] getComment(uint addr) {
		if (addr in comments) return comments[addr];
		return "";
	}
}

int   F_I(float f) { return *(cast(int *)&f); }
float I_F(int   f) { return *(cast(float *)&f); }
