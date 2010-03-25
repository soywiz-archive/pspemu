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
#include <pspkernel.h>
#include <pspdebug.h>
#include <pspthreadman.h>
#include <pspaudio.h>
#include <stdlib.h>
#include <math.h>
#include <string.h>

/* Define the module info section */
PSP_MODULE_INFO("POLYPHONIC", 0, 1, 1);

/* Define the main thread's attribute value (optional) */
PSP_MAIN_THREAD_ATTR(THREAD_ATTR_USER | THREAD_ATTR_VFPU);

/* Define printf, just to make typing easier */
#define printf	pspDebugScreenPrintf

#define PSP_NUM_AUDIO_CHANNELS 4
/** This is the number of frames you can update per callback, a frame being
 * 1 sample for mono, 2 samples for stereo etc. */
#define PSP_NUM_AUDIO_SAMPLES 1024
#define PSP_VOLUME_MAX 0x8000

typedef void (* pspAudioCallback_t)(void *buf, unsigned int reqn, void *pdata);

typedef struct {
  int threadhandle;
  int handle;
  int volumeleft;
  int volumeright;
  pspAudioCallback_t callback;
  void *pdata;
} psp_audio_channelinfo;

typedef int (* pspAudioThreadfunc_t)(int args, void *argp);

int  pspAudioInit();
void pspAudioEndPre();
void pspAudioEnd();

void pspAudioSetVolume(int channel, int left, int right);
void pspAudioChannelThreadCallback(int channel, void *buf, unsigned int reqn);
void pspAudioSetChannelCallback(int channel, pspAudioCallback_t callback, void *pdata);
int  pspAudioOutBlocking(unsigned int channel, unsigned int vol1, unsigned int vol2, void *buf);

static int audio_ready=0;
static short audio_sndbuf[PSP_NUM_AUDIO_CHANNELS][2][PSP_NUM_AUDIO_SAMPLES][2];

static psp_audio_channelinfo AudioStatus[PSP_NUM_AUDIO_CHANNELS];

static volatile int audio_terminate=0;

void pspAudioSetVolume(int channel, int left, int right)
{
  AudioStatus[channel].volumeright = right;
  AudioStatus[channel].volumeleft  = left;
}

void pspAudioChannelThreadCallback(int channel, void *buf, unsigned int reqn)
{
	pspAudioCallback_t callback;
	callback=AudioStatus[channel].callback;
}


void pspAudioSetChannelCallback(int channel, pspAudioCallback_t callback, void *pdata)
{
	volatile psp_audio_channelinfo *pci = &AudioStatus[channel];
	pci->callback=0;
	pci->pdata=pdata;
	pci->callback=callback;
}

int pspAudioOutBlocking(unsigned int channel, unsigned int vol1, unsigned int vol2, void *buf)
{
	if (!audio_ready) return -1;
	if (channel>=PSP_NUM_AUDIO_CHANNELS) return -1;
	if (vol1>PSP_VOLUME_MAX) vol1=PSP_VOLUME_MAX;
	if (vol2>PSP_VOLUME_MAX) vol2=PSP_VOLUME_MAX;
	return sceAudioOutputPannedBlocking(AudioStatus[channel].handle,vol1,vol2,buf);
}

static int AudioChannelThread(int args, void *argp)
{
	volatile int bufidx=0;
	int channel=*(int *)argp;

	printf("AudioChannelThread(%d)\n", channel);
	
	while (audio_terminate==0) {
		void *bufptr=&audio_sndbuf[channel][bufidx];
		pspAudioCallback_t callback;
		callback=AudioStatus[channel].callback;
		if (callback) {
			callback(bufptr, PSP_NUM_AUDIO_SAMPLES, AudioStatus[channel].pdata);
		} else {
			unsigned int *ptr=bufptr;
			int i;
			for (i=0; i<PSP_NUM_AUDIO_SAMPLES; ++i) *(ptr++)=0;
		}
		pspAudioOutBlocking(channel,AudioStatus[channel].volumeleft,AudioStatus[channel].volumeright,bufptr);
		bufidx=(bufidx?0:1);
	}
	sceKernelExitThread(0);
	return 0;
}



/******************************************************************************/



int pspAudioInit()
{
	int i,ret;
	int failed=0;
	char str[32];

	audio_terminate=0;
	audio_ready=0;
	
	printf("pspAudioInit\n");

	for (i=0; i<PSP_NUM_AUDIO_CHANNELS; i++) {
    AudioStatus[i].handle = -1;
    AudioStatus[i].threadhandle = -1;
    AudioStatus[i].volumeright = PSP_VOLUME_MAX;
    AudioStatus[i].volumeleft  = PSP_VOLUME_MAX;
    AudioStatus[i].callback = 0;
    AudioStatus[i].pdata = 0;
	}
	for (i=0; i<PSP_NUM_AUDIO_CHANNELS; i++) {
		if ((AudioStatus[i].handle = sceAudioChReserve(-1,PSP_NUM_AUDIO_SAMPLES,0))<0) 
      failed=1;
	}
	if (failed) {
		for (i=0; i<PSP_NUM_AUDIO_CHANNELS; i++) {
			if (AudioStatus[i].handle != -1) 
        sceAudioChRelease(AudioStatus[i].handle);
			AudioStatus[i].handle = -1;
		}
		return -1;
	}
	audio_ready = 1;
	strcpy(str,"audiot0");
	for (i=0; i<PSP_NUM_AUDIO_CHANNELS; i++) {
		str[6]='0'+i;
		AudioStatus[i].threadhandle = sceKernelCreateThread(str,(void*)&AudioChannelThread,0x12,0x10000,0,NULL);
		if (AudioStatus[i].threadhandle < 0) {
			AudioStatus[i].threadhandle = -1;
			failed=1;
			break;
		}
		ret=sceKernelStartThread(AudioStatus[i].threadhandle,sizeof(i),&i);
		if (ret!=0) {
			failed=1;
			break;
		}
	}
	if (failed) {
		audio_terminate=1;
		for (i=0; i<PSP_NUM_AUDIO_CHANNELS; i++) {
			if (AudioStatus[i].threadhandle != -1) {
				//sceKernelWaitThreadEnd(AudioStatus[i].threadhandle,NULL);
				sceKernelDeleteThread(AudioStatus[i].threadhandle);
			}
			AudioStatus[i].threadhandle = -1;
		}
		audio_ready=0;
		return -1;
	}
	return 0;
}


void pspAudioEndPre()
{
	audio_ready=0;
	audio_terminate=1;
}


void pspAudioEnd()
{
	int i;
	audio_ready=0;
	audio_terminate=1;

	for (i=0; i<PSP_NUM_AUDIO_CHANNELS; i++) {
		if (AudioStatus[i].threadhandle != -1) {
			//sceKernelWaitThreadEnd(AudioStatus[i].threadhandle,NULL);
			sceKernelDeleteThread(AudioStatus[i].threadhandle);
		}
		AudioStatus[i].threadhandle = -1;
	}

	for (i=0; i<PSP_NUM_AUDIO_CHANNELS; i++) {
		if (AudioStatus[i].handle != -1) {
			sceAudioChRelease(AudioStatus[i].handle);
			AudioStatus[i].handle = -1;
		}
	}
}


void dump_threadstatus(void);

/* Exit callback */
int exit_callback(int arg1, int arg2, void *common)
{
	sceKernelExitGame();

	return 0;
}

/* Callback thread */
int CallbackThread(SceSize args, void *argp)
{
	int cbid;

	cbid = sceKernelCreateCallback("Exit Callback", (void *) exit_callback, NULL);
	sceKernelRegisterExitCallback(cbid);

	sceKernelSleepThreadCB();

	return 0;
}

/* Sets up the callback thread and returns its thread id */
int SetupCallbacks(void)
{
	int thid = 0;

	thid = sceKernelCreateThread("update_thread", CallbackThread, 0x11, 0xFA0, 0, 0);
	if(thid >= 0)
	{
		sceKernelStartThread(thid, 0, 0);
	}

	return thid;
}

int  pspAudioInit();
void pspAudioEndPre();
void pspAudioEnd();

#define SAMPLE_COUNT 0x10000
float sample[SAMPLE_COUNT];

#define SAMPLE_RATE 44100

#define OCTAVE_COUNT 6

float octaves[OCTAVE_COUNT][12];

typedef struct {
	int note;
	int octave;
	int duration;
} Note_t;

typedef struct {
	Note_t currentNote;
	int noteIndex;
	int currentTime;
	float currentsampleIndex;
	float currentsampleIncrement;
} ChannelState_t;

ChannelState_t channelStates[3];

// "S" means "#"
#define NOTE_END -2
#define NOTE_PAUSE -1
#define NOTE_C 0
#define NOTE_CS 1
#define NOTE_D 2
#define NOTE_DS 3
#define NOTE_E 4
#define NOTE_F 5
#define NOTE_FS 6
#define NOTE_G 7
#define NOTE_GS 8
#define NOTE_A 9
#define NOTE_AS 10
#define NOTE_B 11

#define EIGHT_NOTE(note, octave, duration) { note, octave, SAMPLE_RATE * duration / 8}

Note_t channel0[] = {
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
};

Note_t channel1[] = {
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
};

Note_t* channels[] = { channel0, channel1 };

void nextNote(int channel)
{
	ChannelState_t* state = &channelStates[channel];
	state->currentNote = channels[channel][state->noteIndex];
	state->currentTime = 0;
	state->currentsampleIndex = 0;
	int note = state->currentNote.note;
	if (note == NOTE_PAUSE) {
		state->currentsampleIncrement = 0;
	} else {
		state->currentsampleIncrement = octaves[state->currentNote.octave][note] * ((float) SAMPLE_COUNT) / ((float) SAMPLE_RATE);
	}

	state->noteIndex++;
	if (channels[channel][state->noteIndex].note == NOTE_END) state->noteIndex = 0;
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

void audioOutCallback(int channel, unsigned short* buf, unsigned int reqn)
{
	ChannelState_t* state = &channelStates[channel];
	unsigned int i;
	for (i = 0; i < reqn; i++) {
		float time = ((float) state->currentTime) / ((float) SAMPLE_RATE);
		if (state->currentTime++ == state->currentNote.duration) nextNote(channel);
		float value;
		if (state->currentsampleIncrement == 0.0) {
			value = 0.0;
		} else {
			value = sample[(int)state->currentsampleIndex] * adsr(time, ((float) state->currentNote.duration) / ((float) SAMPLE_RATE));
			value *= (float) 0x7000;
			state->currentsampleIndex += state->currentsampleIncrement;
			if (state->currentsampleIndex >= SAMPLE_COUNT) state->currentsampleIndex -= (float) SAMPLE_COUNT;
		}
		buf[0] = value;
		buf[1] = value;
		//printf("%f\n", value);
		buf += 2;
	}
}

void audioOutCallback0(void *buf, unsigned int reqn, void *userdata) { audioOutCallback(0, buf, reqn); }
void audioOutCallback1(void *buf, unsigned int reqn, void *userdata) { audioOutCallback(1, buf, reqn); }

void createPitches(float base, float* target)
{
	int i;
	for (i = 0; i < 12; i++) {
		target[i] = base;
		base *= 1.0594630943592952645618252949463;  // 2^(1/12)
	}
}

int main(void)
{
	pspDebugScreenInit();
	SetupCallbacks();
	printf("Polyphonic sample by Shine\n\n");
	printf("Soundtrack of the movie\n");
	printf("\"Le fabuleux destin d'Amelie Poulain\"\n");
	printf("by Yann Tiersen\n");

        int i;
	int maxAt = SAMPLE_COUNT / 16;
	for (i = 0; i < SAMPLE_COUNT; i++) {
		float value;
		if (i < maxAt) {
			value = ((float) i) / ((float) maxAt) * 2.0 - 1.0;
		} else {
			value = 1.0 - ((float) (i - maxAt)) / ((float) (SAMPLE_COUNT - maxAt)) * 2.0;
		}
		sample[i] = value;
		//printf("%f,", sample[i]);
	}
	float base = 40.0;
	for (i = 0; i < OCTAVE_COUNT; i++) {
		createPitches(base, octaves[i]);
		base *= 2;
	}
	channelStates[0].noteIndex = 0; nextNote(0);
	channelStates[1].noteIndex = 0; nextNote(1);

	pspAudioInit();
	pspAudioSetVolume(0, 0x4000, 0x4000);
	pspAudioSetVolume(1, 0x4000, 0x4000);
	pspAudioSetChannelCallback(0, audioOutCallback0, NULL);
	pspAudioSetChannelCallback(1, audioOutCallback1, NULL);
	sceKernelSleepThread();

	return 0;
}
