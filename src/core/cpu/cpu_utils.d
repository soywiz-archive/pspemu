module pspemu.core.cpu.cpu_utils;

enum Advance { NO, YES }

static pure nothrow {
	string CpuExpression(string s, Advance advancePC = Advance.YES) {
		string r = "";
		for (int n = 0; n < s.length; n++) {
			if (s[n] == '$') {
				switch (s[n + 1..n + 3]) {
					case "fs": r ~= "registers.F[instruction.FS]"; break;
					case "fd": r ~= "registers.F[instruction.FD]"; break;
					case "ft": r ~= "registers.F[instruction.FT]"; break;
					case "rs": r ~= "registers.R[instruction.RS]"; break;
					case "rd": r ~= "registers.R[instruction.RD]"; break;
					case "rt": r ~= "registers.R[instruction.RT]"; break;
					case "im": r ~= "instruction.IMM"; break;
					case "um": r ~= "instruction.IMMU"; break;
					case "ps": r ~= "instruction.POS"; break;
					case "sz": r ~= "instruction.SIZE"; break;
					case "hi": r ~= "registers.HI"; break;
					case "lo": r ~= "registers.LO"; break;
					default:
						r ~= s[n];
						n -= 2;
					break;
				}
				n += 2;
			} else {
				r ~= s[n];
			}
		}
		if (advancePC) r ~= "registers.pcAdvance(4);";
		return r;
	}
}