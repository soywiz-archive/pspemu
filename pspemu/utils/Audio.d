module pspemu.utils.Audio;

import std.c.windows.windows;
import std.contracts;

pragma(lib, "winmm.lib");

alias HANDLE HWAVEOUT;
alias uint MMRESULT;

struct WAVEFORMATEX {
	WORD wFormatTag; 
	WORD nChannels; 
	DWORD nSamplesPerSec; 
	DWORD nAvgBytesPerSec; 
	WORD nBlockAlign; 
	WORD wBitsPerSample; 
	WORD cbSize;
}

struct WAVEHDR {
	LPSTR lpData;
	DWORD dwBufferLength;
	DWORD dwBytesRecorded;
	DWORD dwUser;
	DWORD dwFlags;
	DWORD dwLoops;
	WAVEHDR* lpNext;
	DWORD reserved;
}

struct MMTIME {
	UINT wType; 
	union U {
		DWORD ms; 
		DWORD sample; 
		DWORD cb; 
		DWORD ticks; 
		struct SMPTE {
			BYTE hour; 
			BYTE min; 
			BYTE sec; 
			BYTE frame; 
			BYTE fps; 
			BYTE dummy; 
			BYTE pad[2];
		}
		SMPTE smpte;
		struct MIDI {
			DWORD songptrpos;
		}
		MIDI midi;
	} 
	U u;
}

enum {
	TIME_MS      = 0x0001,  // time in milliseconds
	TIME_SAMPLES = 0x0002,  // number of wave samples
	TIME_BYTES   = 0x0004,  // current byte offset
	TIME_SMPTE   = 0x0008,  // SMPTE time
	TIME_MIDI    = 0x0010,  // MIDI time
	TIME_TICKS	 = 0x0020,  // MIDI ticks
}

enum {
	WAVE_FORMAT_UNKNOWN    = 0x0000,
	WAVE_FORMAT_PCM        = 0x0001,
	WAVE_FORMAT_ADPCM      = 0x0002,
	WAVE_FORMAT_IEEE_FLOAT = 0x0003,
}
const uint WAVE_MAPPER = -1;

enum {
	WHDR_DONE       = 0x00000001,
	WHDR_PREPARED   = 0x00000002,
	WHDR_BEGINLOOP  = 0x00000004,
	WHDR_ENDLOOP    = 0x00000008,
	WHDR_INQUEUE    = 0x00000010,
}

enum {
	MMSYSERR_NOERROR        = 0,
	MMSYSERR_ERROR          = 1,
	MMSYSERR_BADDEVICEID    = 2,
	MMSYSERR_NOTENABLED     = 3,
	MMSYSERR_ALLOCATED      = 4,
	MMSYSERR_INVALHANDLE    = 5,
	MMSYSERR_NODRIVER       = 6,
	MMSYSERR_NOMEM          = 7,
	MMSYSERR_NOTSUPPORTED   = 8,
	MMSYSERR_NOMAP          = 7,

	MIDIERR_UNPREPARED      = 64,
	MIDIERR_STILLPLAYING    = 65,
	MIDIERR_NOTREADY        = 66,
	MIDIERR_NODEVICE        = 67,

	WAVERR_BADFORMAT        = 32,
	WAVERR_STILLPLAYING     = 33,
	WAVERR_UNPREPARED       = 34,
	WAVERR_SYNC             = 35,

	MAXERRORLENGTH          = 128,
}

extern (Windows) {
	MMRESULT waveOutOpen(HWAVEOUT* phwo, UINT uDeviceID, WAVEFORMATEX* pwfx, DWORD dwCallback, DWORD dwInstance, DWORD fdwOpen);
	MMRESULT waveOutPrepareHeader(HWAVEOUT hwo, WAVEHDR* pwh, UINT cbwh);
	MMRESULT waveOutWrite(HWAVEOUT hwo, WAVEHDR* pwh, UINT cbwh);
	MMRESULT waveOutGetPosition(HWAVEOUT hwo, MMTIME* pmmt, UINT cbmmt);
}

T enforcemm(T)(T errno, int line = __LINE__, string file = __FILE__) {
	if (errno != MMSYSERR_NOERROR) throw(new Exception(std.string.format("MMSYSERR: %d at '%s:%d'", errno, file, line)));
	return errno;
}

class Audio {
	HWAVEOUT waveOutHandle;
	WAVEFORMATEX  pcmwf;
	WAVEHDR	      wavehdr;
	MMTIME        mmtime;
	float[]       currentBuffer;

	this() {
		pcmwf.wFormatTag		= WAVE_FORMAT_IEEE_FLOAT; 
		pcmwf.nChannels			= 2;
		pcmwf.wBitsPerSample	= float.sizeof * 8;
		pcmwf.nBlockAlign		= cast(ushort)(pcmwf.nChannels * pcmwf.wBitsPerSample / 8);
		pcmwf.nSamplesPerSec	= 44100;
		pcmwf.nAvgBytesPerSec	= pcmwf.nSamplesPerSec * pcmwf.nBlockAlign; 
		pcmwf.cbSize			= 0;
		enforcemm(waveOutOpen(&waveOutHandle, WAVE_MAPPER, &pcmwf, 0, 0, 0));
	}

	void write(float[] buffer) {
		bool REPEAT_ALWAYS = true;
		currentBuffer = buffer;
		wavehdr.dwFlags         = WHDR_BEGINLOOP | WHDR_ENDLOOP;
		wavehdr.lpData          = cast(LPSTR)buffer.ptr;
		wavehdr.dwBufferLength  = buffer.length * buffer[0].sizeof;
		wavehdr.dwBytesRecorded = 0;
		wavehdr.dwUser          = 0;
		wavehdr.dwLoops         = REPEAT_ALWAYS ? -1 : 0;
		enforcemm(waveOutPrepareHeader(waveOutHandle, &wavehdr, wavehdr.sizeof));
		enforcemm(waveOutWrite(waveOutHandle, &wavehdr, wavehdr.sizeof));
	}

	void wait() {
		while (position < currentBuffer.length / pcmwf.nChannels) Sleep(1);
	}

	void writeWait(float[] buffer) {
		write(buffer);
		wait();
	}

	uint position() {
		MMTIME mmtime = MMTIME(TIME_SAMPLES);
		enforcemm(waveOutGetPosition(waveOutHandle, &mmtime, mmtime.sizeof));
		return mmtime.u.sample;
	}
}
