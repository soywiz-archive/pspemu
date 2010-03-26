module pspemu.core.gpu.impl.GpuSoftware;

import pspemu.core.gpu.Types;

class GpuSoftware : GpuImplAbstract {
	void init() {
		assert(0);
	}
	
	void reset() {
		assert(0);
	}

	void startDisplayList() {
		// Here we should invalidate texture cache? and recheck hashes of the textures?
		assert(0);
	}

	void endDisplayList() {
		assert(0);
	}

	void clear() {
		assert(0);
	}

	void draw(VertexState[] vertexList, PrimitiveType type, PrimitiveFlags flags) {
		assert(0);
	}

	void flush() {
		assert(0);
	}

	void frameLoad(void* buffer) {
		assert(0);
	}

	void frameStore(void* buffer) {
		assert(0);
	}

}