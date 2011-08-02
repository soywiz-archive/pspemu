module pspemu.hle.kd.sc_sascore.sceSasCore;

import pspemu.hle.ModuleNative;
import pspemu.hle.HleEmulatorState;
import pspemu.hle.kd.audio.Types;

import pspemu.utils.BitUtils;

import pspemu.formats.audio.Vag;

import std.c.stdlib;

enum WaveformEffectType {
    PSP_SAS_EFFECT_TYPE_OFF   = -1,
    PSP_SAS_EFFECT_TYPE_ROOM  =  0,
    PSP_SAS_EFFECT_TYPE_UNK1  =  1,
    PSP_SAS_EFFECT_TYPE_UNK2  =  2,
    PSP_SAS_EFFECT_TYPE_UNK3  =  3,
    PSP_SAS_EFFECT_TYPE_HALL  =  4,
    PSP_SAS_EFFECT_TYPE_SPACE =  5,
    PSP_SAS_EFFECT_TYPE_ECHO  =  6,
    PSP_SAS_EFFECT_TYPE_DELAY =  7,
    PSP_SAS_EFFECT_TYPE_PIPE  =  8,
}

enum AdsrFlags {
	hasAttack  = 0b_0001,
	hasDecay   = 0b_0010,
	hasSustain = 0b_0100,
	hasRelease = 0b_1000,
}

const int PSP_SAS_VOICES_MAX = 32;
const int PSP_SAS_GRAIN_SAMPLES = 256;
const int PSP_SAS_VOL_MAX = 0x1000;
const int PSP_SAS_LOOP_MODE_OFF = 0;
const int PSP_SAS_LOOP_MODE_ON = 1;
const int PSP_SAS_PITCH_MIN = 0x1;
const int PSP_SAS_PITCH_BASE = 0x1000;
const int PSP_SAS_PITCH_MAX = 0x4000;
const int PSP_SAS_NOISE_FREQ_MAX = 0x3F;
const int PSP_SAS_ENVELOPE_HEIGHT_MAX = 0x40000000;
const int PSP_SAS_ENVELOPE_FREQ_MAX = 0x7FFFFFFF;
const int PSP_SAS_ADSR_ATTACK = 1;
const int PSP_SAS_ADSR_DECAY = 2;
const int PSP_SAS_ADSR_SUSTAIN = 4;
const int PSP_SAS_ADSR_RELEASE = 8;
    
enum OutputMode : uint {
    PSP_SAS_OUTPUTMODE_STEREO = 0,
    PSP_SAS_OUTPUTMODE_MULTICHANNEL = 1,
}

enum AdsrCurveMode : uint {
	PSP_SAS_ADSR_CURVE_MODE_LINEAR_INCREASE = 0,
	PSP_SAS_ADSR_CURVE_MODE_LINEAR_DECREASE = 1,
	PSP_SAS_ADSR_CURVE_MODE_LINEAR_BENT = 2,
	PSP_SAS_ADSR_CURVE_MODE_EXPONENT_REV = 3,
	PSP_SAS_ADSR_CURVE_MODE_EXPONENT = 4,
	PSP_SAS_ADSR_CURVE_MODE_DIRECT = 5,
}


struct SasEnvelope {
    int attackRate;
    int decayRate;
    int sustainRate;
    int releaseRate;
    AdsrCurveMode attackCurveMode;
    AdsrCurveMode decayCurveMode;
    AdsrCurveMode sustainCurveMode;
    AdsrCurveMode releaseCurveMode;
    int sustainLevel;
    int height;
}

struct SasVoice {
	bool on;
	bool playing;
	bool paused;
	VAG  vag;
	
	void setOn(bool set) {
    	on        = set;
    	setPlaying(set);
    }
	
	void setPlaying(bool set) {
    	playing   = set;
    	playOffset = 0;
	}
	
	void onVoiceChanged() {
		if (on && !playing) {
			setPlaying(true);
		}
	}
	
	bool onAndPlaying() {
		return on && playing;
	}
	
	short getSample() {
		if (vag is null) return 0;
		if (playOffset < vag.decodedSamples.length) {
			scope (exit) {
				if (playOffset >= vag.decodedSamples.length) {
					//setPlaying(false);
					setPlaying(loopMode ? true : false);
				}
			}
			return vag.decodedSamples[playOffset++];
		} else{
			setPlaying(false);
			return 0;
		}
	}
	
	int  pitch;
	
	int  playOffset;
	
	int  leftVolume;
	int  rightVolume;
	
	int noiseFreq;

	ubyte[] data;
	int loopMode;
	
	SasEnvelope envelope;

	bool ended() {
		return !playing;
	}
	
	string toString() {
		string s = "";
		s ~= "SasVoice(";
		s ~= std.string.format("on=%d,", on);
		s ~= std.string.format("playing=%d,", playing);
		s ~= std.string.format("pitch=%d,", pitch);
		s ~= std.string.format("playOffset=%d/%d,", playOffset, (vag !is null) ? vag.decodedSamples.length : 0);
		s ~= std.string.format("volumes=%d/%d,", leftVolume, rightVolume);
		s ~= std.string.format("noiseFreq=%d,", noiseFreq);
		s ~= std.string.format("loopMode=%d,", loopMode);
		s ~= std.string.format("envelope=...,");
		s ~= ")";
		return s;
	}
}

struct SasCore {
	int  grainSamples;
	int  maxVoices;
	OutputMode  outputMode;
	int  sampleRate;
	int  leftVol;
	int  rightVol;
	bool waveformEffectIsDry;
	bool waveformEffectIsWet;
	int  waveformEffectLeftVol;
	int  waveformEffectRightVol;
	int  delay;
	int  feedback;
	WaveformEffectType waveformEffectType;
	SasVoice[32] _voices;
	
	SasVoice[] voices() {
		return _voices[0..maxVoices];
	}
}

class sceSasCore : ModuleNative {
	void initNids() {
		mixin(registerd!(0x42778A9F, __sceSasInit));
	    mixin(registerd!(0x019B25EB, __sceSasSetADSR));
	    mixin(registerd!(0x267A6DD2, __sceSasRevParam));
	    mixin(registerd!(0x2C8E6AB3, __sceSasGetPauseFlag));
	    mixin(registerd!(0x33D4AB37, __sceSasRevType));
	    mixin(registerd!(0x440CA7D8, __sceSasSetVolume));
	    mixin(registerd!(0x50A14DFC, __sceSasCoreWithMix));
	    mixin(registerd!(0x5F9529F6, __sceSasSetSL));
	    mixin(registerd!(0x68A46B95, __sceSasGetEndFlag));
	    mixin(registerd!(0x74AE582A, __sceSasGetEnvelopeHeight));
	    mixin(registerd!(0x76F01ACA, __sceSasSetKeyOn));
	    mixin(registerd!(0x787D04D5, __sceSasSetPause));
	    mixin(registerd!(0x99944089, __sceSasSetVoice));
	    mixin(registerd!(0x9EC3676A, __sceSasSetADSRmode));
	    mixin(registerd!(0xA0CF2FA4, __sceSasSetKeyOff));
	    mixin(registerd!(0xA3589D81, __sceSasCore));
	    mixin(registerd!(0xAD84D37F, __sceSasSetPitch));
	    mixin(registerd!(0xB7660A23, __sceSasSetNoise));
	    mixin(registerd!(0xCBCD4F79, __sceSasSetSimpleADSR));
	    mixin(registerd!(0xD5A229C9, __sceSasRevEVOL));
	    mixin(registerd!(0xF983B186, __sceSasRevVON));
	    
	    mixin(registerd!(0xBD11B7C2, __sceSasGetGrain));
	    mixin(registerd!(0xD1E0A01E, __sceSasSetGrain));
	    mixin(registerd!(0xE175EF66, __sceSasGetOutputmode));
	    mixin(registerd!(0xE855BF76, __sceSasSetOutputmode));
	}

	int __sceSasGetGrain(SasCore* sasCore) {
		return sasCore.grainSamples;
	}
	
	int __sceSasSetGrain(SasCore* sasCore, int grain) {
		sasCore.grainSamples = grain;
		return 0;
	}

	OutputMode __sceSasGetOutputmode(SasCore* sasCore) {
		return sasCore.outputMode;
	}

	int __sceSasSetOutputmode(SasCore* sasCore, OutputMode outputMode) {
		sasCore.outputMode = outputMode;
		return 0;
	}

	/**
	 * Initialized a sasCore structure.
	 * Note: PSP can only handle one at a time.
	 *
	 * @example __sceSasInit(&sasCore, PSP_SAS_GRAIN_SAMPLES, PSP_SAS_VOICES_MAX, OutputMode.PSP_SAS_OUTPUTMODE_STEREO, 44100);
	 *
	 * @param   sasCore       Pointer to a SasCore structure that will contain information.
	 * @param   grainSamples  Number of grainSamples
	 * @param   maxVoices     Max number of voices
	 * @param   outMode       Out Mode
	 * @param   sampleRate    Sample Rate
	 *
	 * @return  0 on success
	 */
	uint __sceSasInit(SasCore* sasCore, int grainSamples, int maxVoices, OutputMode outputMode, int sampleRate) {
		try {
			//if (grainSamples > PSP_SAS_GRAIN_SAMPLES) throw(new Exception("Invalid grainSamples"));
			if (maxVoices    > PSP_SAS_VOICES_MAX   ) throw(new Exception("Invalid maxVoices"));
			
			//logWarning("Not implemented __sceSasInit(%08X, %d, %d, %d, %d)", currentMemory().getPointerReverse(sasCore), grainSamples, maxVoices, outMode, sampleRate);
	
			sasCore.grainSamples = grainSamples;
			sasCore.maxVoices    = maxVoices;
			sasCore.outputMode   = outputMode;
			sasCore.sampleRate   = sampleRate;
			
			if (sampleRate != 44100 || outputMode != OutputMode.PSP_SAS_OUTPUTMODE_STEREO) {
				throw(new Exception(std.string.format("Unsupported __sceSasInit outputMode(%d)/sampleRate(%d)", outputMode, sampleRate)));
			}
			//*sasCorePtr = uniqueIdFactory.add!SasCore(sasCore);
			
			return 0;
		} catch (Exception e) {
			logError("Error: %s", e);
			return 0;
		}
	}

	/**
	 * Return a bitfield indicating the end of the voices.
	 *
	 * @param  sasCore  Core
	 *
	 * @return  A set of flags indiciating the end of the voices.
	 */
    uint __sceSasGetEndFlag(SasCore* sasCore) {
		uint endFlags;
		foreach (uint index, ref voice; sasCore.voices) {
			if (voice.ended) endFlags |= (1 << index); 
		}
		//logInfo("__sceSasGetEndFlag::%032b", endFlags);
		return endFlags;
    }

	/**
	 * Sets the WaveformEffectType to the specified sasCore.
	 *
	 * @param  sasCore             Core
	 * @param  waveformEffectType  Effect
	 *
	 * @return 0 on success.
	 */
    uint __sceSasRevType(SasCore* sasCore, WaveformEffectType waveformEffectType) {
    	sasCore.waveformEffectType = waveformEffectType;
    	return 0;
    }

	/**
	 * Sets the waveformEffectIsDry and waveformEffectIsWet to the specified sasCore.
	 *
	 * @param  sasCore              Core
	 * @param  waveformEffectIsDry  waveformEffectIsDry
	 * @param  waveformEffectIsWet  waveformEffectIsWet
	 *
	 * @return 0 on success.
	 */
    uint __sceSasRevVON(SasCore* sasCore, bool waveformEffectIsDry, bool waveformEffectIsWet) {
    	sasCore.waveformEffectIsDry = waveformEffectIsDry;
    	sasCore.waveformEffectIsWet = waveformEffectIsWet;
    	return 0;
    }

	/**
	 * Sets the effect left and right volumes for the specified sasCore.
	 *
	 * @param  sasCore     Core
	 * @param  leftVol     Left volume
	 * @param  rightVol    Right volume
	 *
	 * @return 0 on success
	 */
    uint __sceSasRevEVOL(SasCore* sasCore, int leftVol, int rightVol) {
    	sasCore.waveformEffectLeftVol  = leftVol;
    	sasCore.waveformEffectRightVol = rightVol;
    	return 0;
    }

	/**
	 * Sets the Voice (VAG pointer).
	 *
	 * 4-bit ADPCM, mono sound format.
	 * 4-bit compressed sound format used by PlayStation and PlayStation Portable games;
	 * compressed using ADPCM (Adaptive Differential Pulse Code Modulation) encoding.
	 *
	 * @param  sasCore   Core
	 * @param  voice     Voice
	 * @param  vagArg    Pointer to the wave data
	 * @param  size      Size in bytes?? (to confirm)
	 * @param  loopmode  Number of times the voice should play
	 */
    int __sceSasSetVoice(SasCore* sasCore, int voice, ubyte* vagAddr, int size, int loopmode) {
    	auto voicePtr = &sasCore.voices[voice];
    	
    	try {
	    	voicePtr.data = vagAddr[0..size];
	    	voicePtr.loopMode = loopmode;
	    	
	    	voicePtr.vag = new VAG;
	    	voicePtr.vag.load(vagAddr[0..size]);
	    	//voicePtr.vag.load(vagAddr[0..size].dup);
	    	voicePtr.onVoiceChanged();
	    	
	    	//std.c.stdlib.exit(-1);
	    } catch (Throwable o) {
	    	logError("__sceSasSetVoice error: %s", o);
	    }
    	
		return 0;
    }

	/**
	 * Sets the pitch for a sasCore.voice.
	 *
	 * @param  sasCore  SasCore
	 * @param  voice    Voice
	 * @param  pitch    Pitch to set. A value between 1 and 16384. The default value is 4096.
	 *
	 * @return 0 on success
	 */
    int __sceSasSetPitch(SasCore* sasCore, int voice, int pitch) {
    	auto voicePtr = &sasCore.voices[voice];
    	
    	voicePtr.pitch = pitch;
    	voicePtr.onVoiceChanged();
		return 0;
    }

	/**
	 * Sets the stereo volumes for a sasCore.voice.
	 *
	 * @param  sasCore     SasCore
	 * @param  voice       Voice
	 * @param  leftVolume  Left  Volume 0-0x1000
	 * @param  rightVolume Right Volume 0-0x1000
	 *
	 * @return 0 on success.
	 */
    int __sceSasSetVolume(SasCore* sasCore, int voice, int leftVolume, int rightVolume) {
    	SasVoice* voicePtr = &sasCore.voices[voice];
    	
    	voicePtr.leftVolume  = leftVolume;
    	voicePtr.rightVolume = rightVolume;
        
    	return 0;
    }
	

	int __sceSasRevParam(SasCore* sasCore, int delay, int feedback) {
		sasCore.delay    = delay;
		sasCore.feedback = feedback;
		return 0;
	}

    int __sceSasSetSL(SasCore* sasCore, int voice, int sustainLevel) {
    	SasVoice* voicePtr = &sasCore.voices[voice];
    	
    	voicePtr.envelope.sustainLevel = sustainLevel;

    	return 0;
    }

    int __sceSasGetEnvelopeHeight(SasCore* sasCore, int voice) {
    	SasVoice* voicePtr = &sasCore.voices[voice];
    	return voicePtr.envelope.height;
    }

	/**
	 * Pauses a set of voice channels for that sasCore.
	 *
	 * @param  sasCore     SasCore
	 * @param  voice_bits  Voice Bit Set
	 *
	 * @return 0 on success.
	 */
    int __sceSasSetPause(SasCore* sasCore, uint voice_bits) {
    	foreach (uint index, SasVoice voice; sasCore.voices) {
    		if ((voice_bits >> index) & 1) {
    			voice.paused = true;
    		}
    	}

    	return 0;
    }

    int __sceSasGetPauseFlag(SasCore* sasCore) {
    	uint flags;
    	foreach (uint index, SasVoice voice; sasCore.voices) {
    		if (voice.paused) {
    			flags |= (1 << index);
    		}
    	}
    	return flags;
    }
    
	/**
	 * Sets the ADSR (Attack Decay Sustain Release) for a sasCore.voice.
	 *
	 * @param  sasCore  SasCore
	 * @param  voice    Voice
	 * @param  flags    Bitfield to set each envelope on or off.
	 * @param  attack   ADSR Envelope's attack type.
	 * @param  decay    ADSR Envelope's decay type.
	 * @param  sustain  ADSR Envelope's sustain type.
	 * @param  release  ADSR Envelope's release type.
	 *
	 * @return 0 on success.
	 */
	int __sceSasSetADSR(SasCore* sasCore, int voice, AdsrFlags flags, uint attackRate, uint decayRate, uint sustainRate, uint releaseRate) {
		auto voicePtr = &sasCore.voices[voice];
		
		if (flags & AdsrFlags.hasAttack ) voicePtr.envelope.attackRate  = attackRate;
		if (flags & AdsrFlags.hasDecay  ) voicePtr.envelope.decayRate   = decayRate;
		if (flags & AdsrFlags.hasSustain) voicePtr.envelope.sustainRate = sustainRate;
		if (flags & AdsrFlags.hasRelease) voicePtr.envelope.releaseRate = releaseRate;

		return 0;
	}
	
    int __sceSasSetSimpleADSR(SasCore* sasCore, int voice, uint env1Bitfield, uint env2Bitfield) {
    	auto voicePtr = &sasCore.voices[voice];
    	
    	voicePtr.envelope.sustainLevel   = BitUtils.extract!(uint,  0, 4)(env1Bitfield);
    	voicePtr.envelope.decayRate      = BitUtils.extract!(uint,  4, 4)(env1Bitfield);
    	voicePtr.envelope.attackRate     = BitUtils.extract!(uint,  8, 7)(env1Bitfield);
    	voicePtr.envelope.decayCurveMode = cast(AdsrCurveMode)BitUtils.extract!(uint, 15, 2)(env1Bitfield);

    	voicePtr.envelope.releaseRate      = BitUtils.extract!(uint,  0, 5)(env1Bitfield);
    	voicePtr.envelope.releaseCurveMode = cast(AdsrCurveMode)BitUtils.extract!(uint,  5, 1)(env1Bitfield);
    	voicePtr.envelope.sustainRate      = BitUtils.extract!(uint,  6, 7)(env1Bitfield);
    	voicePtr.envelope.sustainCurveMode = cast(AdsrCurveMode)BitUtils.extract!(uint, 13, 3)(env1Bitfield);

    	return 0;
    }
    
    int __sceSasSetADSRmode(SasCore* sasCore, int voice, AdsrFlags flags, AdsrCurveMode attackCurveMode, AdsrCurveMode decayCurveMode, AdsrCurveMode sustainCurveMode, AdsrCurveMode releaseCurveMode) {
		auto voicePtr = &sasCore.voices[voice];
		
		if (flags & AdsrFlags.hasAttack ) voicePtr.envelope.attackCurveMode  = attackCurveMode;
		if (flags & AdsrFlags.hasDecay  ) voicePtr.envelope.decayCurveMode   = decayCurveMode;
		if (flags & AdsrFlags.hasSustain) voicePtr.envelope.sustainCurveMode = sustainCurveMode;
		if (flags & AdsrFlags.hasRelease) voicePtr.envelope.releaseCurveMode = releaseCurveMode;

		return 0;
    	
    	unimplemented_notice();
    	return 0;
    }

    int __sceSasSetKeyOn(SasCore* sasCore, int voice) {
    	SasVoice* voicePtr = &sasCore.voices[voice];
    	voicePtr.setOn(true);
    	return 0;
    }

    int __sceSasSetKeyOff(SasCore* sasCore, int voice) {
    	SasVoice* voicePtr = &sasCore.voices[voice];
    	voicePtr.setOn(false);
    	return 0;
    }

    int __sceSasSetNoise(SasCore* sasCore, int voice, int noiseFreq) {
    	SasVoice* voicePtr = &sasCore.voices[voice];
    	voicePtr.noiseFreq = noiseFreq;
    	voicePtr.onVoiceChanged();
    	return 0;
    }

	int __sceSasCoreWithMix(SasCore* sasCore, void* sasInOut, int leftVol, int rightVol) {
		unimplemented_notice();
		return 0;
	}
	
	/*
	static void audioConvert(short[] inSamples, int inChannels, int inSampleRate, short[] outSamples, int outChannels, int outSampleRate) {
		
	}
	*/
	
	static void audioConvert_Mono22050_Stereo44100(short[] inSamples, short[] outSamples) {
		int m = 0;
		foreach (n, inSample; inSamples) {
			outSamples[m + 0] = inSample;
			outSamples[m + 2] = inSample;
			m += 4;
		}
		for (int n = 1; n < outSamples.length - 1; n += 4) {
			short sample = cast(short)((cast(int)outSamples[n - 1] + cast(int)outSamples[n + 1]) / 2);
			outSamples[n + 0] = sample;
			outSamples[n + 2] = sample; 
		}
	}
	
	uint __sceSasCore(SasCore* sasCore, void* sasOut) {
		//writefln("[1]");
		int[] mixedSamples = new int[sasCore.grainSamples * 2];
		scope short[] outputStereo44100 = (cast(short *)sasOut)[0..sasCore.grainSamples * 2];
		scope int[]   tempMixer         = new int  [outputStereo44100.length / 4]; 
		scope short[] tempMono22050     = new short[outputStereo44100.length / 4];
		int divideCount;
		tempMixer[] = 0;
		//writefln("[2]");
		
		try {
			foreach (index, ref SasVoice voice; sasCore.voices) {
				if (voice.on) {
					//logTrace("SasCore:: Voice(%d):%s", index, voice.toString);
				}
				if (voice.onAndPlaying) {
					foreach (ref sample; tempMixer) sample = voice.getSample; 
					divideCount++;
				}
			}
		} catch (Throwable o) {
			writefln("Error! : %s", o);
		}
		
		//writefln("[3]");
		
		if (divideCount == 0) {
			outputStereo44100[] = 0;
		} else {
			foreach (n, ref outSample; tempMixer) tempMono22050[n] = cast(short)(outSample / divideCount);
		}
		
		audioConvert_Mono22050_Stereo44100(tempMono22050, outputStereo44100);
		
		//writefln("[4]");
		
		//output[] = cast(short)(outputMix[] / divideCount);
		
		//writefln("%s", output);

		return 0;
    }
}

static this() {
	mixin(ModuleNative.registerModule("sceSasCore"));
}