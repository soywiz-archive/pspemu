module psp.disassembler.gpu;

class GPU_Disasm {
	static char[][] VC_N = [
		"NOP", "VADDR", "IADDR", "Unknown0x03", "PRIM", "BEZIER", "SPLINE", "BBOX", "JUMP", "BJUMP", "CALL", "RET", "END", "Unknown0x0D",
		"SIGNAL", "FINISH", "BASE", "Unknown0x11", "VTYPE", "OFFSETADDR", "ORIGINADDR", "REGION1", "REGION2", "LTE", "LTE0", "LTE1", "LTE2",
		"LTE3", "CPE", "BCE", "TME", "FGE", "DTE", "ABE", "ATE", "ZTE", "STE", "AAE", "PCE", "CTE", "LOE", "Unknown0x29", "BOFS", "BONE", "MW0",
		"MW1", "MW2", "MW3", "MW4", "MW5", "MW6", "MW7", "Unknown0x34", "Unknown0x35", "PSUB", "PPRIM", "PFACE", "Unknown0x39", "WMS", "WORLD",
		"VMS", "VIEW", "PMS", "PROJ", "TMS", "TMATRIX", "XSCALE", "YSCALE", "ZSCALE", "XPOS", "YPOS", "ZPOS", "USCALE", "VSCALE", "UOFFSET",
		"VOFFSET", "OFFSETX", "OFFSETY", "Unknown0x4E", "Unknown0x4F", "SHADE", "RNORM", "Unknown0x52", "CMAT", "EMC", "AMC", "DMC", "SMC", "AMA",
		"Unknown0x59", "Unknown0x5A", "SPOW", "ALC", "ALA", "LMODE", "LT0", "LT1", "LT2", "LT3", "LXP0", "LYP0", "LZP0", "LXP1", "LYP1", "LZP1",
		"LXP2", "LYP2", "LZP2", "LXP3", "LYP3", "LZP3", "LXD0", "LYD0", "LZD0", "LXD1", "LYD1", "LZD1", "LXD2", "LYD2", "LZD2", "LXD3", "LYD3",
		"LZD3", "LCA0", "LLA0", "LQA0", "LCA1", "LLA1", "LQA1", "LCA2", "LLA2", "LQA2", "LCA3", "LLA3", "LQA3", "SPOTEXP0", "SPOTEXP1",
		"SPOTEXP2", "SPOTEXP3", "SPOTCUT0", "SPOTCUT1", "SPOTCUT2", "SPOTCUT3", "ALC0", "DLC0", "SLC0", "ALC1", "DLC1", "SLC1", "ALC2", "DLC2",
		"SLC2", "ALC3", "DLC3", "SLC3", "FFACE", "FBP", "FBW", "ZBP", "ZBW", "TBP0", "TBP1", "TBP2", "TBP3", "TBP4", "TBP5", "TBP6", "TBP7",
		"TBW0", "TBW1", "TBW2", "TBW3", "TBW4", "TBW5", "TBW6", "TBW7", "CBP", "CBPH", "TRXSBP", "TRXSBW", "TRXDBP", "TRXDBW", "Unknown0xB6",
		"Unknown0xB7", "TSIZE0", "TSIZE1", "TSIZE2", "TSIZE3", "TSIZE4", "TSIZE5", "TSIZE6", "TSIZE7", "TMAP", "TEXTURE", "TMODE", "TPSM",
		"CLOAD", "CMODE", "TFLT", "TWRAP", "TBIAS", "TFUNC", "TEC", "TFLUSH", "TSYNC", "FFAR", "FDIST", "FCOL", "TSLOPE", "Unknown0xD1", "PSM",
		"CLEAR", "SCISSOR1", "SCISSOR2", "NEARZ", "FARZ", "CTST", "CREF", "CMSK", "ATST", "STST", "SOP", "ZTST", "ALPHA", "SFIX", "DFIX", "DTH0",
		"DTH1", "DTH2", "DTH3", "LOP", "ZMSK", "PMSKC", "PMSKA", "TRXKICK", "TRXSPOS", "TRXDPOS", "Unknown0xED", "TRXSIZE", "Unknown0xEF",
		"Unknown0xF0", "Unknown0xF1", "Unknown0xF2", "Unknown0xF3", "Unknown0xF4", "Unknown0xF5", "Unknown0xF6", "Unknown0xF7", "Unknown0xF8",
		"Unknown0xF9", "Unknown0xFA", "Unknown0xFB", "Unknown0xFC", "Unknown0xFD", "Unknown0xFE", "Unknown0xFF"
	];
	
	static char[] disasm(uint* ptr) {
		ubyte command = (*ptr >> 24) & 0xFF;
		return VC_N[command];
	}
}