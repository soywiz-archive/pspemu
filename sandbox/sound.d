// dmd -run sound.d

// http://www.fmod.org/index.php/download#FMODMini
// http://www.planet-source-code.com/vb/scripts/ShowCode.asp?txtCodeId=4422&lngWId=3

import std.stdio;
import std.math;
import std.contracts;
import std.c.windows.windows;

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

	void writeBuffer(float[] buffer) {
		wavehdr.dwFlags         = WHDR_BEGINLOOP | WHDR_ENDLOOP;
		wavehdr.lpData          = cast(LPSTR)buffer.ptr;
		wavehdr.dwBufferLength  = buffer.length * buffer[0].sizeof;
		wavehdr.dwBytesRecorded = 0;
		wavehdr.dwUser          = 0;
		wavehdr.dwLoops         = 0;
		enforcemm(waveOutPrepareHeader(waveOutHandle, &wavehdr, wavehdr.sizeof));
		enforcemm(waveOutWrite(waveOutHandle, &wavehdr, wavehdr.sizeof));
	}

	void writeBufferBlock(float[] buffer) {
		writeBuffer(buffer);
		while (position < buffer.length / pcmwf.nChannels) {
			Sleep(1);
		}
	}

	uint position() {
		MMTIME mmtime = MMTIME(TIME_SAMPLES);
		enforcemm(waveOutGetPosition(waveOutHandle, &mmtime, mmtime.sizeof));
		return mmtime.u.sample;
	}
}

void simpleTest() {
	HWAVEOUT      waveOutHandle;
	WAVEFORMATEX  pcmwf;
	WAVEHDR	      wavehdr;
	float[]       buffer;
	MMTIME        mmtime;

	// ========================================================================================================
	// INITIALIZE WAVEOUT
	// ========================================================================================================
	{
		pcmwf.wFormatTag		= WAVE_FORMAT_IEEE_FLOAT; 
		pcmwf.nChannels			= 2;
		pcmwf.wBitsPerSample	= float.sizeof * 8;
		pcmwf.nBlockAlign		= cast(ushort)(pcmwf.nChannels * pcmwf.wBitsPerSample / 8);
		pcmwf.nSamplesPerSec	= 44100;
		pcmwf.nAvgBytesPerSec	= pcmwf.nSamplesPerSec * pcmwf.nBlockAlign; 
		pcmwf.cbSize			= 0;

		enforcemm(waveOutOpen(&waveOutHandle, WAVE_MAPPER, &pcmwf, 0, 0, 0));
	}
	{
		buffer = new float[44100 * 2];
		
		wavehdr.dwFlags         = WHDR_BEGINLOOP | WHDR_ENDLOOP;
		wavehdr.lpData          = cast(LPSTR)buffer.ptr;
		wavehdr.dwBufferLength  = buffer.length * buffer[0].sizeof;
		wavehdr.dwBytesRecorded = 0;
		wavehdr.dwUser          = 0;
		wavehdr.dwLoops         = -1;

		enforcemm(waveOutPrepareHeader(waveOutHandle, &wavehdr, wavehdr.sizeof));
	}

	for (int n = 0; n < buffer.length; n += 2) {
		buffer[n + 0] = sin((cast(float)n) / 20);
		buffer[n + 1] = cos((cast(float)n) / 20);
	}

	enforcemm(waveOutWrite(waveOutHandle, &wavehdr, wavehdr.sizeof));

	for (int n = 0; n < 10; n++) {
		Sleep(100);
		mmtime.wType = TIME_SAMPLES;
		enforcemm(waveOutGetPosition(waveOutHandle, &mmtime, mmtime.sizeof));
		writefln("%d", mmtime.u.sample);
	}
}

string FunctionName(alias f)() { return (&f).stringof[2 .. $]; }
string FunctionName(T)() { return T.stringof[2 .. $]; }

extern (Windows) {
	alias void FMUSIC_MODULE;
	byte function(int mixrate, int maxsoftwarechannels, uint flags) FSOUND_Init;
	FMUSIC_MODULE* function(char *name) FMUSIC_LoadSong;
	byte function(FMUSIC_MODULE*) FMUSIC_PlaySong;
}

void fmodTest() {
	HANDLE fmod_dll = enforce(LoadLibraryA("fmod.dll"));
	void bind(alias func, string size)() {
		mixin("*(cast(void **)&" ~ FunctionName!(func) ~ ") = enforce(GetProcAddress(fmod_dll, \"_" ~ FunctionName!(func) ~ "@" ~ (size) ~ "\"));");
		//writefln("BIND:%s", FunctionName!(func));
	}
	bind!(FSOUND_Init, "12");
	bind!(FMUSIC_LoadSong, "4");
	bind!(FMUSIC_PlaySong, "4");
	FSOUND_Init(44100, 8, 0);
	/*
	auto mod = FMUSIC_LoadSong(cast(char*)"test.s3m\0");
	FMUSIC_PlaySong(mod);
	*/
	//assert(0);
}

void main() {
	//simpleTest();
	//fmodTest();
	auto audio = new Audio;
	auto buffer = new float[44100 * 2];
	for (int n = 0; n < buffer.length; n += 2) {
		buffer[n + 0] = sin((cast(float)n) / 20);
		buffer[n + 1] = cos((cast(float)n) / 10);
	}
	audio.writeBufferBlock(buffer);
}
