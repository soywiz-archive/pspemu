module pspemu.formats.Pgf;

// http://forums.ps2dev.org/viewtopic.php?p=59845
// http://hitmen.c02.at/files/yapspd/psp_doc/chap26.html#sec26.9

class Pgf {
	struct Header {
		ubyte _ver[4] = x"00008801";
		char magic[4] = "PGF0";
	}
}
