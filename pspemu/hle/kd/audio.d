module pspemu.hle.kd.audio; // kd/audio.prx (sceAudio_Driver)

debug = DEBUG_AUDIO;
debug = DEBUG_SYSCALL;

import std.c.windows.windows;

import std.contracts;

import pspemu.hle.Module;
import pspemu.utils.Audio;

enum PspAudioFormats : uint {
	/** Channel is set to stereo output. */
	PSP_AUDIO_FORMAT_STEREO = 0,
	/** Channel is set to mono output. */
	PSP_AUDIO_FORMAT_MONO   = 0x10
}

class sceAudio_driver : Module {
	struct Channel {
		bool reserved;
		int  samplecount;
		PspAudioFormats format;
		int valuesPerSample() { return (format == PspAudioFormats.PSP_AUDIO_FORMAT_MONO) ? 1 : 2; }
	}
	
	Channel channels[8]; // PSP_AUDIO_CHANNEL_MAX
	Audio audio;

	void initNids() {
		mixin(registerd!(0x13F592BC, sceAudioOutputPannedBlocking));
		mixin(registerd!(0x5EC81C55, sceAudioChReserve));
		mixin(registerd!(0x6FC46853, sceAudioChRelease));
		mixin(registerd!(0x136CAF51, sceAudioOutputBlocking));
	}

	void initModule() {
		audio = new Audio;
	}

	int freeChannelIndex() {
		foreach (n, ref channel; channels) {
			if (!channel.reserved) return n;
		}
		return -1;
	}

	bool validChannelIndex(int index) {
		return (index >= 0 && index < channels.length);
	}

	/**
	  * Output panned audio of the specified channel (blocking)
	  *
	  * @param channel - The channel number.
	  * @param leftvol - The left volume.
	  * @param rightvol - The right volume.
	  * @param buf - Pointer to the PCM data to output.
	  *
	  * @return 0 on success, an error if less than 0.
	  */
	int sceAudioOutputPannedBlocking(int channel, int leftvol, int rightvol, void* buf) {
		// Invalid channel.
		if (!validChannelIndex(channel)) {
			debug (DEBUG_AUDIO) {
				writefln("  sceAudioOutputPannedBlocking.invalidChannel!");
			}
			return -1;
		}

		auto cchannel = channels[channel];
		
		auto samples = (cast(float*)buf)[0..cchannel.samplecount * cchannel.valuesPerSample];
		//writefln("  samplecount: %d", cchannel.samplecount);
		//writefln("    %s", (cast(ubyte*)buf)[0..cchannel.samplecount*4]);
		/*
		foreach (sample; (cast(ushort*)buf)[0..cchannel.samplecount * cchannel.valuesPerSample]) {
			writefln("    %d", sample);
		}
		*/
		audio.writeWait(samples);

		unimplemented();
		return 0;
	}

	/**
	 * Output audio of the specified channel (blocking)
	 *
	 * @param channel - The channel number.
	 *
	 * @param vol - The volume.
	 *
	 * @param buf - Pointer to the PCM data to output.
	 *
	 * @return 0 on success, an error if less than 0.
	 */
	int sceAudioOutputBlocking(int channel, int vol, void* buf) {
		unimplemented();
		return -1;
	}

	/**
	  * Allocate and initialize a hardware output channel.
	  *
	  * @param channel - Use a value between 0 - 7 to reserve a specific channel.
	  *                   Pass PSP_AUDIO_NEXT_CHANNEL to get the first available channel.
	  * @param samplecount - The number of samples that can be output on the channel per
	  *                      output call.  It must be a value between ::PSP_AUDIO_SAMPLE_MIN
	  *                      and ::PSP_AUDIO_SAMPLE_MAX, and it must be aligned to 64 bytes
	  *                      (use the ::PSP_AUDIO_SAMPLE_ALIGN macro to align it).
	  * @param format - The output format to use for the channel.  One of ::PspAudioFormats.
	  *
	  * @return The channel number on success, an error code if less than 0.
	  */
	int sceAudioChReserve(int channel, int samplecount, PspAudioFormats format) {
		// Select a free channel.
		if (channel == PSP_AUDIO_NEXT_CHANNEL) channel = freeChannelIndex;

		// Invalid channel.
		if (!validChannelIndex(channel)) return -1;

		// Sets the information of the channel.
		channels[channel] = Channel(true, samplecount, format);

		// Returns the channel.
		return channel;
	}

	/**
	  * Release a hardware output channel.
	  *
	  * @param channel - The channel to release.
	  *
	  * @return 0 on success, an error if less than 0.
	  */
	int sceAudioChRelease(int channel) {
		if (!validChannelIndex(channel)) return -1;
		channels[channel].reserved = false;
		return 0;
	}
}

class sceAudio : sceAudio_driver {
}

/** The maximum output volume. */
const int PSP_AUDIO_VOLUME_MAX = 0x8000;

/** Used to request the next available hardware channel. */
const int PSP_AUDIO_NEXT_CHANNEL = -1;

struct pspAudioInputParams {
	/** Unknown. Pass 0 */
	int unknown1;
	int gain;
	/** Unknown. Pass 0 */
	int unknown2;
	/** Unknown. Pass 0 */
	int unknown3;
	/** Unknown. Pass 0 */
	int unknown4;
	/** Unknown. Pass 0 */
	int unknown5;
}

/** The minimum number of samples that can be allocated to a channel. */
const int PSP_AUDIO_SAMPLE_MIN = 64;

/** The maximum number of samples that can be allocated to a channel. */
const int PSP_AUDIO_SAMPLE_MAX = 65472;

/** Make the given sample count a multiple of 64. */
Type PSP_AUDIO_SAMPLE_ALIGN(Type)(Type s) { return (s + 63) & ~63; }

static this() {
	mixin(Module.registerModule("sceAudio_driver"));
	mixin(Module.registerModule("sceAudio"));
}
