module pspsdk.utils.vram;

import pspsdk.pspge;
import pspsdk.pspgu;

static uint staticOffset = 0;

static uint getMemorySize(uint width, uint height, uint psm) {
	switch (psm) {
		case GU_PSM_T4: return (width * height) >> 1;
		case GU_PSM_T8: return width * height;
		case GU_PSM_5650, GU_PSM_5551, GU_PSM_4444, GU_PSM_T16: return 2 * width * height;
		case GU_PSM_8888, GU_PSM_T32: return 4 * width * height;
		default: return 0;
	}
}

void* getStaticVramBuffer(uint width, uint height, uint psm) {
	uint memSize = getMemorySize(width,height,psm);
	void* result = cast(void*)staticOffset;
	staticOffset += memSize;
	return result;
}

void* getStaticVramTexture(uint width, uint height, uint psm) {
	void* result = getStaticVramBuffer(width,height,psm);
	return cast(void*)((cast(uint)result) + (cast(uint)sceGeEdramGetAddr()));
}
