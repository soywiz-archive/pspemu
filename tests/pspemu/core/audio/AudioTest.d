module pspemu.core.audio.AudioTest;

import pspemu.core.audio.Audio;
import pspemu.utils.sync.WaitEvent;

import tests.Test;

import core.thread;

class AudioMock : Audio {
	WaitEvent stopEvent;
	int outOpen_Count = 0;
	int outPrepare_Count = 0;
	int outGetPosition_Count = 0;
	int outWrite_Count = 0;
	int outClose_Count = 0;
	short[] output;
	
	this() {
		super();
		stopEvent = new WaitEvent();
	}
	
	void stop() {
		Audio.stop();
	}
	
	MMRESULT waveOutOpen(HWAVEOUT* phwo, UINT uDeviceID, WAVEFORMATEX* pwfx, DWORD dwCallback, DWORD dwInstance, DWORD fdwOpen) {
		*phwo = cast(HANDLE)1;
		//writefln("waveOutOpen(%d, %s, %d, %d, %d)", cast(int)uDeviceID, *pwfx, dwCallback, dwInstance, fdwOpen);
		outOpen_Count++;
		return 0;
	}
	MMRESULT waveOutPrepareHeader(HWAVEOUT hwo, WAVEHDR* pwh, UINT cbwh) {
		//writefln("waveOutPrepareHeader(%d, %s)", cast(int)hwo, *pwh);
		outPrepare_Count++;
		return 0;
	}
	MMRESULT waveOutWrite(HWAVEOUT hwo, WAVEHDR* pwh, UINT cbwh) {
		short[] data = (cast(short *)pwh.lpData)[0..pwh.dwBufferLength / short.sizeof];
		output ~= data.dup;

		//writefln("waveOutWrite(%d, %s, %d)", cast(int)hwo, *pwh, cbwh);
		//writefln("%s", data);
		pwh.dwFlags |= WHDR_DONE;
		
		
		outWrite_Count++;
		if (outWrite_Count >= 14) {
			this.stop();
		}
		return 0;
	}
	MMRESULT waveOutGetPosition(HWAVEOUT hwo, MMTIME* pmmt, UINT cbmmt) {
		outGetPosition_Count++;
		//writefln("waveOutGetPosition");
		return 0;
	}
	MMRESULT waveOutClose(HWAVEOUT hwo) {
		outClose_Count++;
		//writefln("waveOutClose(%d)", cast(int)hwo);
		stopEvent.signal();
		return 0;
	}
}

class AudioTest : Test {
	AudioMock audio;
	
	void setUp() {
		audio = new AudioMock();
	}
	
	void tearDown() {
		audio.stop();
	}
	
	void testAudio() {
		short[] buffer0 = new short[6000];
		short[] buffer1 = new short[6000];
		short[] buffer0_1 = new short[6000];
		foreach (n, ref c; buffer0) c = cast(short)n; 
		foreach (n, ref c; buffer1) c = cast(short)(-n + 2);
		foreach (n, ref c; buffer0_1) c = (buffer0[n] + buffer1[n]) / 2;
		//writefln("%s", buffer);
		audio.channels[0].write(buffer0, 1);
		audio.channels[1].write(buffer1, 1);
		
		audio.start();
		audio.stopEvent.wait();

		assertEquals(1, audio.outOpen_Count);
		assertEquals(4, audio.outPrepare_Count);
		assertEquals(14, audio.outWrite_Count);
		assertEquals(0, audio.outGetPosition_Count);
		assertEquals(1, audio.outClose_Count);
		assertEquals(audio.output[0..buffer0_1.length], buffer0_1);
	}
}