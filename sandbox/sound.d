// dmd -run sound.d

// http://www.fmod.org/index.php/download#FMODMini
// http://www.planet-source-code.com/vb/scripts/ShowCode.asp?txtCodeId=4422&lngWId=3

import core.thread;
import std.stdio;
import std.math;
import std.contracts;
import std.c.windows.windows;

pragma(lib, "winmm.lib");

T min(T)(T a, T b) { return (a < b) ? a : b; }
T max(T)(T a, T b) { return (a > b) ? a : b; }

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

enum {
	WAVE_FORMAT_QUERY = 0x00000001,
	WAVE_ALLOWSYNC    = 0x00000002,
	CALLBACK_FUNCTION = 0x00030000,
}
static const WOM_OPEN  = 0x3BB;
static const WOM_CLOSE = 0x3BC;
static const WOM_DONE  = 0x3BD;

static int value = 0;

__gshared static int[] messages;


class Audio {
	class Channel {
		uint playingPosition;
		uint samplesCount;
		short samples[44100 * 2];
		uint samplesLeft() { return samplesCount - playingPosition; }
		bool isPlaying() { return (samplesLeft == 0); }
	
		void set(short[] samplesToWrite, float volumeLeft = 1.0, float volumeRight = 1.0) {
			playingPosition = 0;
			samplesCount = samplesToWrite.length;
			for (int n = 0; n < samplesToWrite.length; n += 2) {
				samples[n + 0] = cast(short)(cast(float)samplesToWrite[n + 0] * volumeLeft);
				samples[n + 1] = cast(short)(cast(float)samplesToWrite[n + 1] * volumeRight);
			}
		}
	}
	
	Channel[8] channels;
	//short[0x40] mixedBuffer;
	int[220 * 2] tempBuffer;
	short[220 * 2 * 2] buffer;
	bool _running = true;
	uint playingPos;
	Thread thread;

	HWAVEOUT      waveOutHandle;
	WAVEFORMATEX  pcmwf;
	WAVEHDR	      wavehdr;
	MMTIME        mmtime;

	this() {
		for (int n = 0; n < channels.length; n++) channels[n] = new Channel;
		(thread = new Thread(&playThread)).start();
	}

	void stop() {
		_running = false;
	}

	void playThread() {
		pcmwf.wFormatTag      = WAVE_FORMAT_PCM; 
		pcmwf.nChannels       = 2;
		pcmwf.wBitsPerSample  = 16;
		pcmwf.nBlockAlign     = 2 * short.sizeof;
		pcmwf.nSamplesPerSec  = 44100;
		pcmwf.nAvgBytesPerSec = pcmwf.nSamplesPerSec * pcmwf.nBlockAlign; 
		pcmwf.cbSize          = 0;
		enforcemm(waveOutOpen(&waveOutHandle, WAVE_MAPPER, &pcmwf, 0, 0, 0));

		wavehdr.dwFlags         = WHDR_BEGINLOOP | WHDR_ENDLOOP;
		wavehdr.lpData          = cast(LPSTR)buffer.ptr;
		wavehdr.dwBufferLength  = buffer.length * short.sizeof;
		wavehdr.dwBytesRecorded = 0;
		wavehdr.dwUser          = 0;
		wavehdr.dwLoops         = -1;
		enforcemm(waveOutPrepareHeader(waveOutHandle, &wavehdr, wavehdr.sizeof));
		enforcemm(waveOutWrite(waveOutHandle, &wavehdr, wavehdr.sizeof));

		bool bufferToggle = false;

		void mix() {
			tempBuffer[] = 0;

			for (int ch = 0; ch < channels.length; ch++) {
				auto channel = channels[ch];
				int channelMixLen = min(channel.samplesCount - channel.playingPosition, tempBuffer.length);
				//writefln("%d", channelMixLen);
				for (int n = 0; n < channelMixLen; n++) {
					//writefln("%d", n);
					tempBuffer[n] += channel.samples[channel.playingPosition + n];
				}
				channel.playingPosition += channelMixLen;
			}
			for (int n = 0; n < tempBuffer.length; n++) {
				buffer[tempBuffer.length * bufferToggle + n] = cast(short)(tempBuffer[n] / channels.length);
			}
			
			bufferToggle = !bufferToggle;
		}

		while (_running) {
			mix();
			Sleep(5);
		}
	}


	void writeBufferBlock(short[] buffer, int channel = 0) {
		//writeBuffer(buffer);
		//while (blocked) Sleep(1);
		channels[channel].set(buffer);
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

void test() {
	//simpleTest();
	//fmodTest();
	auto audio = new Audio;
	auto buffer = new short[41100 * 2];
	for (int n = 0; n < buffer.length; n += 2) {
		buffer[n + 0] = cast(short)(sin((cast(float)n) / 20) * cast(float)0x7FFF);
		buffer[n + 1] = cast(short)(cos((cast(float)n) / 10) * cast(float)0x7FFF);
	}
	audio.writeBufferBlock(buffer, 0);

	for (int n = 0; n < buffer.length; n += 2) {
		buffer[n + 0] = cast(short)(sin((cast(float)n) / 40) * cast(float)0x7FFF);
		buffer[n + 1] = cast(short)(cos((cast(float)n) / 40) * cast(float)0x7FFF);
	}
	audio.writeBufferBlock(buffer, 1);
}

void main() {
	test();
	writefln("end! [%s]:%d", messages, messages.length);
}
