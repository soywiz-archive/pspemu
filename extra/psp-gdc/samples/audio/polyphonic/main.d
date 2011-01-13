/*
 * PSP Software Development Kit - http://www.pspdev.org
 * -----------------------------------------------------------------------
 * Licensed under the BSD license, see LICENSE in PSPSDK root for details.
 *
 * main.c - Basic audio sample.
 *
 * Copyright (c) 2005 Frank Buss <fb@frank-buss.de> (aka Shine)
 *
 * $Id: main.c 1147 2005-10-12 15:52:52Z mrbrown $
 */

import pspsdk.all;

version (BUILD_INFO) {
	pragma(MODULE_NAME, "POLYPHONIC");
	pragma(PSP_EBOOT_TITLE, "Polyphonic");
	pragma(PSP_MAIN_THREAD_ATTR, THREAD_ATTR_USER | THREAD_ATTR_VFPU);
	pragma(PSP_FW_VERSION, 150);
}

extern (C) {
	int  pspAudioInit();
	void pspAudioEndPre();
	void pspAudioEnd();
}

static const int SAMPLE_COUNT = 0x10000;
static const int SAMPLE_RATE = 44100;
static const int OCTAVE_COUNT = 6;

float sample[SAMPLE_COUNT];

float octaves[OCTAVE_COUNT][12];

struct Note {
	int note;
	int octave;
	int duration;
	
	char[] toString() {
		return std.string.format("Note(%d, %d, %d)", note, octave, duration);
	}
}

struct ChannelState {
	Note  currentNote;
	int   noteIndex;
	int   currentTime;
	float currentsampleIndex;
	float currentsampleIncrement;
}

ChannelState channelStates[3];

// "S" means "#"
static const int NOTE_END   = -2;
static const int NOTE_PAUSE = -1;
static const int NOTE_C     =  0;
static const int NOTE_CS    =  1;
static const int NOTE_D     =  2;
static const int NOTE_DS    =  3;
static const int NOTE_E     =  4;
static const int NOTE_F     =  5;
static const int NOTE_FS    =  6;
static const int NOTE_G     =  7;
static const int NOTE_GS    =  8;
static const int NOTE_A     =  9;
static const int NOTE_AS    =  10;
static const int NOTE_B     =  11;

Note EIGHT_NOTE(int note, int octave, int duration) {
	Note n;
	n.note = note;
	n.octave = octave;
	n.duration = SAMPLE_RATE * duration / 8;
	return n;
}

Note channel0[] = [
	EIGHT_NOTE(NOTE_D, 4, 7),
	EIGHT_NOTE(NOTE_E, 4, 1),
	EIGHT_NOTE(NOTE_F, 4, 1),
	EIGHT_NOTE(NOTE_E, 4, 1),
	EIGHT_NOTE(NOTE_F, 4, 1),
	EIGHT_NOTE(NOTE_E, 4, 1),
	EIGHT_NOTE(NOTE_A, 3, 9),
	EIGHT_NOTE(NOTE_B, 3, 2),
	EIGHT_NOTE(NOTE_C, 4, 1),
	EIGHT_NOTE(NOTE_D, 4, 7),
	EIGHT_NOTE(NOTE_E, 4, 1),
	EIGHT_NOTE(NOTE_F, 4, 1),
	EIGHT_NOTE(NOTE_E, 4, 1),
	EIGHT_NOTE(NOTE_F, 4, 1),
	EIGHT_NOTE(NOTE_E, 4, 1),
	EIGHT_NOTE(NOTE_A, 3, 9),
	EIGHT_NOTE(NOTE_G, 3, 3),
	EIGHT_NOTE(NOTE_A, 3, 7),
	EIGHT_NOTE(NOTE_B, 3, 1),
	EIGHT_NOTE(NOTE_C, 4, 1),
	EIGHT_NOTE(NOTE_B, 3, 1),
	EIGHT_NOTE(NOTE_C, 4, 1),
	EIGHT_NOTE(NOTE_B, 3, 1),
	EIGHT_NOTE(NOTE_E, 3, 9),
	EIGHT_NOTE(NOTE_F, 3, 2),
	EIGHT_NOTE(NOTE_G, 3, 1),
	EIGHT_NOTE(NOTE_A, 3, 7),
	EIGHT_NOTE(NOTE_B, 3, 1),
	EIGHT_NOTE(NOTE_C, 4, 1),
	EIGHT_NOTE(NOTE_B, 3, 1),
	EIGHT_NOTE(NOTE_C, 4, 1),
	EIGHT_NOTE(NOTE_B, 3, 1),
	EIGHT_NOTE(NOTE_E, 3, 12),
	EIGHT_NOTE(NOTE_D, 4, 9),
	EIGHT_NOTE(NOTE_C, 4, 3),
	EIGHT_NOTE(NOTE_B, 3, 6),
	EIGHT_NOTE(NOTE_A, 3, 6),
	EIGHT_NOTE(NOTE_D, 4, 7),
	EIGHT_NOTE(NOTE_E, 4, 1),
	EIGHT_NOTE(NOTE_E, 4, 1),
	EIGHT_NOTE(NOTE_C, 4, 1),
	EIGHT_NOTE(NOTE_B, 3, 1),
	EIGHT_NOTE(NOTE_C, 4, 1),
	EIGHT_NOTE(NOTE_B, 3, 6),
	EIGHT_NOTE(NOTE_A, 3, 6),
	EIGHT_NOTE(NOTE_C, 4, 9),
	EIGHT_NOTE(NOTE_B, 3, 3),
	EIGHT_NOTE(NOTE_E, 3, 12),
	EIGHT_NOTE(NOTE_C, 4, 7),
	EIGHT_NOTE(NOTE_D, 4, 1),
	EIGHT_NOTE(NOTE_C, 4, 1),
	EIGHT_NOTE(NOTE_B, 3, 1),
	EIGHT_NOTE(NOTE_C, 4, 1),
	EIGHT_NOTE(NOTE_B, 3, 1),
	EIGHT_NOTE(NOTE_E, 3, 12),
	{ NOTE_END, 0, 0 }
];

Note channel1[] = [
	EIGHT_NOTE(NOTE_D, 1, 1),
	EIGHT_NOTE(NOTE_A, 1, 1),
	EIGHT_NOTE(NOTE_D, 2, 1),
	EIGHT_NOTE(NOTE_E, 2, 1),
	EIGHT_NOTE(NOTE_F, 2, 1),
	EIGHT_NOTE(NOTE_A, 2, 1),
	EIGHT_NOTE(NOTE_F, 2, 1),
	EIGHT_NOTE(NOTE_E, 2, 1),
	EIGHT_NOTE(NOTE_D, 2, 1),
	EIGHT_NOTE(NOTE_A, 1, 1),
	EIGHT_NOTE(NOTE_D, 1, 1),
	EIGHT_NOTE(NOTE_A, 1, 1),
	EIGHT_NOTE(NOTE_A, 0, 1),
	EIGHT_NOTE(NOTE_E, 1, 1),
	EIGHT_NOTE(NOTE_A, 1, 1),
	EIGHT_NOTE(NOTE_B, 1, 1),
	EIGHT_NOTE(NOTE_C, 2, 1),
	EIGHT_NOTE(NOTE_E, 2, 1),
	EIGHT_NOTE(NOTE_C, 2, 1),
	EIGHT_NOTE(NOTE_B, 1, 1),
	EIGHT_NOTE(NOTE_A, 1, 1),
	EIGHT_NOTE(NOTE_E, 1, 1),
	EIGHT_NOTE(NOTE_A, 0, 1),
	EIGHT_NOTE(NOTE_E, 1, 1),
	EIGHT_NOTE(NOTE_D, 1, 1),
	EIGHT_NOTE(NOTE_A, 1, 1),
	EIGHT_NOTE(NOTE_D, 2, 1),
	EIGHT_NOTE(NOTE_E, 2, 1),
	EIGHT_NOTE(NOTE_F, 2, 1),
	EIGHT_NOTE(NOTE_A, 2, 1),
	EIGHT_NOTE(NOTE_F, 2, 1),
	EIGHT_NOTE(NOTE_E, 2, 1),
	EIGHT_NOTE(NOTE_D, 2, 1),
	EIGHT_NOTE(NOTE_A, 1, 1),
	EIGHT_NOTE(NOTE_D, 1, 1),
	EIGHT_NOTE(NOTE_A, 1, 1),
	EIGHT_NOTE(NOTE_A, 0, 1),
	EIGHT_NOTE(NOTE_E, 1, 1),
	EIGHT_NOTE(NOTE_A, 1, 1),
	EIGHT_NOTE(NOTE_B, 1, 1),
	EIGHT_NOTE(NOTE_C, 2, 1),
	EIGHT_NOTE(NOTE_E, 2, 1),
	EIGHT_NOTE(NOTE_C, 2, 1),
	EIGHT_NOTE(NOTE_B, 1, 1),
	EIGHT_NOTE(NOTE_A, 1, 1),
	EIGHT_NOTE(NOTE_E, 1, 1),
	EIGHT_NOTE(NOTE_A, 0, 1),
	EIGHT_NOTE(NOTE_E, 1, 1),
	EIGHT_NOTE(NOTE_F, 1, 1),
	EIGHT_NOTE(NOTE_C, 2, 1),
	EIGHT_NOTE(NOTE_F, 2, 1),
	EIGHT_NOTE(NOTE_G, 2, 1),
	EIGHT_NOTE(NOTE_A, 2, 1),
	EIGHT_NOTE(NOTE_C, 3, 1),
	EIGHT_NOTE(NOTE_A, 2, 1),
	EIGHT_NOTE(NOTE_G, 2, 1),
	EIGHT_NOTE(NOTE_F, 2, 1),
	EIGHT_NOTE(NOTE_C, 2, 1),
	EIGHT_NOTE(NOTE_F, 1, 1),
	EIGHT_NOTE(NOTE_C, 2, 1),
	EIGHT_NOTE(NOTE_C, 1, 1),
	EIGHT_NOTE(NOTE_G, 1, 1),
	EIGHT_NOTE(NOTE_C, 2, 1),
	EIGHT_NOTE(NOTE_D, 2, 1),
	EIGHT_NOTE(NOTE_E, 2, 1),
	EIGHT_NOTE(NOTE_G, 2, 1),
	EIGHT_NOTE(NOTE_E, 2, 1),
	EIGHT_NOTE(NOTE_D, 2, 1),
	EIGHT_NOTE(NOTE_C, 2, 1),
	EIGHT_NOTE(NOTE_G, 1, 1),
	EIGHT_NOTE(NOTE_C, 1, 1),
	EIGHT_NOTE(NOTE_G, 1, 1),
	EIGHT_NOTE(NOTE_F, 1, 1),
	EIGHT_NOTE(NOTE_C, 2, 1),
	EIGHT_NOTE(NOTE_F, 2, 1),
	EIGHT_NOTE(NOTE_G, 2, 1),
	EIGHT_NOTE(NOTE_A, 2, 1),
	EIGHT_NOTE(NOTE_C, 3, 1),
	EIGHT_NOTE(NOTE_A, 2, 1),
	EIGHT_NOTE(NOTE_G, 2, 1),
	EIGHT_NOTE(NOTE_F, 2, 1),
	EIGHT_NOTE(NOTE_C, 2, 1),
	EIGHT_NOTE(NOTE_F, 1, 1),
	EIGHT_NOTE(NOTE_C, 2, 1),
	EIGHT_NOTE(NOTE_C, 1, 1),
	EIGHT_NOTE(NOTE_G, 1, 1),
	EIGHT_NOTE(NOTE_C, 2, 1),
	EIGHT_NOTE(NOTE_D, 2, 1),
	EIGHT_NOTE(NOTE_E, 2, 1),
	EIGHT_NOTE(NOTE_G, 2, 1),
	EIGHT_NOTE(NOTE_E, 2, 1),
	EIGHT_NOTE(NOTE_D, 2, 1),
	EIGHT_NOTE(NOTE_C, 2, 1),
	EIGHT_NOTE(NOTE_G, 1, 1),
	EIGHT_NOTE(NOTE_C, 1, 1),
	EIGHT_NOTE(NOTE_G, 1, 1),
	EIGHT_NOTE(NOTE_D, 1, 1),
	EIGHT_NOTE(NOTE_A, 1, 1),
	EIGHT_NOTE(NOTE_D, 2, 1),
	EIGHT_NOTE(NOTE_E, 2, 1),
	EIGHT_NOTE(NOTE_F, 2, 1),
	EIGHT_NOTE(NOTE_A, 2, 1),
	EIGHT_NOTE(NOTE_F, 2, 1),
	EIGHT_NOTE(NOTE_E, 2, 1),
	EIGHT_NOTE(NOTE_D, 2, 1),
	EIGHT_NOTE(NOTE_A, 1, 1),
	EIGHT_NOTE(NOTE_D, 1, 1),
	EIGHT_NOTE(NOTE_A, 1, 1),
	EIGHT_NOTE(NOTE_A, 0, 1),
	EIGHT_NOTE(NOTE_E, 1, 1),
	EIGHT_NOTE(NOTE_A, 1, 1),
	EIGHT_NOTE(NOTE_B, 1, 1),
	EIGHT_NOTE(NOTE_C, 2, 1),
	EIGHT_NOTE(NOTE_E, 2, 1),
	EIGHT_NOTE(NOTE_C, 2, 1),
	EIGHT_NOTE(NOTE_B, 1, 1),
	EIGHT_NOTE(NOTE_A, 1, 1),
	EIGHT_NOTE(NOTE_E, 1, 1),
	EIGHT_NOTE(NOTE_A, 0, 1),
	EIGHT_NOTE(NOTE_E, 1, 1),
	EIGHT_NOTE(NOTE_D, 1, 1),
	EIGHT_NOTE(NOTE_A, 1, 1),
	EIGHT_NOTE(NOTE_D, 2, 1),
	EIGHT_NOTE(NOTE_E, 2, 1),
	EIGHT_NOTE(NOTE_F, 2, 1),
	EIGHT_NOTE(NOTE_A, 2, 1),
	EIGHT_NOTE(NOTE_F, 2, 1),
	EIGHT_NOTE(NOTE_E, 2, 1),
	EIGHT_NOTE(NOTE_D, 2, 1),
	EIGHT_NOTE(NOTE_A, 1, 1),
	EIGHT_NOTE(NOTE_D, 1, 1),
	EIGHT_NOTE(NOTE_A, 1, 1),
	EIGHT_NOTE(NOTE_A, 0, 1),
	EIGHT_NOTE(NOTE_E, 1, 1),
	EIGHT_NOTE(NOTE_A, 1, 1),
	EIGHT_NOTE(NOTE_B, 1, 1),
	EIGHT_NOTE(NOTE_C, 2, 1),
	EIGHT_NOTE(NOTE_E, 2, 1),
	EIGHT_NOTE(NOTE_C, 2, 1),
	EIGHT_NOTE(NOTE_B, 1, 1),
	EIGHT_NOTE(NOTE_A, 1, 1),
	EIGHT_NOTE(NOTE_E, 1, 1),
	EIGHT_NOTE(NOTE_A, 0, 1),
	EIGHT_NOTE(NOTE_E, 1, 1),
	EIGHT_NOTE(NOTE_F, 1, 1),
	EIGHT_NOTE(NOTE_C, 2, 1),
	EIGHT_NOTE(NOTE_F, 2, 1),
	EIGHT_NOTE(NOTE_G, 2, 1),
	EIGHT_NOTE(NOTE_A, 2, 1),
	EIGHT_NOTE(NOTE_C, 3, 1),
	EIGHT_NOTE(NOTE_A, 2, 1),
	EIGHT_NOTE(NOTE_G, 2, 1),
	EIGHT_NOTE(NOTE_F, 2, 1),
	EIGHT_NOTE(NOTE_C, 2, 1),
	EIGHT_NOTE(NOTE_F, 1, 1),
	EIGHT_NOTE(NOTE_C, 2, 1),
	EIGHT_NOTE(NOTE_C, 1, 1),
	EIGHT_NOTE(NOTE_G, 1, 1),
	EIGHT_NOTE(NOTE_C, 2, 1),
	EIGHT_NOTE(NOTE_D, 2, 1),
	EIGHT_NOTE(NOTE_E, 2, 1),
	EIGHT_NOTE(NOTE_G, 2, 1),
	EIGHT_NOTE(NOTE_E, 2, 1),
	EIGHT_NOTE(NOTE_D, 2, 1),
	EIGHT_NOTE(NOTE_C, 2, 1),
	EIGHT_NOTE(NOTE_G, 1, 1),
	EIGHT_NOTE(NOTE_C, 1, 1),
	EIGHT_NOTE(NOTE_G, 1, 1),
	EIGHT_NOTE(NOTE_F, 1, 1),
	EIGHT_NOTE(NOTE_C, 2, 1),
	EIGHT_NOTE(NOTE_F, 2, 1),
	EIGHT_NOTE(NOTE_G, 2, 1),
	EIGHT_NOTE(NOTE_A, 2, 1),
	EIGHT_NOTE(NOTE_C, 3, 1),
	EIGHT_NOTE(NOTE_A, 2, 1),
	EIGHT_NOTE(NOTE_G, 2, 1),
	EIGHT_NOTE(NOTE_F, 2, 1),
	EIGHT_NOTE(NOTE_C, 2, 1),
	EIGHT_NOTE(NOTE_F, 1, 1),
	EIGHT_NOTE(NOTE_C, 2, 1),
	EIGHT_NOTE(NOTE_C, 1, 1),
	EIGHT_NOTE(NOTE_G, 1, 1),
	EIGHT_NOTE(NOTE_C, 2, 1),
	EIGHT_NOTE(NOTE_D, 2, 1),
	EIGHT_NOTE(NOTE_E, 2, 1),
	EIGHT_NOTE(NOTE_G, 2, 1),
	EIGHT_NOTE(NOTE_E, 2, 1),
	EIGHT_NOTE(NOTE_D, 2, 1),
	EIGHT_NOTE(NOTE_C, 2, 1),
	EIGHT_NOTE(NOTE_G, 1, 1),
	EIGHT_NOTE(NOTE_C, 1, 1),
	EIGHT_NOTE(NOTE_G, 1, 1),
	{ NOTE_END, 0, 0 }
];

Note* channels[];

static this() {
	channels.length = 2;
	channels[0] = channel0.ptr;
	channels[1] = channel1.ptr;
}

void nextNote(int channel) {
	ChannelState* state = &channelStates[channel];
	state.currentNote = channels[channel][state.noteIndex];
	state.currentTime = 0;
	state.currentsampleIndex = 0;
	int note = state.currentNote.note;
	if (note == NOTE_PAUSE) {
		state.currentsampleIncrement = 0;
	} else {
		state.currentsampleIncrement = octaves[state.currentNote.octave][note] * (cast(float) SAMPLE_COUNT) / (cast(float) SAMPLE_RATE);
	}

	state.noteIndex++;
	if (channels[channel][state.noteIndex].note == NOTE_END) state.noteIndex = 0;
}

// calculate current value of attack/delay/sustain/release envelope
float adsr(float time, float duration) {
	if (time < 0.0) return 0.0;
	const float attack = 0.004;
	const float decay = 0.02;
	const float sustain = 0.5;
	const float release = 0.08;
	duration -= attack + decay + release;
	if (time < attack) return time / attack;
	time -= attack;
	if (time < decay) return (decay - time) / decay * (1.0 - sustain) + sustain;
	time -= decay;
	if (time < duration) return sustain;
	time -= duration;
	if (time < release) return (release - time) / release * sustain;
	return 0.0;
}

void audioOutCallback(int channel, ushort* buf, uint reqn)
{
	ChannelState* state = &channelStates[channel];
	uint i;
	for (i = 0; i < reqn; i++) {
		float time = (cast(float) state.currentTime) / (cast(float) SAMPLE_RATE);
		if (state.currentTime++ == state.currentNote.duration) nextNote(channel);
		float value;
		if (state.currentsampleIncrement == 0.0) {
			value = 0.0;
		} else {
			value = sample[cast(int)state.currentsampleIndex] * adsr(time, (cast(float) state.currentNote.duration) / (cast(float) SAMPLE_RATE));
			value *= cast(float) 0x7000;
			state.currentsampleIndex += state.currentsampleIncrement;
			if (state.currentsampleIndex >= SAMPLE_COUNT) state.currentsampleIndex -= cast(float) SAMPLE_COUNT;
		}
		//pspDebugScreenPrintf("%f\n", value);
		buf[0] = cast(ushort)value;
		buf[1] = cast(ushort)value;
		buf += 2;
	}
}

extern (C) {
	void audioOutCallback0(void *buf, uint reqn, void *userdata) { audioOutCallback(0, cast(ushort *)buf, reqn); }
	void audioOutCallback1(void *buf, uint reqn, void *userdata) { audioOutCallback(1, cast(ushort *)buf, reqn); }
}

void createPitches(float base, float* target)
{
	int i;
	for (i = 0; i < 12; i++) {
		target[i] = base;
		base *= 1.0594630943592952645618252949463;  // 2^(1/12)
	}
}

int main()
{
	pspDebugScreenInit();
	SetupCallbacks();
	pspDebugScreenPrintf("Polyphonic sample by Shine\n\n");
	pspDebugScreenPrintf("Soundtrack of the movie\n");
	pspDebugScreenPrintf("\"Le fabuleux destin d'Amelie Poulain\"\n");
	pspDebugScreenPrintf("by Yann Tiersen\n");
	
	int i;
	int maxAt = SAMPLE_COUNT / 16;
	for (i = 0; i < SAMPLE_COUNT; i++) {
		float value;
		if (i < maxAt) {
			value = (cast(float) i) / (cast(float) maxAt) * 2.0 - 1.0;
		} else {
			value = 1.0 - (cast(float) (i - maxAt)) / (cast(float) (SAMPLE_COUNT - maxAt)) * 2.0;
		}
		sample[i] = value;
	}
	float base = 40.0;
	for (i = 0; i < OCTAVE_COUNT; i++) {
		createPitches(base, octaves[i].ptr);
		base *= 2;
	}
	channelStates[0].noteIndex = 0; nextNote(0);
	channelStates[1].noteIndex = 0; nextNote(1);

	pspAudioInit();
	pspAudioSetVolume(0, 0x4000, 0x4000);
	pspAudioSetVolume(1, 0x4000, 0x4000);
	pspAudioSetChannelCallback(0, &audioOutCallback0, null);
	pspAudioSetChannelCallback(1, &audioOutCallback1, null);
	sceKernelSleepThread();

	return 0;
}
