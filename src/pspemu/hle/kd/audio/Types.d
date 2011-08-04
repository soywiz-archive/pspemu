module pspemu.hle.kd.audio.Types;

public import pspemu.hle.kd.Types;

enum PspAudioFormats : uint {
	/** Channel is set to stereo output. */
	PSP_AUDIO_FORMAT_STEREO = 0,
	/** Channel is set to mono output. */
	PSP_AUDIO_FORMAT_MONO   = 0x10
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

