module pspemu.core.gpu.GpuImpl;

import pspemu.core.gpu.Types;
import pspemu.core.gpu.GpuState;

interface GpuImpl {
	void setState(GpuState *state);
	void init();
	void reset();
	void startDisplayList();
	void endDisplayList();
	void clear();
	void draw(VertexState[] vertexList, PrimitiveType type, PrimitiveFlags flags);
	void flush();
	void frameLoad (void* colorBuffer, void* depthBuffer);
	void frameStore(void* colorBuffer, void* depthBuffer);
	void tsync();
	void tflush();
	void test(string reason);
}

abstract class GpuImplAbstract : GpuImpl {
	GpuState *state;
	void setState(GpuState *state) { this.state = state; }
}