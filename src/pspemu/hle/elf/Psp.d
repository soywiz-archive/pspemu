module pspemu.hle.elf.Psp;

import pspemu.hle.elf.PspHeader;

import pspemu.core.crypto.kirk;
import pspemu.core.exceptions.NotImplementedException;

class Psp {
	PspHeader pspHeader;
	
	ubyte[] decrypt(ubyte[] data) {
		throw(new NotImplementedException("Psp.decrypt"));
	}
}