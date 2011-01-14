module pspemu.utils.Audio;

import std.c.windows.windows;
import std.stdio;
import core.thread;
import std.stream;

import pspemu.utils.Utils;

//debug = DEBUG_DUMP_AUDIO_CHANNELS;

//version = VERSION_ONLY_FIRST_CHANNEL;

/*
static const uint SndOutPacketSize = 512;
static const uint MAX_BUFFER_COUNT = 8;

static const int PacketsPerBuffer = (1024 / SndOutPacketSize);
static const int BufferSize = SndOutPacketSize*PacketsPerBuffer;
*/

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

class RingBuffer(Type) {
	Type[] buffer;

	uint readingPosition;
	uint writtingPosition;
	uint readLeft;
	uint writeLeft;
	uint capacity() { return buffer.length; }
	Object readLock, writeLock;
	
	this(uint capacity) {
		buffer.length = capacity;
		readingPosition = 0;
		writtingPosition = 0;
		readLeft = 0;
		writeLeft = capacity;
		readLock = new Object;
		writeLock = new Object;
	}

	void read(Type[] data) {
		if (data.length > readLeft) throw(new Exception("Buffer underrun"));
		synchronized (readLock) {
			readLeft -= data.length;
			foreach (ref v; data) {
				v = buffer[readingPosition];
				readingPosition = (readingPosition + 1) % buffer.length;
			}
			writeLeft += data.length;
		}
	}
	
	void write(Type[] data) {
		if (data.length > writeLeft) throw(new Exception("Buffer overrun"));
		synchronized (writeLock) {
			writeLeft -= data.length;
			foreach (ref v; data) {
				buffer[writtingPosition] = v;
				writtingPosition = (writtingPosition + 1) % buffer.length;
			}
			readLeft += data.length;
		}
	}
}

class Audio {
	//const int bufferSize = 84; // less than 2ms
	const int bufferSize = 441; // 10ms
	//const int bufferSize = 128;
	
	class Channel {
		int index;
		RingBuffer!(short) samples;
		
		this(int index) {
			samples = new typeof(samples)(44100 * 2 * 2); // 2 seconds for two channels
		}
		
		bool isPlaying() {
			//return samples.readLeft > samples.capacity / 2;
			//return samples.readLeft > 4410 * 2; // 100ms
			return samples.readLeft > bufferSize * 2 * 5;
			//return samples.readLeft > bufferSize * 2 * 20;
		}
		
		void wait() {
			//writefln("read:%d, write:%d, capacity:%d, readpos:%d, writepos:%d", samples.readLeft, samples.writeLeft, samples.capacity, samples.readingPosition, samples.writtingPosition);
			while (isPlaying) {
				sleep(1);
				//Sleep(0);
			}
			//while (samples.writeLeft < samples.capacity / 2) sleep(1);
		}
		
		uint samplesLeft() {
			return samples.readLeft;
		}
		
		void read(short[] samplesToRead) {
			samples.read(samplesToRead);
			//writefln("%s", samplesToRead);
		}

		void write(short[] samplesToWrite, int numchannels, float volumeLeft = 1.0, float volumeRight = 1.0) {
			//writefln("writting(%d) : %d", index, samplesToWrite.length);
			switch (numchannels) {
				case 1:
					//writefln("single channel!");
					for (int n = 0, m = 0; n < samplesToWrite.length; n++, m += 2) {
						samples.write([
							cast(short)(cast(float)samplesToWrite[n] * volumeLeft),
							cast(short)(cast(float)samplesToWrite[n] * volumeRight)
						]);
					}
				break;
				case 2:
					// Ignore volume
					samples.write(samplesToWrite);
					/*
					for (int m = 0; m < samplesToWrite.length; m += 2) {
						samples.write([
							cast(short)(cast(float)samplesToWrite[m + 0] * volumeLeft),
							cast(short)(cast(float)samplesToWrite[m + 1] * volumeRight)
						]);
					}
					*/
				break;
				default: throw(new Exception(std.string.format("Only supported 1 and 2 numchannels for channel not %d.", numchannels)));
			}
		}
	}
	
	class Buffer {
		WAVEHDR	wavehdr;
		short[bufferSize * 2] data;

		void prepare() {
			wavehdr.dwFlags         = WHDR_DONE;
			wavehdr.lpData          = cast(LPSTR)data.ptr;
			wavehdr.dwBufferLength  = data.length * short.sizeof;
			wavehdr.dwBytesRecorded = 0;
			wavehdr.dwUser          = 0;
			wavehdr.dwLoops         = 0;
			enforcemm(waveOutPrepareHeader(waveOutHandle, &wavehdr, wavehdr.sizeof));
			wavehdr.dwFlags |= WHDR_DONE;
		}
		
		void play() {
			wavehdr.dwFlags &= ~WHDR_DONE;
			enforcemm(waveOutWrite(waveOutHandle, &wavehdr, wavehdr.sizeof));
		}
		
		bool ready() {
			return wavehdr.dwFlags & WHDR_DONE;
		}
	}
	
	Channel[8] channels;
	Buffer[4] buffers;
	int[bufferSize * 2] bufferTemp;
	short[bufferSize * 2] bufferTemp2;

	int fillBuffer(short[] bufferBack) {
		int playingChannels;
		bufferTemp[] = 0;
		bufferBack[] = 0;
		int maxMixed = 0;

		foreach (channel; channels) {
			int channelMixLen = min(channel.samplesLeft, bufferTemp.length);
			maxMixed = max(maxMixed, channelMixLen);
			
			if (channelMixLen) {
				channel.read(bufferTemp2[0..channelMixLen]);
				foreach (n; 0..channelMixLen) bufferTemp[n] += bufferTemp2[n];

				playingChannels++;
			}
		}

		if (playingChannels) {
			for (int n = 0; n < bufferBack.length; n++) bufferBack[n] = cast(short)(bufferTemp[n] / playingChannels);
		}
		
		return maxMixed;
	}
	
	bool _running = true;
	uint playingPos;
	Thread thread;

	HWAVEOUT      waveOutHandle;
	WAVEFORMATEX  pcmwf;
	WAVEHDR	      wavehdr;
	MMTIME        mmtime;

	this() {
		foreach (n, ref channel; channels) channel = new Channel(n);
		foreach (ref buffer; buffers) buffer = new Buffer();
		(thread = new Thread(&playThread)).start();
	}

	void stop() {
		_running = false;
	}
	
	bool anyChannelAvailable() {
		return true;
		//foreach (channel; channels) if (channel.samplesLeft >= 84 * 2) return true;
		foreach (channel; channels) if (channel.samplesLeft >= bufferTemp.length) return true;
		return false;
	}

	void playThread() {
		//Thread.getThis.priority = +1;

		pcmwf.wFormatTag      = WAVE_FORMAT_PCM; 
		pcmwf.nChannels       = 2;
		pcmwf.wBitsPerSample  = 16;
		pcmwf.nBlockAlign     = 2 * short.sizeof;
		pcmwf.nSamplesPerSec  = 44100;
		pcmwf.nAvgBytesPerSec = pcmwf.nSamplesPerSec * pcmwf.nBlockAlign; 
		pcmwf.cbSize          = 0;
		enforcemm(waveOutOpen(&waveOutHandle, WAVE_MAPPER, &pcmwf, 0, 0, 0));

		foreach (buffer; buffers) buffer.prepare();

		try {
			while (_running) {
				bool didsomething = false;

				foreach (buffer; buffers) {
					if (buffer.ready && anyChannelAvailable) {
						fillBuffer(buffer.data);
						buffer.play();
						didsomething = true;
					}
				}

				//Sleep(didsomething ? 1 : 0);
				Sleep(1);
				//Sleep(0);
			}
		} catch (Object o) {
			writefln("Audio.playThread: %s", o);
		} finally {
			enforcemm(waveOutClose(waveOutHandle));
		}
	}
	
	void writeWait(int channel, int numchannels, short[] samples, float volumeleft = 1.0, float volumeright = 1.0) {
		version (VERSION_ONLY_FIRST_CHANNEL) if (channel != 0) return;

		auto cchannel = channels[channel];
		cchannel.write(samples, numchannels, volumeleft, volumeright);
		cchannel.wait();

		debug (DEBUG_DUMP_AUDIO_CHANNELS) writeWaitWAV(channel, numchannels, samples, volumeleft, volumeright);
	}

	debug (DEBUG_DUMP_AUDIO_CHANNELS) {
		Stream[int] wavs;
		void writeWaitWAV(int channel, int numchannels, short[] samples, float volumeleft = 1.0, float volumeright = 1.0) {
			Stream wav;
			WaveFile header;
			if (channel !in wavs) wavs[channel] = new std.stream.File(std.string.format("%d.wav", channel), FileMode.OutNew);
			wav = wavs[channel];
			
			auto pos_back = cast(uint)wav.position;
			wav.write(cast(ubyte[])samples);
			auto pos = cast(uint)wav.position;
			
			//writefln("CHANNEL(%d): %d -> %d (%d)", channel, pos_back, pos, samples.length);

			header.Subchunk2Size = pos - header.sizeof;
			header.Subchunk1Size = 16;
			header.ChunkSize = 4 + (8 + header.Subchunk1Size) + (8 + header.Subchunk2Size);

			wav.position = 0;
			wav.write(TA(header));
			wav.position = pos;
		}
	}
}
