module gdb.GdbProcessorRegisters;

struct GdbProcessorRegisters {
	union {
		struct {
			// 0x00 .. 0x1F
			uint[32] GPR;
			// 0x20
			uint CP0_STATUS;
			// 0x21
			uint LO;
			// 0x22
			uint HI;
			// 0x23
			uint CP0_BADVADDR;
			// 0x24
			union {
				uint PC;
				uint CO0_CAUSE;
			}
			// 0x25
			uint __UNK;
			// 0x26 .. 0x45
			uint[32] FPR;
			// 0x46
			uint FCSR;
			// 0x47
			uint FIR;
			// 0x48
			uint LINUX_RESTART;
		}
		uint[0x49] ALL;
	}
	
	static assert (this.sizeof == uint.sizeof * 0x49);
}
