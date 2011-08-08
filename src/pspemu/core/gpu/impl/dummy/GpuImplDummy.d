module pspemu.core.gpu.impl.dummy.GpuImplDummy;

public import pspemu.core.gpu.GpuImpl;

class GpuImplDummy : IGpuImpl {
	void setState(GpuState *state) { }
	void init() { }
	void reset() { }
	void startDisplayList() { }
	void endDisplayList() { }
	void clear() { }
	void draw(ushort[] indexList, VertexState[] vertexList, PrimitiveType type, PrimitiveFlags flags) { }
	void flush() { }
	void frameLoad (void* colorBuffer, void* depthBuffer) { }
	void frameStore(void* colorBuffer, void* depthBuffer) { }
	void tsync() { }
	void tflush() { }
	void test(string reason) { }
	void fastTrxKickToFrameBuffer() { }
	void recordFrameStart() { }
	void recordFrameEnd() { }
	int  getTextureCacheCount() { return 0; }
	int  getTextureCacheSize() { return 0; }
	void readIndexes(ref ushort[] indexListBuffer, ubyte* indexPointer, uint indexCount, out uint maxVertexCount, VertexType vertexType) { }
	void readVertices(ref VertexState[] vertexListBuffer, ubyte* vertexPointer, int maxVertexCount, VertexType vertexType, float[] morphWeights, Matrix[8] boneMatrix) { }
}