module pspemu.core.gpu.GpuImpl;

import pspemu.core.gpu.Types;
import pspemu.core.gpu.GpuState;

import std.stdio;
import pspemu.utils.BitUtils;
import pspemu.utils.MathUtils;
public import std.datetime;

interface IGpuImpl {
	void setState(GpuState *state);
	void init();
	void reset();
	void startDisplayList();
	void endDisplayList();
	void clear();
	void draw(ushort[] indexList, VertexState[] vertexList, PrimitiveType type, PrimitiveFlags flags);
	void flush();
	void frameLoad (void* colorBuffer, void* depthBuffer);
	void frameStore(void* colorBuffer, void* depthBuffer);
	void tsync();
	void tflush();
	void test(string reason);
	void fastTrxKickToFrameBuffer();
	void recordFrameStart();
	void recordFrameEnd();
	int  getTextureCacheCount();
	int  getTextureCacheSize();
	void readIndexes(ref ushort[] indexListBuffer, ubyte* indexPointer, uint indexCount, out uint maxVertexCount, VertexType vertexType);
	void readVertices(ref VertexState[] vertexListBuffer, ubyte* vertexPointer, int maxVertexCount, VertexType vertexType, float[] morphWeights, Matrix[8] boneMatrix);
}

abstract class GpuImplAbstract : IGpuImpl {
	GpuState *state;
	StopWatch setStateStopWatch;
	StopWatch drawStopWatch;
	void setState(GpuState *state) { this.state = state; }
	
	abstract int getTextureCacheCount();
	abstract int getTextureCacheSize();
	
	void readIndexes(ref ushort[] indexListBuffer, ubyte* indexPointer, uint indexCount, out uint maxVertexCount, VertexType vertexType) {
		alias indexCount vertexCount;
		maxVertexCount = 0;
		
		void extractIndexGen(T)(ref ushort index) {
			index = cast(ushort)*cast(T *)indexPointer;
			indexPointer += T.sizeof;
		}
		
		auto extractIndexTable = [null, &extractIndexGen!(ubyte), &extractIndexGen!(ushort), &extractIndexGen!(uint)];
		auto extractIndex      = (indexPointer !is null) ? extractIndexTable[vertexType.index] : null;

		// Extract indexes.
		{
			if (indexListBuffer.length < indexCount) indexListBuffer.length = indexCount;
			
			if (extractIndex) {
				for (int n = 0; n < indexCount; n++) {
					//auto TIndexPointer = cast(T *)indexPointer;
					//vertexPointer = vertexPointerBase + (*TIndexPointer * vertexSizeWithMorph);
					extractIndex(indexListBuffer[n]);
					if (maxVertexCount < indexListBuffer[n]) maxVertexCount = indexListBuffer[n];
				}
				maxVertexCount++;
			} else {
				for (int n = 0; n < vertexCount; n++) indexListBuffer[n] = cast(ushort)n;
				maxVertexCount = vertexCount;
			}
		}
	}


	/**
	 * Read vertices.
	 *
	 * @TODO Use OpenCL integrated with OpenGL on the GpuOpenGL driver.
	 */
	void readVertices(ref VertexState[] vertexListBuffer, ubyte* vertexPointer, int maxVertexCount, VertexType vertexType, float[] morphWeights, Matrix[8] boneMatrix) {
		static void pad(ref ubyte* ptr, ubyte pad) {
			if ((cast(uint)ptr) % pad) ptr += (pad - ((cast(uint)ptr) % pad));
		}

		static void extractArray(T)(ref ubyte* vertexPointer, float[] array) {
			pad(vertexPointer, T.sizeof);
			foreach (ref value; array) {
				debug (EXTRACT_PRIM_COMPONENT) writefln("%08X(%s):%s", cast(uint)cast(void *)vertexPointer, typeid(T), *cast(T*)vertexPointer);
				value = *cast(T*)vertexPointer;
				vertexPointer += T.sizeof;
			}
		}

		static void extractColor8888(ref ubyte* vertexPointer, float[] array) {
			pad(vertexPointer, 4);
			for (int n = 0; n < 4; n++) {
				array[n] = cast(float)vertexPointer[n] / 255.0;
			}
			vertexPointer += 4;
		}

		static void extractColorInvalidbits (ref ubyte* vertexPointer, float[] array) {
			pad(vertexPointer, 1);
			// palette?
			writefln("Unimplemented Gpu.OP_PRIM.extractColorInvalidbits");
			//throw(new Exception("Unimplemented Gpu.OP_PRIM.extractColor8bits"));
			vertexPointer += 1;
		}

		static void extractColor5650(ref ubyte* vertexPointer, float[] array) {
			pad(vertexPointer, 2);
			ushort data = *cast(ushort*)vertexPointer;
			array[0] = BitUtils.extractNormalizedFloat!( 0, 5)(data);
			array[1] = BitUtils.extractNormalizedFloat!( 5, 6)(data);
			array[2] = BitUtils.extractNormalizedFloat!(11, 5)(data);
			array[3] = 1.0;
			vertexPointer += 2;
		}

		static void extractColor5551(ref ubyte* vertexPointer, float[] array) {
			pad(vertexPointer, 2);
			ushort data = *cast(ushort*)vertexPointer;
			array[0] = BitUtils.extractNormalizedFloat!( 0, 5)(data);
			array[1] = BitUtils.extractNormalizedFloat!( 5, 5)(data);
			array[2] = BitUtils.extractNormalizedFloat!(10, 5)(data);
			array[3] = BitUtils.extractNormalizedFloat!(15, 1)(data);
			vertexPointer += 2;
		}
		
		static void extractColor4444(ref ubyte* vertexPointer, float[] array) {
			pad(vertexPointer, 2);
			ushort data = *cast(ushort*)vertexPointer;
			array[0] = BitUtils.extractNormalizedFloat!( 0, 4)(data);
			array[1] = BitUtils.extractNormalizedFloat!( 4, 4)(data);
			array[2] = BitUtils.extractNormalizedFloat!( 8, 4)(data);
			array[3] = BitUtils.extractNormalizedFloat!(12, 4)(data);
			vertexPointer += 2;
		}

		static auto extractTable      = [null, &extractArray!(byte), &extractArray!(short), &extractArray!(float)];
		static auto extractColorTable = [null, &extractColorInvalidbits, &extractColorInvalidbits, &extractColorInvalidbits, &extractColor5650, &extractColor5551, &extractColor4444, &extractColor8888];

		auto extractWeights    = extractTable[vertexType.weight  ];
		auto extractTexture    = extractTable[vertexType.texture ];
		auto extractPosition   = extractTable[vertexType.position];
		auto extractNormal     = extractTable[vertexType.normal  ];
		auto extractColor      = extractColorTable[vertexType.color];
		
		ubyte[] tableSizes = [0, 1, 2, 4];
		ubyte[] colorSizes = [0, 1, 1, 1, 2, 2, 2, 4];

		bool shouldPerformSkin = (!vertexType.transform2D) && (vertexType.skinningWeightCount > 1);

		
		ubyte vertexAlignSize = 0;
		vertexAlignSize = max(vertexAlignSize, tableSizes[vertexType.weight]);
		vertexAlignSize = max(vertexAlignSize, tableSizes[vertexType.texture]);
		vertexAlignSize = max(vertexAlignSize, tableSizes[vertexType.position]);
		vertexAlignSize = max(vertexAlignSize, tableSizes[vertexType.normal]);
		vertexAlignSize = max(vertexAlignSize, colorSizes[vertexType.color]);

		void extractVertex(ref VertexState vertex) {
			//while ((cast(uint)vertexPointer) & 0b11) vertexPointer++;
			//if ((cast(uint)vertexPointer) & 0b11) writefln("ERROR!");
			
			// Vertex has to be aligned to the maxium size of any component. 
			pad(vertexPointer, vertexAlignSize);
			
			if (extractWeights) {
				extractWeights(vertexPointer, vertex.weights[0..vertexType.skinningWeightCount]);
				debug (EXTRACT_PRIM) writef("| weights(...) ");
			}
			if (extractTexture) {
				extractTexture(vertexPointer, (&vertex.u)[0..2]);
				debug (EXTRACT_PRIM) writef("| texture(%f, %f) ", vertex.u, vertex.v);
			}
			if (extractColor) {
				extractColor(vertexPointer, (&vertex.r)[0..4]);
				debug (EXTRACT_PRIM) writef("| color(%f, %f, %f, %f) ", vertex.r, vertex.g, vertex.b, vertex.a);
			}
			if (extractNormal) {
				extractNormal(vertexPointer, (&vertex.nx)[0..3]);
				debug (EXTRACT_PRIM) writef("| normal(%f, %f, %f) ", vertex.nx, vertex.ny, vertex.nz);
			}
			if (extractPosition) {
				extractPosition(vertexPointer, (&vertex.px)[0..3]);
				debug (EXTRACT_PRIM) writef("| position(%f, %f, %f) ", vertex.px, vertex.py, vertex.pz);
			}
			debug (EXTRACT_PRIM) writefln("");
		}
		
		static void multiplyVectorPerMatrix(bool translate)(out float[3] outf, float[] inf, in Matrix matrix, float weight) {
			for (int i = 0; i < 3; i++) {
				float f = 0;
				f += inf[0] * matrix.cells[0 + i]; 
				f += inf[1] * matrix.cells[4 + i];
				f += inf[2] * matrix.cells[8 + i];
				static if (translate) {
					f += 1 * matrix.cells[12 + i];
				}
				outf[i] = f * weight;
			}
		}
		
		VertexState performSkin(VertexState vertexState) {
			if (!shouldPerformSkin) return vertexState;
			
			//writefln("%s", gpu.state.boneMatrix[0]);
			VertexState skinnedVertexState = vertexState;
			(cast(float *)&skinnedVertexState.px)[0..3] = 0.0;
			(cast(float *)&skinnedVertexState.nx)[0..3] = 0.0;
			
			float[3] p, n;

			for (int m = 0; m < vertexType.skinningWeightCount; m++) {
				multiplyVectorPerMatrix!(true)(
					p,
					(cast(float *)&vertexState.px)[0..3],
					boneMatrix[m],
					vertexState.weights[m]
				);

				multiplyVectorPerMatrix!(false)(
					n,
					(cast(float *)&vertexState.nx)[0..3],
					boneMatrix[m],
					vertexState.weights[m]
				);
				
				//writefln("%s", p);
				
				(cast(float *)&skinnedVertexState.px)[0..3] += p[];
				(cast(float *)&skinnedVertexState.nx)[0..3] += n[];
			}
			
			return skinnedVertexState;
		}

		// Extract vertex list.
		{
			if (vertexListBuffer.length < maxVertexCount) vertexListBuffer.length = maxVertexCount;
			
			auto extractAllVertex(bool doMorph)() {
				for (int n = 0; n < maxVertexCount; n++) {
					static if (!doMorph) {
						extractVertex(vertexListBuffer[n]);
						vertexListBuffer[n] = performSkin(vertexListBuffer[n]);
					} else {
						VertexState vertexStateMorphed;
						VertexState currentVertexState = void;
						
						for (int m = 0; m < vertexType.morphingVertexCount; m++) {
							extractVertex(currentVertexState);
							currentVertexState = performSkin(currentVertexState);
							vertexStateMorphed.floatValues[] += currentVertexState.floatValues[] * morphWeights[m];
						}
			
						vertexListBuffer[n] = vertexStateMorphed;
					}
				}
			}
			
			if (vertexType.morphingVertexCount == 1) {
				extractAllVertex!(false)();
			} else {
				extractAllVertex!(true)();
			}
			
			//writefln("%d", maxVertexCount);
		}
	}
}