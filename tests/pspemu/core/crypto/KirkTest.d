module pspemu.core.crypto.KirkTest;

import pspemu.core.crypto.crypto;
import pspemu.core.crypto.kirk;

import tests.Test;

class KirkTest : Test {
	mixin TRegisterTest;
	
	void testKirk() {
		/*
		ubyte[] data_inp = cast(ubyte[])"Hello World";
		ubyte[] data_tmp = new ubyte[11];
		ubyte[] data_out = new ubyte[11];
		writefln("%d", sceUtilsBufferCopyWithRange(data_inp, data_tmp, KIRK_CMD_ENCRYPT_IV_0));
		writefln("%d", sceUtilsBufferCopyWithRange(data_tmp, data_out, KIRK_CMD_DECRYPT_IV_0));
		writefln("%s", data_inp);
		writefln("%s", data_tmp);
		writefln("%s", data_out);
		*/
	}
}