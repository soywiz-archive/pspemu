module pspemu.utils.Audio;

import std.c.windows.windows;
import std.contracts;
import std.stdio;
import core.thread;

import pspemu.utils.Utils;

pragma(lib, "winmm.lib");

alias HANDLE HWAVEOUT;
alias uint MMRESULT;

align(1) struct WaveFile {
	char[4] ChunkID = "RIFF";
	uint    ChunkSize;
	char[4] Format  = "WAVE";
	char[4] Subchunk1ID  = "fmt ";
	uint    Subchunk1Size;
	ushort  AudioFormat = 1; // PCM
	ushort  NumChannels = 2;
	uint    SampleRatio = 40100;
	uint    ByteRate = 40100 * 2 * (16 / 8);
	ushort  BlockAlign = 2 * (16 / 8);
	ushort  BitsPerSample = 16;
	char[4] Subchunk2ID = "data";
	uint    Subchunk2Size;
}

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
	MMRESULT waveOutClose(HWAVEOUT hwo);
}

T enforcemm(T)(T errno, int line = __LINE__, string file = __FILE__) {
	if (errno != MMSYSERR_NOERROR) throw(new Exception(std.string.format("MMSYSERR: %d at '%s:%d'", errno, file, line)));
	return errno;
}

/*
static const CALLBACK_FUNCTION = 0x00030000;
static const WOM_OPEN  = 0x3BB;
static const WOM_CLOSE = 0x3BC;
static const WOM_DONE  = 0x3BD;
*/

class Audio {
	class Channel {
		uint playingPosition;
		uint samplesCount;
		short samples[44100 * 2];
		uint samplesLeft() { return samplesCount - playingPosition; }
		bool isPlaying() { return (samplesLeft == 0); }
		
		void wait() {
			while (isPlaying) Sleep(1);
		}
	
		void set(short[] samplesToWrite, int numchannels, float volumeLeft = 1.0, float volumeRight = 1.0) {
			switch (numchannels) {
				case 1:
					for (int n = 0, m = 0; n < samplesToWrite.length; n++, m += 2) {
						samples[m + 0] = cast(short)(cast(float)samplesToWrite[n] * volumeLeft);
						samples[m + 1] = cast(short)(cast(float)samplesToWrite[n] * volumeRight);
					}
				break;
				case 2:
					for (int m = 0; m < samplesToWrite.length; m += 2) {
						samples[m + 0] = cast(short)(cast(float)samplesToWrite[m + 0] * volumeLeft);
						samples[m + 1] = cast(short)(cast(float)samplesToWrite[m + 1] * volumeRight);
					}
				break;
				default: throw(new Exception(std.string.format("Only supported 1 and 2 numchannels for channel not %d.", numchannels)));
			}
			playingPosition = 0;
			samplesCount = samplesToWrite.length;
		}
	}
	
	Channel[8] channels;
	//short[0x40] mixedBuffer;
	//int[220 * 2] tempBuffer;
	short[220 * 2 * 2] buffer;
	short[] bufferFront, bufferBack;
	bool _running = true;
	uint playingPos;
	Thread thread;

	HWAVEOUT      waveOutHandle;
	WAVEFORMATEX  pcmwf;
	WAVEHDR	      wavehdr;
	MMTIME        mmtime;

	this() {
		bufferFront = buffer[0..buffer.length / 2];
		bufferBack  = buffer[buffer.length / 2..$];
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

		void mix() {
			int[220 * 2] bufferTemp;
			int[int] channelsEndings;
			int playingChannels;

			foreach (channel; channels) {
				int channelMixLen = min(channel.samplesCount - channel.playingPosition, bufferTemp.length);
				
				if (channelMixLen) {
					for (int n = 0; n < channelMixLen; n++) {
						bufferTemp[n] += channel.samples[channel.playingPosition + n];
					}
					channel.playingPosition += channelMixLen;
					playingChannels++;
					if ((channelMixLen in channelsEndings) is null) channelsEndings[channelMixLen] = 1; else channelsEndings[channelMixLen]++;
				}
			}

			static if (1) {
				struct Slice { int numSamples, numChannels; }
				Slice[] channelCountSlices;
				int backPos = 0;
				int numChannels = playingChannels;
				foreach (pos; channelsEndings.keys.sort) {
					int count = channelsEndings[pos];
					channelCountSlices ~= Slice(pos - backPos, numChannels);
					backPos = pos;
					numChannels -= count;
				}
				channelCountSlices ~= Slice(bufferTemp.length - backPos, 0);

				int m = 0;
				foreach (slice; channelCountSlices) {
					if (slice.numChannels) {
						for (int n = 0; n < slice.numSamples; n++) bufferBack[m + n] = cast(short)(bufferTemp[m + n]);
					} else {
						bufferBack[m..m + slice.numSamples][] = 0;
					}
					m += slice.numSamples;
				}
			} else {
				if (playingChannels) {
					for (int n = 0; n < bufferBack.length; n++) {
						bufferBack[n] = cast(short)(bufferTemp[n] / playingChannels);
					}
				} else {
					bufferBack[] = 0;
				}
			}

			swap(bufferFront, bufferBack);
		}

		try {
			while (_running) {
				mix();
				Sleep(5);
			}
		} catch (Object o) {
			writefln("Audio.playThread: %s", o);
		} finally {
			enforcemm(waveOutClose(waveOutHandle));
		}
	}

	void writeWait(int channel, int numchannels, short[] samples, float volumeleft = 1.0, float volumeright = 1.0) {
		channels[channel].set(samples, numchannels, volumeleft, volumeright);
		channels[channel].wait();
	}
}
