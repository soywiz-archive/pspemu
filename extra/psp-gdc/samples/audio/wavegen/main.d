/* 
   AudioLib Sample

   Demonstrates how to get sound working with minimal effort.

   Based on sdktest sample from pspsdk
*/

import pspsdk.all;
import std.c.math;
//import std.c.limits;

version (BUILD_INFO) {
	pragma(MODULE_NAME, "AUDIOLIBDEMO");
	pragma(PSP_EBOOT_TITLE, "Audio Lib Demo");
	pragma(PSP_MAIN_THREAD_ATTR, THREAD_ATTR_USER | THREAD_ATTR_VFPU);
	pragma(PSP_FW_VERSION, 150);
}

static const float PI = 3.1415926535897932f;
static const int sampleRate = 44100;
float frequency = 440.0f;
float time = 0;
int _function = 0;

struct sample {
	short l, r;
}

T clamp(T)(T v, T m, T M) {
	if (v < m) return m;
	if (v > m) return M;
	return v;
}

float currentFunction(/*const*/ float time) {
	double x;
	float t = modf(time / (2 * PI), &x);

	switch(_function) {
		case 0: { // SINE
			return sinf(time);
		}
		case 1: { // SQUARE
			if (t < 0.5f) {
				return -0.2f;
			} else {
				return 0.2f;
			}
		}
		case 2: { // TRIANGLE
			if (t < 0.5f) {
				return t * 2.0f - 0.5f;
			} else {
				return 0.5f - (t - 0.5f) * 2.0f;
			}
		}
		default: {
			return 0.0f;
		}
	}
}


/* This function gets called by pspaudiolib every time the
   audio buffer needs to be filled. The sample format is
   16-bit, stereo. */
extern (C) void audioCallback(void* buf, uint length, void *userdata) {
	const float sampleLength = 1.0f / sampleRate;
	const float scaleFactor = short.max - 1.0f;
	static float freq0 = 440.0f;
	sample* ubuf = cast(sample*) buf;
	int i;
	
	if (frequency != freq0) {
		time *= (freq0 / frequency);
	}
	for (i = 0; i < length; i++) {
		short s = cast(short) (scaleFactor * currentFunction(2.0f * PI * frequency * time));
		ubuf[i].l = s;
		ubuf[i].r = s;
		time += sampleLength;
	}
	if (time * frequency > 1.0f) {
		double d;
		time = modf(time * frequency, &d) / frequency;
	}
	freq0 = frequency;
}

/* Read the analog stick and adjust the frequency */
void controlFrequency() {
	static int oldButtons = 0;
	const int zones[6] = [30, 70, 100, 112, 125, 130];
	const float response[6] = [0.0f, 0.1f, 0.5f, 1.0f, 4.0f, 8.0f];
	const float minFreq = 32.0f;
	const float maxFreq = 7040.0f;
	SceCtrlData pad;
	float direction;
	int changedButtons;
	int i, v;

	sceCtrlReadBufferPositive(&pad, 1);

	v = pad.Ly - 128;
	if (v < 0) {
		direction = 1.0f;
		v = -v;
	} else {
		direction = -1.0f;
	}

	for (i = 0; i < 6; i++) {
		if (v < zones[i]) {
			frequency += response[i] * direction;
			break;
		}
	}

	frequency = clamp(frequency, minFreq, maxFreq);

	changedButtons = pad.Buttons & (~oldButtons);
	if (changedButtons & PSP_CTRL_CROSS) {
		_function++;
		if (_function > 2) _function = 0;
	}
	oldButtons = pad.Buttons;
}

int main() {
	pspDebugScreenInit();
	SetupCallbacks();

	pspAudioInit();
	pspAudioSetChannelCallback(0, &audioCallback, null);

	sceCtrlSetSamplingCycle(0);
	sceCtrlSetSamplingMode(PSP_CTRL_MODE_ANALOG);

	pspDebugScreenPrintf("Press up and down to select frequency\nPress X to change function\n");
	
	while (running) {
		sceDisplayWaitVblankStart();
		pspDebugScreenSetXY(0,2);
		pspDebugScreenPrintf("freq = %.2f   \n", frequency);
		switch (_function) {
			case 0: pspDebugScreenPrintf("sine wave\n"); break;
			case 1: pspDebugScreenPrintf("square wave\n"); break;
			case 2: pspDebugScreenPrintf("triangle wave\n"); break;
			default: assert(0);
		}
		controlFrequency();
	}
	return 0;
}
