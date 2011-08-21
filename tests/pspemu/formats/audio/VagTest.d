module pspemu.formats.audio.VagTest;

import pspemu.formats.audio.Vag;

import tests.Test;

class VagTest : Test {
	mixin TRegisterTest;
	
	void testLoadWithHeader() {
		VAG vag = new VAG();
		vag.load(import("VAG_WITH_HEADER"));
	}
	// dmd pspemu\utils\MathUtils.d pspemu\utils\audio\wav.d -run pspemu\formats\audio\Vag.d
	/*
	int main(string[] args) {
		VAG vag = new VAG();
		vag.load(cast(ubyte[])std.file.read("TEMP_AUDIO_DAT.BIN"));
		writefln("%d", vag.decodedSamples.length);
		std.file.write(
			"TEMP_AUDIO_DAT.WAV",
			WaveProcessor.getBytes(vag.decodedSamples, WaveProcessor.WaveFormat.getByInfo(1, 44100 / 2))
		);
		
		return 0;
	}
	*/	
}