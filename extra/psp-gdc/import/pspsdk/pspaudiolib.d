module pspsdk.pspaudiolib;

version (BUILD_INFO) {
	pragma(lib, pspaudio);
	pragma(lib, pspaudiolib);
}

extern (C):

static const uint PSP_NUM_AUDIO_CHANNELS = 4;
/** This is the number of frames you can update per callback, a frame being
 * 1 sample for mono, 2 samples for stereo etc. */
static const uint PSP_NUM_AUDIO_SAMPLES = 1024;
static const uint PSP_VOLUME_MAX = 0x8000;

alias void function(void *buf, uint reqn, void *pdata) pspAudioCallback;
//typedef void (* pspAudioCallback_t)(void *buf, uint reqn, void *pdata);

struct psp_audio_channelinfo {
  int threadhandle;
  int handle;
  int volumeleft;
  int volumeright;
  pspAudioCallback callback;
  void *pdata;
}

alias int function(int args, void *argp) pspAudioThreadfunc;
//typedef int (* pspAudioThreadfunc_t)(int args, void *argp);

int  pspAudioInit();
void pspAudioEndPre();
void pspAudioEnd();

void pspAudioSetVolume(int channel, int left, int right);
void pspAudioChannelThreadCallback(int channel, void *buf, uint reqn);
void pspAudioSetChannelCallback(int channel, pspAudioCallback callback, void *pdata);
int  pspAudioOutBlocking(uint channel, uint vol1, uint vol2, void *buf);
