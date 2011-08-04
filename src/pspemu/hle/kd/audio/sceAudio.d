module pspemu.hle.kd.audio.sceAudio; // kd/audio.prx (sceAudio_Driver)

import pspemu.hle.ModuleNative;

import std.c.windows.windows;

import core.thread;

import pspemu.core.audio.Audio;

import pspemu.hle.Module;
import pspemu.hle.ModuleNative;
import pspemu.hle.kd.audio.Types;

import pspemu.utils.Logger;

class sceAudio_driver : ModuleNative {
	struct Channel {
		int index;
		bool reserved = false;
		int  samplecount;
		PspAudioFormats format = PspAudioFormats.PSP_AUDIO_FORMAT_STEREO;
		int  freq = 44100;
		int leftvol = PSP_AUDIO_VOLUME_MAX, rightvol = PSP_AUDIO_VOLUME_MAX;

		int numchannels() { return (format == PspAudioFormats.PSP_AUDIO_FORMAT_MONO) ? 1 : 2; }
		int dataCount() { return samplecount * numchannels; }
	}
	
	Channel channels[8]; // PSP_AUDIO_CHANNEL_MAX
	Channel srcChannel;
	int numberOfChannels;
	Audio audio;

	void initNids() {
		mixin(registerd!(0x13F592BC, sceAudioOutputPannedBlocking));
		mixin(registerd!(0x5EC81C55, sceAudioChReserve));
		mixin(registerd!(0x6FC46853, sceAudioChRelease));
		mixin(registerd!(0x8C1009B2, sceAudioOutput));
		mixin(registerd!(0x136CAF51, sceAudioOutputBlocking));
		mixin(registerd!(0xE2D56B2D, sceAudioOutputPanned));
		mixin(registerd!(0xE9D97901, sceAudioGetChannelRestLen));
		mixin(registerd!(0xCB2E439E, sceAudioSetChannelDataLen));
		mixin(registerd!(0x95FD0C2D, sceAudioChangeChannelConfig));
		mixin(registerd!(0xB7E1D8E7, sceAudioChangeChannelVolume));

		mixin(registerd!(0x01562BA3, sceAudioOutput2Reserve));
		mixin(registerd!(0x2D53F36E, sceAudioOutput2OutputBlocking));
		mixin(registerd!(0x43196845, sceAudioOutput2Release));
		mixin(registerd!(0xB011922F, sceAudioGetChannelRestLength));

		mixin(registerd!(0x086E5895, sceAudioInputBlocking));
		mixin(registerd!(0x7DE61688, sceAudioInputInit));
		
		mixin(registerd!(0x38553111, sceAudioSRCChReserve));
		mixin(registerd!(0x5C37C0AE, sceAudioSRCChRelease));
		mixin(registerd!(0xE0727056, sceAudioSRCOutputBlocking));
	}

	void initModule() {
		audio = new Audio;
		currentEmulatorState.runningState.onStop += delegate(...) {
			audio.stop();
		};
		
		foreach (n, ref channel; channels) channel.index = n;
		srcChannel.index = 8;
	}

	void shutdownModule() {
		audio.stop();
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

	static float volumef(int shortval) { return (cast(float)shortval) / cast(float)PSP_AUDIO_VOLUME_MAX; }
	
	int Output2Channel;

	/**
	 * Reserve the audio output and set the output sample count
	 *
	 * @param samplecount - The number of samples to output in one output call (min 17, max 4111).
	 *
	 * @return 0 on success, an error if less than 0.
	 */
	int sceAudioOutput2Reserve(int samplecount) {
		Output2Channel = sceAudioChReserve(PSP_AUDIO_NEXT_CHANNEL, samplecount, PspAudioFormats.PSP_AUDIO_FORMAT_STEREO);
		//unimplemented_notice();
		return 0;
	}

	/**
	 * Output audio (blocking)
	 *
	 * @param vol - The volume. A value between 0 and PSP_AUDIO_VOLUME_MAX.
	 * @param buf - Pointer to the PCM data.
	 *
	 * @return 0 on success, an error if less than 0.
	 */
	int sceAudioOutput2OutputBlocking(int vol, void *buf) {
		unimplemented_notice();
		sceAudioOutputBlocking(Output2Channel, vol, buf);
		return 0;
	}

	/**
	 * Release the audio output
	 *
	 * @return 0 on success, an error if less than 0.
	 */
	int sceAudioOutput2Release() {
		unimplemented_notice();
		sceAudioChRelease(Output2Channel);
		return 0;
	}

	/**
	 * Get count of unplayed samples remaining
	 *
	 * @param channel - The channel number.
	 *
	 * @return Number of samples to be played, an error if less than 0.
	 */
	int sceAudioGetChannelRestLength(int channel) {
		// Invalid channel.
		if (!validChannelIndex(channel)) {
			logWarning("sceAudioOutputPannedBlocking.invalidChannel!");
			return -1;
		}
		
		return audio.channels[channel].samplesLeft();
	}

	int _sceAudioOutputPannedBlocking(int channel, int leftvol, int rightvol, void *buf, bool blocking) {
		try {
			// Invalid channel.
			if (!validChannelIndex(channel)) {
				logWarning("sceAudioOutputPannedBlocking.invalidChannel!");
				return -1;
			}

			Channel cchannel = channels[channel];

			logTrace(
				"sceAudioOutputPannedBlocking(channel=%d, channel.format=%s, channel.samplecount=%d, channel.freq=%d, leftvol=%d, rightvol=%d, buf=%08X, buf_length=%d)",
				channel, to!string(cchannel.format), cchannel.samplecount, cchannel.freq, leftvol, rightvol, cast(uint)cast(void *)buf, cchannel.dataCount
			);
			
			// Invalid source.
			if (buf is null) {
				logError("--------------------------------------------------------------------------");
				logWarning("sceAudioOutputPannedBlocking.invalidBuffer(Channel=%d) == NULL", channel);
				logError("--------------------------------------------------------------------------");
				return 0;
			}
			
			//float toFloat(short sample) { return cast(float)sample / cast(float)(0x8000 - 1); }
			
			auto samples_short = (cast(short*)buf)[0..cchannel.dataCount];
			//bool error = false;
			
			auto writeDelegate = delegate() {
				try {
					audio.writeWait(channel, cchannel.numchannels, samples_short, volumef(leftvol), volumef(rightvol));
				} catch (Throwable o) {
					Logger.log(Logger.Level.ERROR, "sceAudio_driver", "_sceAudioOutputPannedBlocking: %s", o);
				}
			};
	
			if (blocking) {
				currentThreadState().waitingBlock("_sceAudioOutputPannedBlocking", writeDelegate);
			} else {
				Thread audioNonBlockingThread = new Thread(writeDelegate);
				audioNonBlockingThread.name = "audioNonBlockingThread";
				audioNonBlockingThread.start();
			}
			
			return 0;
		} catch (Throwable o) {
			writefln("_sceAudioOutputPannedBlocking.ERROR: %s", o);
			return -1;
		}
	}

	/**
	  * Output panned audio of the specified channel (blocking)
	  *
	  * @param channel  - The channel number.
	  * @param leftvol  - The left volume. A value between 0 and PSP_AUDIO_VOLUME_MAX.
	  * @param rightvol - The right volume. A value between 0 and PSP_AUDIO_VOLUME_MAX.
	  * @param buf      - Pointer to the PCM data to output.
	  *
	  * @return 0 on success, an error if less than 0.
	  */
	int sceAudioOutputPannedBlocking(int channel, int leftvol, int rightvol, void* buf) {
		return _sceAudioOutputPannedBlocking(channel, leftvol, rightvol, buf, /*blocking = */ true);
	}
	
	/**
	 * Output panned audio of the specified channel
	 *
	 * @param channel  - The channel number.
	 * @param leftvol  - The left volume. A value between 0 and PSP_AUDIO_VOLUME_MAX.
	 * @param rightvol - The right volume. A value between 0 and PSP_AUDIO_VOLUME_MAX.
	 * @param buf      - Pointer to the PCM data to output.
	 *
	 * @return 0 on success, an error if less than 0.
	 */
	int sceAudioOutputPanned(int channel, int leftvol, int rightvol, void *buf) {
		return _sceAudioOutputPannedBlocking(channel, leftvol, rightvol, buf, /*blocking = */ false);
	}
	
	/**
	 * Output audio of the specified channel
	 *
	 * @param channel - The channel number.
	 * @param vol     - The volume. A value between 0 and PSP_AUDIO_VOLUME_MAX.
	 * @param buf     - Pointer to the PCM data to output.
	 *
	 * @return 0 on success, an error if less than 0.
	 */
	int sceAudioOutput(int channel, int vol, void* buf) {
		return sceAudioOutputPanned(channel, vol, vol, buf);
	}

	/**
	 * Get count of unplayed samples remaining
	 *
	 * @param channel - The channel number.
	 *
	 * @return Number of samples to be played, an error if less than 0.
	 */
	int sceAudioGetChannelRestLen(int channel) {
		unimplemented();
		return -1;
	}

	/**
	 * Change the output sample count, after it's already been reserved
	 *
	 * @param channel     - The channel number.
	 * @param samplecount - The number of samples to output in one output call.
	 *
	 * @return 0 on success, an error if less than 0.
	 */
	int sceAudioSetChannelDataLen(int channel, int samplecount) {
		//logWarning("Not implemented sceAudioSetChannelDataLen(%d, %d)", channel, samplecount);
		if (samplecount < 0) return -1;
		channels[channel].samplecount = samplecount;
		return 0;
	}

	/**
	 * Change the format of a channel
	 *
	 * @param channel - The channel number.
	 * @param format  - One of ::PspAudioFormats
	 *
	 * @return 0 on success, an error if less than 0.
	 */
	int sceAudioChangeChannelConfig(int channel, PspAudioFormats format) {
		channels[channel].format = format;
		return 0;
	}
	
	/**
	 * Output audio of the specified channel (blocking)
	 *
	 * @param channel - The channel number.
	 * @param vol     - The volume.
	 * @param buf     - Pointer to the PCM data to output.
	 *
	 * @return 0 on success, an error if less than 0.
	 */
	int sceAudioOutputBlocking(int channel, int vol, void* buf) {
		return sceAudioOutputPannedBlocking(channel, vol, vol, buf);
	}

	/**
	  * Allocate and initialize a hardware output channel.
	  *
	  * @param channel     - Use a value between 0 - 7 to reserve a specific channel.
	  *                      Pass PSP_AUDIO_NEXT_CHANNEL to get the first available channel.
	  * @param samplecount - The number of samples that can be output on the channel per
	  *                      output call.  It must be a value between ::PSP_AUDIO_SAMPLE_MIN
	  *                      and ::PSP_AUDIO_SAMPLE_MAX, and it must be aligned to 64 bytes
	  *                      (use the ::PSP_AUDIO_SAMPLE_ALIGN macro to align it).
	  * @param format      - The output format to use for the channel.  One of ::PspAudioFormats.
	  *
	  * @return The channel number on success, an error code if less than 0.
	  */
	int sceAudioChReserve(int channel, int samplecount, PspAudioFormats format) {
		// Select a free channel.
		if (channel == PSP_AUDIO_NEXT_CHANNEL) channel = freeChannelIndex;

		// Invalid channel.
		if (!validChannelIndex(channel)) return -1;

		// Sets the information of the channel.
		channels[channel].reserved = true;
		channels[channel].samplecount = samplecount;
		channels[channel].format = format;
		
		logInfo("sceAudioChReserve(channel=%d, samplecount=%d, format=%d)", channel, samplecount, format);

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

	/**
	 * Perform audio input (blocking)
	 *
	 * @param samplecount - Number of samples.
	 * @param freq        - Either 44100, 22050 or 11025.
	 * @param buf         - Pointer to where the audio data will be stored.
	 *
	 * @return 0 on success, an error if less than 0.
	 */
	int sceAudioInputBlocking(int samplecount, int freq, void* buf) {
		unimplemented();
		return -1;
	}

	/**
	 * Init audio input
	 *
	 * @param unknown1 - Unknown. Pass 0.
	 * @param gain - Gain.
	 * @param unknown2 - Unknown. Pass 0.
	 *
	 * @return 0 on success, an error if less than 0.
	 */
	int sceAudioInputInit(int unknown1, int gain, int unknown2) {
		unimplemented();
		return -1;
	}


	/**
	  * Change the volume of a channel
	  *
	  * @param channel  - The channel number.
	  * @param leftvol  - The left volume.
	  * @param rightvol - The right volume.
	  *
	  * @return 0 on success, an error if less than 0.
	  */
	int sceAudioChangeChannelVolume(int channel, int leftvol, int rightvol) {
		logWarning("Partially implemented sceAudioChangeChannelVolume(%d, %d, %s)", channel, leftvol, rightvol);
		this.channels[channel].leftvol  = leftvol;
		this.channels[channel].rightvol = rightvol;
		return 0;
	}

	/**
	  * Reserve the audio output
	  *
	  * @param samplecount - The number of samples to output in one output call (min 17, max 4111).
	  * @param freq        - The frequency. One of 48000, 44100, 32000, 24000, 22050, 16000, 12000, 11050, 8000.
	  * @param channels    - Number of channels. Pass 2 (stereo).
	  *
	  * @return 0 on success, an error if less than 0.
	  */
	int sceAudioSRCChReserve(int samplecount, int freq, int channels) {
		logInfo("Partially implemented: sceAudioSRCChReserve(%d, %d, %s:%d)", samplecount, freq, to!string(format), format);
		
		srcChannel.samplecount = samplecount;
		srcChannel.freq = freq;
		srcChannel.format = (channels == 1) ? PspAudioFormats.PSP_AUDIO_FORMAT_MONO : PspAudioFormats.PSP_AUDIO_FORMAT_STEREO;
		srcChannel.reserved = true;
		
		return 0;
	}

	/**
	  * Release the audio output
	  *
	  * @return 0 on success, an error if less than 0.
	  */
	int sceAudioSRCChRelease() {
		if (!srcChannel.reserved) return -1;
		srcChannel.reserved = false;
		return 0;
	}
	
	/**
	  * Output audio
	  *
	  * @param vol - The volume.
	  * @param buf - Pointer to the PCM data to output.
	  *
	  * @return 0 on success, an error if less than 0.
	  */
	int sceAudioSRCOutputBlocking(int vol, void *buf) {
		auto writeDelegate = delegate() {
			try {
				audio.writeWait(srcChannel.index, srcChannel.numchannels, (cast(short*)buf)[0..srcChannel.samplecount * srcChannel.numchannels], volumef(vol), volumef(vol));
			} catch (Throwable o) {
				Logger.log(Logger.Level.ERROR, "sceAudio_driver", "_sceAudioOutputPannedBlocking: %s", o);
			}
		};

		currentThreadState().waitingBlock("_sceAudioOutputPannedBlocking", writeDelegate);

		return 0;
	}

}

class sceAudio : sceAudio_driver {
}

static this() {
	mixin(ModuleNative.registerModule("sceAudio"));
	mixin(ModuleNative.registerModule("sceAudio_driver"));
}
