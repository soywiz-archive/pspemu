module pspemu.core.gpu.impl.gl.GpuOpengl;

/*
http://code.google.com/p/jpcsp/source/browse/trunk/src/jpcsp/graphics/VideoEngine.java
http://code.google.com/p/pspemu/source/browse/branches/old/src/core/gpu.d
http://code.google.com/p/pspplayer/source/browse/trunk/Noxa.Emulation.Psp.Video.OpenGL/OglDriver_Processing.cpp
*/

//debug = DEBUG_CLEAR_MODE;

//version = VERSION_ENABLE_FRAME_LOAD; // Disabled temporary. It cause problems with some games (Dividead for example and a lot of games using SDL. I have to fix it first.).
//version = VERSION_HOLD_DEPTH_BUFFER_IN_MEMORY; // Disabled temporary

version = VERSION_ENABLED_STATE_CORTOCIRCUIT;
version = VERSION_ENABLED_STATE_CORTOCIRCUIT_EX;

//debug = DEBUG_OUTPUT_DEPTH_AND_STENCIL;
//debug = DEBUG_PRIM_PERFORMANCE;
//debug = DEBUG_FRAME_TRANSFER;

import std.file;
import std.datetime;
import std.path;
import std.conv;
import std.math;
import std.stream;
import pspemu.utils.StructUtils;

import std.c.windows.windows;
import std.windows.syserror;
import std.stdio;
import etc.c.zlib;

//import pspemu.utils.Utils;
//import pspemu.utils.Image;

//import pspemu.utils.OpenGL;

import pspemu.core.Memory;
import pspemu.core.gpu.Types;
import pspemu.core.gpu.GpuState;
import pspemu.core.gpu.GpuImpl;
import pspemu.utils.MathUtils;
import pspemu.utils.Logger;
import pspemu.utils.BitUtils;

import derelict.opengl.gl;
import derelict.opengl.glext;
import derelict.opengl.wgl;
//import derelict.util.wintypes;

import pspemu.core.gpu.impl.gl.GpuOpenglUtils;
import pspemu.core.gpu.impl.gl.GpuOpenglTexture;

import pspemu.core.exceptions.NotImplementedException;

import pspemu.utils.imaging.SimplePng;
import pspemu.utils.imaging.SimpleTga;


class GpuOpengl : GpuImplAbstract {
	mixin OpenglBase;
	mixin OpenglUtils;

	/// Previous state to check changes in the new state and perform new operations.
	GpuState prevState;
	PrimitiveFlags prevPrimitiveFlags;
	//glProgram program;
	
	ubyte[4 * 512 * 272] tempBufferData;

	/*
	glUniform gla_tex;
	glUniform gla_clut;
	glUniform gla_clutOffset;
	glUniform gla_clutUse;
	glUniform gla_textureUse;
	*/
	
	void init() {
		openglInit();
		openglPostInit();

		//setVSync(0);
		/*
		program = new glProgram();
		program.attach(new glFragmentShader(import("shader.fragment")));
		program.attach(new glVertexShader(import("shader.vertex")));
		program.link();
		*/
		glPixelStorei(GL_PACK_ALIGNMENT, 1);
		glPixelStorei(GL_UNPACK_ALIGNMENT, 1);
		//program.use();

		/*
		gla_tex          = program.getUniform("tex");
		gla_clut         = program.getUniform("clut");
		gla_clutOffset   = program.getUniform("clutOffset");
		gla_clutUse      = program.getUniform("clutUse");
		gla_textureUse   = program.getUniform("textureUse");
		*/

		//program.use(0);
		
		implInit();
		
		reset();
	}
	
	uint recordFrameID = 0;
	long recordFrameTime = 0;
	bool recordFrame = false;

	void recordFrameStart() {
		recordFrame = true;
		recordFrameID = 0;
		recordFrameTime = std.datetime.Clock.currStdTime;
	}

	void recordFrameEnd() {
		recordFrame = false;
		
		int count = 0;
		string buffer;
		for (int n = 0; ; n++) {
			string dumpFilename = std.string.format("GPU/%s/%d.bin", recordFrameTime, n);
			if (!std.file.exists(dumpFilename)) break;
			GpuOpengl.DumpStruct dumpStruct = GpuOpengl.loadDump(cast(ubyte[])std.file.read(dumpFilename));
			buffer ~= dumpStruct.dumpString ~ "\n";
			count++;
		}
		
		if (count > 0) {
			std.file.write(std.string.format("GPU/%s/frame.txt", recordFrameTime), buffer);
		}
		//std.c.stdlib.exit(0);
	}
	
	void fastTrxKickToFrameBuffer() {
		// trxkick:TextureTransfer(Size(480, 272) : SRC(addr=08EB4510, w=480, XY(0, 0))-DST(addr=04088000, w=512, XY(0, 0))) : Bpp:4
		writefln("trxkick:%s", state.textureTransfer);
		with (state.textureTransfer) {
			GlPixelFormat glPixelFormat = GlPixelFormats[state.drawBuffer.format];
			int _dstX = dstX, _dstY = dstY;
			
			// @TODO: With this we should increment _dstX and _dstY
			// CHECK!
			// dstAddress - state.drawBuffer.address;
			int dstPixels = (dstAddress - state.drawBuffer.address) / glPixelFormat.isize;
			_dstX += dstPixels % dstLineWidth;
			_dstY += dstPixels / dstLineWidth;

			glWindowPos2i(_dstX, 272 - _dstY);
			glPixelZoom(1.0f, -1.0f);

			glPixelStorei(GL_UNPACK_ALIGNMENT,   glPixelFormat.isize);
			glPixelStorei(GL_UNPACK_ROW_LENGTH,  srcLineWidth);
			glPixelStorei(GL_UNPACK_SKIP_PIXELS, srcX);
			glPixelStorei(GL_UNPACK_SKIP_ROWS,   srcY);
			{
				glDrawPixels(
					width, height,
					glPixelFormat.external,
					glPixelFormat.opengl,
					state.memory.getPointer(srcAddress)
				);
			}
			glPixelStorei(GL_UNPACK_ALIGNMENT,   1);
			glPixelStorei(GL_UNPACK_ROW_LENGTH,  0);
			glPixelStorei(GL_UNPACK_SKIP_PIXELS, 0);
			glPixelStorei(GL_UNPACK_SKIP_ROWS,   0);
		}
	}

	void reset() {
		if (textureCachePool is null) textureCachePool = new TextureCachePool(this);
		textureCachePool.reset();
	}
	
	int getTextureCacheCount() {
		return textureCachePool.length;
	}
	
	int getTextureCacheSize() {
		return textureCachePool.size;
	}

	void startDisplayList() {
		debug (DEBUG_PRIM_PERFORMANCE) writefln("-");

		// Here we should invalidate texture cache? and recheck hashes of the textures?
		textureCachePool.markForRecheckAll();
	}

	void endDisplayList() {
		state.toggleUpdateState = !state.toggleUpdateState;
	}
	
	void tflush() {
		// ???
		//foreach (texture; textureCache) texture.markForRecheck = true;
	}
	
	void tsync() {
	}

	void test(string reason) {	
		writefln("GpuOpengl.test('%s')", reason);
	}

	void clear() {
	}
	
	static struct DumpStruct {
		string textureName;
		ushort[] indexList;
		VertexState[] vertexList;
		GpuState gpuState;
		PrimitiveType type;
		PrimitiveFlags flags;
		
		string dumpString() {
			string r;
			r ~= std.string.format("--------------------------------------------------------------------------------------------------------\n");
			r ~= std.string.format("textureName: '%s'\n", textureName);
			r ~= std.string.format("primitiveType: %s(%d)\n", to!string(type), type);
			r ~= std.string.format("flags: %s)\n", flags);
			r ~= std.string.format("indexList(%d): %s\n", indexList.length, indexList);
			r ~= std.string.format("vertexList(%d):\n", vertexList.length);
			foreach (ref vertex; vertexList) r ~= std.string.format("  %s\n", vertex.toString(type, flags));
			r ~= std.string.format("gpuState:%s\n", gpuState.toString(type, flags));
			return r;
		}
		
		void dump() {
			writefln("%s", dumpString);
		}
	}
	
	static ubyte[] saveDump(ref DumpStruct dumpStruct) {
		MemoryStream stream = new MemoryStream();
		ubyte[] output;
		
		stream.write(cast(uint)dumpStruct.textureName.length);
		stream.write(cast(uint)dumpStruct.indexList.length);
		stream.write(cast(uint)dumpStruct.vertexList.length);
		stream.write(cast(ubyte[])dumpStruct.textureName);
		stream.write(TA(dumpStruct.gpuState));
		stream.write(TA(dumpStruct.type));
		stream.write(TA(dumpStruct.flags));
		stream.write(cast(ubyte[])dumpStruct.indexList);
		stream.write(cast(ubyte[])dumpStruct.vertexList);
		
		return stream.data;
	}
	
	static DumpStruct loadDump(ubyte[] data) {
		DumpStruct dumpStruct;
		uint textureNameLength;
		uint indexListLength;
		uint vertexListLength;
		scope stream = new MemoryStream(data);
		
		uint read32() {
			uint v;
			stream.read(v);
			return v;
		}
		
		dumpStruct.textureName.length = read32();
		dumpStruct.indexList.length = read32();
		dumpStruct.vertexList.length = read32();
		
		stream.read(cast(ubyte[])dumpStruct.textureName);
		stream.read(TA(dumpStruct.gpuState));
		stream.read(TA(dumpStruct.type));
		stream.read(TA(dumpStruct.flags));
		stream.read(cast(ubyte[])dumpStruct.indexList);
		stream.read(cast(ubyte[])dumpStruct.vertexList);
		
		return dumpStruct;
	}

	void draw(ushort[] indexList, VertexState[] vertexList, PrimitiveType type, PrimitiveFlags flags) {
		//writefln("[1]"); scope (exit) writefln("[2]");
		
		if (recordFrame) {
			string dumpPath = std.string.format("GPU/%s", recordFrameTime);
			try { std.file.mkdirRecurse(dumpPath); } catch { }
			//prevState.texture.
			
			string textureFileName;
			
			if (state.texture.enabled) {
				Texture texture = getTexture(state.texture, state.clut);
				textureFileName = std.string.format("%s/TEXTURE_%08X_%s_%s.png", dumpPath, texture.textureHash, to!string(texture.textureFormat), to!string(texture.clutFormat));
				if (!std.file.exists(textureFileName)) {
					ubyte[] data = texture.getTexturePixels();
					SimplePng.write(cast(uint[])data, texture.getTextureWidth(), texture.getTextureHeight(), textureFileName);
				}
			} else {
				textureFileName = "";
			}
			
			{
				DumpStruct dumpStruct;
				dumpStruct.flags = flags;
				dumpStruct.gpuState = *state;
				dumpStruct.indexList = indexList;
				dumpStruct.vertexList = vertexList;
				dumpStruct.textureName = cast(string)textureFileName.dup;
				dumpStruct.type = type;
				
				std.file.write(std.string.format("%s/%d.bin", dumpPath, recordFrameID), saveDump(dumpStruct));
			}
			
			recordFrameID++;
		}

		/*
		if (flags.hasColor) {
			flags.hasTexture = false;
			bool backTextureEnabled = state.texture.enabled;
			scope (exit) state.texture.enabled = backTextureEnabled; 
			state.texture.enabled = false;
		}
		*/
		
		//if (gpu.state.clearingMode) return; // Do not draw in clearmode.

		/*
		static if (1) {
			writefln("type:%d, vertexcount:%d, flags:%d", type, vertexList.length, flags);
			writefln("  %s", vertexList[0]);
			writefln("  %s", vertexList[1]);
		}
		*/

		debug (DEBUG_PRIM_PERFORMANCE) {
			auto start = microSecondsTick; scope (exit) writefln("DRAW: Vertex(%d) : MicroSeconds(%d)", vertexList.length, microSecondsTick - start);
		}
	
		void putVertex(ref VertexState vertex) {
			if (flags.hasTexture ) glTexCoord2f(vertex.u, vertex.v);
			if (flags.hasColor   ) {
				glColor4fv(&vertex.r);
				//glColor4f(vertex.r, vertex.g, vertex.b, 1.0);
			}
			if (flags.hasNormal  ) glNormal3f(vertex.nx, vertex.ny, vertex.nz);
			if (flags.hasPosition) glVertex3f(vertex.px, vertex.py, vertex.pz);
			//writefln("UV(%f, %f)", vertex.u, vertex.v);
			debug (DEBUG_CLEAR_MODE) if (state.clearingMode) writefln("POS(%f, %f, %f) : COL(%f, %f, %f, %f)", vertex.px, vertex.py, vertex.pz, vertex.r, vertex.g, vertex.b, vertex.a);
		}
		
		debug (DEBUG_CLEAR_MODE) if (state.clearingMode) writefln("--");

		//writefln("draw[1]");
		drawBegin(flags);
		
		drawStopWatch.start();
		scope (exit) drawStopWatch.stop();
		
		//writefln("draw[2]");
		{
			switch (type) {
				// Special primitive that doesn't have equivalent in Open
				// With two points specify a GL_QUAD.
				// http://www.openorg/registry/specs/ARB/point_sprite.txt
				// http://cirl.missouri.edu/gpu/glsl_lessons/glsl_geometry_shader/index.html
				case PrimitiveType.GU_SPRITES:
					static string spriteVertexInterpolate(string vx, string vy) {
						string s;
						s ~= "vertex.px = " ~ vx ~ ".px; vertex.py = " ~ vy ~ ".py;";
						s ~= "vertex.nx = " ~ vx ~ ".px; vertex.ny = " ~ vy ~ ".py;";
						s ~= "vertex.u  = " ~ vx ~ ".u ; vertex.v  = " ~ vy ~ ".v;";
						/*
						s ~= "vertex.weights[]  = " ~ vy ~ ".weights[];";
						s ~= "vertex.r  = " ~ vy ~ ".r;";
						s ~= "vertex.g  = " ~ vy ~ ".g;";
						s ~= "vertex.b  = " ~ vy ~ ".b;";
						s ~= "vertex.a  = " ~ vy ~ ".a;";
						*/
						return s;
					}

					glPushAttrib(GL_CULL_FACE);
					{
						glDisable(GL_CULL_FACE);
						glBegin(GL_QUADS);
						{
							for (int n = 0; n < vertexList.length; n += 2) {
								VertexState v1 = vertexList[n + 0], v2 = vertexList[n + 1], vertex = void;
								
								debug (DEBUG_CLEAR_MODE) if (state.clearingMode) writefln("(%f,%f,%f)-(%f,%f,%f)", v1.px, v1.py, v1.pz, v2.px, v2.py, v2.pz);
								vertex = v2;
								mixin(spriteVertexInterpolate("v1", "v1")); putVertex(vertex);
								mixin(spriteVertexInterpolate("v2", "v1")); putVertex(vertex);
								mixin(spriteVertexInterpolate("v2", "v2")); putVertex(vertex);
								mixin(spriteVertexInterpolate("v1", "v2")); putVertex(vertex);
							}
						}
						glEnd();
					}
					glPopAttrib();
				break;
				// Normal primitives that have equivalent in Open
				default: {
					static if (true) {
						glEnableDisableClientState(GL_COLOR_ARRAY,  flags.hasColor);
						glEnableDisableClientState(GL_NORMAL_ARRAY, flags.hasNormal);
						glEnableDisableClientState(GL_VERTEX_ARRAY, flags.hasPosition);
						glEnableDisableClientState(GL_TEXTURE_COORD_ARRAY, flags.hasTexture);
						glEnableDisableClientState(GL_INDEX_ARRAY, false);
						glEnableDisableClientState(GL_EDGE_FLAG_ARRAY, false);

						static uint arrayBuffer;
						
						/*
						ubyte* base = null;
						
						if (glBufferData !is null) {
							if (arrayBuffer == 0) glGenBuffers(1, &arrayBuffer);
							glBindBuffer(GL_ARRAY_BUFFER, arrayBuffer);
							glBufferData(GL_ARRAY_BUFFER, VertexState.sizeof * vertexList.length, vertexList.ptr, GL_DYNAMIC_DRAW);
						} else {
							base = cast(ubyte*)vertexList.ptr;
						}

						if (base is null) {
						} else {
						}
						*/
						auto base = cast(ubyte*)vertexList.ptr;
						glTexCoordPointer(2, GL_FLOAT, VertexState.sizeof, base + vertexList[0].u.offsetof);
						glColorPointer   (4, GL_FLOAT, VertexState.sizeof, base + vertexList[0].r.offsetof);
						glNormalPointer  (   GL_FLOAT, VertexState.sizeof, base + vertexList[0].nx.offsetof);
						glVertexPointer  (3, GL_FLOAT, VertexState.sizeof, base + vertexList[0].px.offsetof);
						
						//glDrawArrays(PrimitiveTypeTranslate[type], 0, vertexList.length);

						//glInterleavedArrays(GL_T2F_C4F_N3F_V3F, VertexState.sizeof, vertexList.ptr);
						
						//glDrawArrays(PrimitiveTypeTranslate[type], 0, vertexList.length);
						
						//glIndexPointer(GL_UNSIGNED_SHORT, 0, indexList.ptr);
						glDrawElements(PrimitiveTypeTranslate[type], indexList.length, GL_UNSIGNED_SHORT, indexList.ptr);
					}
					// Faster?
					else {
						glBegin(PrimitiveTypeTranslate[type]);
						{
							//foreach (ref vertex; vertexList) putVertex(vertex);
							foreach (index; indexList) {
								//vertexList[index].nx = 0;
								//vertexList[index].ny = 0;
								//vertexList[index].nz = 0;
								putVertex(vertexList[index]);
							}
						}
						glEnd();
					}
				} break;
			}
		}
		drawEnd(flags);
	}

	void flush() {
		glFlush();
	}

	// http://hitmen.c02.at/files/yapspd/psp_doc/chap10.html#sec10
	// @TODO @FIXME - Depth should be swizzled.
	// Reading from VRAM+6Mib will give you a proper linearized version of the depth buffer with no effort.

	void frameLoad(void* colorBuffer, void* depthBuffer) {
		//scope microSecondsStart = microSecondsTick;
		
		version (VERSION_ENABLE_FRAME_LOAD) {
			if (colorBuffer !is null) {
				glWindowPos2i(0, 272 - 0);
				glPixelZoom(1.0f, -1.0f);
				
				GlPixelFormat glPixelFormat = GlPixelFormats[state.drawBuffer.format];
				glPixelStorei(GL_UNPACK_ALIGNMENT, glPixelFormat.isize);

				//glColorMask(true, true, true, false);

				glDrawPixels(
					state.drawBuffer.width, 272,
					glPixelFormat.external,
					glPixelFormat.opengl,
					colorBuffer
				);
				
				glPixelStorei(GL_UNPACK_ALIGNMENT, 1);
			}
			
			version (VERSION_HOLD_DEPTH_BUFFER_IN_MEMORY) {
				if ((depthBuffer !is null) && (colorBuffer != depthBuffer)) {
					glWindowPos2i(0, 0);
					glPixelZoom(1.0f, 1.0f);
					glDrawPixels(
						state.depthBuffer.width, 272,
						GL_DEPTH_COMPONENT,
						GL_UNSIGNED_SHORT,
						depthBuffer
					);
				}
			}
		}
		
		//debug (DEBUG_FRAME_TRANSFER) writefln("frameLoad(%08X, %08X) : microseconds:%d", cast(uint)colorBuffer, cast(uint)depthBuffer, microSecondsTick - microSecondsStart);
	}

	void frameStore(void* colorBuffer, void* depthBuffer) {
		//scope microSecondsStart = microSecondsTick;

		//return;
		if (colorBuffer !is null) {
			//(cast(uint *)drawBufferAddress)[0..512 * 272] = bitmapData[0..512 * 272];
			//writefln("%d, %d", state.drawBuffer.width, 272);

			GlPixelFormat glPixelFormat = GlPixelFormats[state.drawBuffer.format];
			glPixelStorei(GL_PACK_ALIGNMENT, cast(uint)glPixelFormat.size);

			glReadPixels(
				0, 0, // x, y
				state.drawBuffer.width, 272, // w, h
				glPixelFormat.external,
				//GL_RGB,
				glPixelFormat.opengl,
				&tempBufferData[0]
			);
			
			glPixelStorei(GL_PACK_ALIGNMENT, 1);
			
			for (int n = 0; n < 272; n++) {
				int m = 271 - n;
				state.drawBuffer.row(colorBuffer, n)[] = state.drawBuffer.row(&tempBufferData, m)[];
			}
		}

		version (VERSION_HOLD_DEPTH_BUFFER_IN_MEMORY) {
			if ((depthBuffer !is null) && (colorBuffer != depthBuffer)) {
				glReadPixels(
					0, 0, // x, y
					state.depthBuffer.width, 272, // w, h
					GL_DEPTH_COMPONENT,
					GL_UNSIGNED_SHORT,
					depthBuffer
				);
			}
		}

		debug (DEBUG_OUTPUT_DEPTH_AND_STENCIL) {
			outputDepthAndStencil();
		}
		
		debug (DEBUG_FRAME_TRANSFER) writefln("frameStore(%08X, %08X) : microseconds:%d", cast(uint)colorBuffer, cast(uint)depthBuffer, microSecondsTick - microSecondsStart);
	}
}

class TextureCachePool {
	// Implement.
	static struct TextureCacheInfo {
		Texture texture;
		uint size;
		uint hit;
		uint lastUpdate;
		string hash;
	}
	GpuOpengl gpuOpengl;
	Texture[string] textureCache;
	int textureCacheSize;
	
	this(GpuOpengl gpuOpengl) {
		this.gpuOpengl = gpuOpengl;
	}
	
	void reset() {
		foreach (texture; textureCache) texture.free();
		textureCache = null;
	}

	int size() {
		return textureCacheSize;
	}
	
	int length() {
		return textureCache.length;
	}
	
	Texture get(TextureState textureState, ClutState clutState) {
		__gshared missCount = 0;
		Texture texture = void;
		
		static ubyte[] emptyBuffer;
		
		//auto textureData = textureState.address ? (cast(ubyte*)gpuOpengl.state.memory.getPointer(textureState.address))[0..textureState.mipmapTotalSize(0)] : emptyBuffer;
		//string hash = textureState.hash ~ clutState.hash ~ cast(string)textureData ~ cast(string)clutState.getRealClutData;
		string hash = textureState.hash ~ clutState.hash;
		
		if ((hash in textureCache) is null) {
			texture = new Texture();
			textureCache[hash] = texture;
			//writefln("TEXTURE CACHE MISS!! (%d)", missCount);
			missCount++;
		} else {
			texture = textureCache[hash];
		}
		textureCacheSize -= texture.size;
		{ 
			texture.update(gpuOpengl.state.memory, textureState, clutState);
		}
		textureCacheSize += texture.size;
		return texture;
	}
	
	void markForRecheckAll() {
		scope textureCacheDup = textureCache.dup;
		foreach (textureHash, texture; textureCacheDup) {
			if (texture.canDelete) {
				textureCacheSize -= texture.size;
				texture.free();
				textureCache.remove(textureHash);
			} else {
				texture.markForRecheck = true;
			}
		}
	}
}

template OpenglUtils() {
	TextureCachePool textureCachePool;
	//Clut[uint] clutCache;
	
	bool glEnableDisable(int type, bool enable) {
		if (enable) glEnable(type); else glDisable(type);
		return enable;
	}

	bool glEnableDisableClientState(int type, bool enable) {
		if (enable) glEnableClientState(type); else glDisableClientState(type);
		return enable;
	}

	void outputDepthAndStencil() {
		/*
		scope temp = new ubyte[1024 * 1024];
		glReadPixels(
			0, 0, // x, y
			state.drawBuffer.width, 272, // w, h
			GL_DEPTH_COMPONENT,
			GL_UNSIGNED_BYTE,
			temp.ptr
		);
		writeBmp8("depth.bmp", temp.ptr, 512, 272, paletteGrayScale);
		glReadPixels(
			0, 0, // x, y
			state.drawBuffer.width, 272, // w, h
			GL_STENCIL_INDEX,
			GL_UNSIGNED_BYTE,
			temp.ptr
		);
		writeBmp8("stencil.bmp", temp.ptr, 512, 272, paletteRandom);
		*/
		throw(new NotImplementedException("outputDepthAndStencil"));
	}
	
	Texture getTexture(TextureState textureState, ClutState clutState) {
		return textureCachePool.get(textureState, clutState);
	}
	
	bool lastIsTransform2D = false;
	
	void drawBeginCommon() {
		void prepareMatrix() {
			if (state.vertexType.transform2D) {
				if (!lastIsTransform2D) {
					glMatrixMode(GL_PROJECTION); glLoadIdentity();
					glOrtho(0, 512, 272, 0, -0x7FFF, +0x7FFF);
					glMatrixMode(GL_MODELVIEW); glLoadIdentity();
					lastIsTransform2D = true;
				}
			} else {
				glMatrixMode(GL_PROJECTION); glLoadIdentity();
				glMultMatrixf(state.projectionMatrix.pointer);

				glMatrixMode(GL_MODELVIEW); glLoadIdentity();
				glMultMatrixf(state.viewMatrix.pointer);
				glMultMatrixf(state.worldMatrix.pointer);
				lastIsTransform2D = false;
			}
		}

		prepareMatrix();
	}

	void drawBeginClear(PrimitiveFlags flags) {
		bool ccolorMask, calphaMask;
		
		glDisable(GL_BLEND);
		glDisable(GL_STENCIL_TEST);
		glDisable(GL_LIGHTING);
		glDisable(GL_TEXTURE_2D);
		glDisable(GL_ALPHA_TEST);
		glDisable(GL_FOG);
		glDisable(GL_DEPTH_TEST);
		glDisable(GL_LOGIC_OP);
		glDisable(GL_CULL_FACE);
		glDepthMask(false);
		
		if (state.clearFlags & ClearBufferMask.GU_COLOR_BUFFER_BIT) {
			ccolorMask = true;
		}

		if (state.clearFlags & ClearBufferMask.GU_STENCIL_BUFFER_BIT) {
			calphaMask = true;
			// Sets to 0x00 the stencil.
			glEnable(GL_STENCIL_TEST);
			glStencilFunc(GL_ALWAYS, 0, 0xFF); // @TODO @FIXME! : Color should be extracted from the color! (as alpha component)
			glStencilOp(GL_REPLACE, GL_REPLACE, GL_REPLACE);
		}

		//int i; glGetIntegerv(GL_STENCIL_BITS, &i); writefln("GL_STENCIL_BITS: %d", i);

		if (state.clearFlags & ClearBufferMask.GU_DEPTH_BUFFER_BIT) {
			glEnable(GL_DEPTH_TEST);
			glDepthFunc(GL_ALWAYS);
			glDepthMask(true);
			glDepthRange(0.0, 0.0);

			//glDepthRange(0.0, 1.0); // Original value
		}

		glColorMask(ccolorMask, ccolorMask, ccolorMask, calphaMask);

		//glClearDepth(0.0); glClear(GL_COLOR_BUFFER_BIT);

		//if (state.clearFlags & ClearBufferMask.GU_COLOR_BUFFER_BIT) glClear(GL_DEPTH_BUFFER_BIT);
	}
	
	void drawBeginNormal(PrimitiveFlags flags) {
		void prepareTexture() {
			//writefln("prepareTexture[1]");
			if (!glEnableDisable(GL_TEXTURE_2D, state.texture.enabled)) {
				version (VERSION_ENABLED_STATE_CORTOCIRCUIT) return;
			}

			//glEnable(GL_BLEND);
			glActiveTexture(GL_TEXTURE0);
			glMatrixMode(GL_TEXTURE);
			
			if (state.vertexType.transform2D) {
				glLoadIdentity();
				glScalef(1.0f / cast(float)state.texture.mipmaps[0].width, 1.0f / cast(float)state.texture.mipmaps[0].height, 1);
			} else {
				final switch (state.texture.mapMode) {
					case TextureMapMode.GU_TEXTURE_COORDS:
						glLoadIdentity();
						glTranslatef(state.texture.offset.u, state.texture.offset.v, 0);
						glScalef(state.texture.scale.u, state.texture.scale.v, 1);
					break;
					case TextureMapMode.GU_TEXTURE_MATRIX:
						glLoadMatrixf(state.texture.matrix.pointer);
					break;
					case TextureMapMode.GU_ENVIRONMENT_MAP:
						Matrix envmapMatrix;
						envmapMatrix.setIdentity();
						
						for (int i = 0; i < 3; i++) {
							envmapMatrix.rows[0][i] = state.lighting.lights[state.texture.texShade[0]].position[i];
							envmapMatrix.rows[1][i] = state.lighting.lights[state.texture.texShade[1]].position[i];
						}
						
						glLoadMatrixf(envmapMatrix.pointer);
						Logger.log(Logger.Level.WARNING, "GPU", "Not implemented! texture for transform3D!");
					break;
				}
			}

			// @TODO! Based on BIAS.			
			//glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_BASE_LEVEL, level);
			//glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAX_LEVEL, level);
			
			//writefln("prepareTexture[2]");
			glEnable(GL_TEXTURE_2D);
			getTexture(state.texture, state.clut).bind();
			//writefln("tex0:%s", state.textureMipmaps[0]);
			
			//writefln("prepareTexture[3]");

			glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, (state.texture.filterMin == TextureFilter.GU_LINEAR) ? GL_LINEAR : GL_NEAREST);
			glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, (state.texture.filterMag == TextureFilter.GU_LINEAR) ? GL_LINEAR : GL_NEAREST);
			glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S,     (state.texture.wrapU     == WrapMode.GU_REPEAT     ) ? GL_REPEAT : GL_CLAMP_TO_EDGE);
			glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T,     (state.texture.wrapV     == WrapMode.GU_REPEAT     ) ? GL_REPEAT : GL_CLAMP_TO_EDGE);

			//glTexEnvf(GL_TEXTURE_ENV, GL_RGB_SCALE, 1.0); // 2.0 in scale_2x
			glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, TextureEnvModeTranslate[state.texture.effect]);
			
			//writefln("prepareTexture[4]");
		}
		
		void prepareBlend() {
			if (!glEnableDisable(GL_BLEND, state.blend.enabled)) {
				version (VERSION_ENABLED_STATE_CORTOCIRCUIT) return;
			}

			int getBlendFix(Colorf color) {
				if (color.isColorf(0, 0, 0)) return GL_ZERO;
				if (color.isColorf(1, 1, 1)) return GL_ONE;
				return GL_CONSTANT_COLOR;
			}

			int glFuncSrc = BlendFuncSrcTranslate[state.blend.funcSrc];
			int glFuncDst = BlendFuncDstTranslate[state.blend.funcDst];
			
			if (state.blend.funcSrc == BlendingFactor.GU_FIX) {
				glFuncSrc = getBlendFix(state.blend.fixColorSrc);
			}

			if (state.blend.funcDst == BlendingFactor.GU_FIX) {
				if ((glFuncSrc == GL_CONSTANT_COLOR) && (state.blend.fixColorSrc + state.blend.fixColorDst).isColorf(1, 1, 1)) {
					glFuncDst = GL_ONE_MINUS_CONSTANT_COLOR;
				} else {
					glFuncDst = getBlendFix(state.blend.fixColorDst);					
				}
			}
			
			// @CHECK @FIX
			glBlendEquationEXT(BlendEquationTranslate[state.blend.equation]);
			glBlendFunc(glFuncSrc, glFuncDst);
			
			// @TODO Must mix colors. 
			glBlendColor(
				state.blend.fixColorDst.r,
				state.blend.fixColorDst.g,
				state.blend.fixColorDst.b,
				state.blend.fixColorDst.a
			);
		}

		// http://www.openorg/sdk/docs/man/xhtml/glColorMaterial.xml
		// http://www.openorg/discussion_boards/ubbthreads.php?ubb=showflat&Number=238308
		void prepareColors() {
			//auto faces = GL_FRONT;
			auto faces = GL_FRONT_AND_BACK;
			
			//return;

			glEnableDisable(GL_COLOR_MATERIAL, flags.hasColor && cast(bool)state.materialColorComponents && state.lighting.enabled);

			glColor4fv(state.ambientModelColor.ptr);
			
			if (!flags.hasColor && state.lighting.enabled) {
				int flags;
				/*
				glMaterialfv(faces, GL_AMBIENT , [0.0f, 0.0f, 0.0f, 0.0f].ptr);
				glMaterialfv(faces, GL_DIFFUSE , [0.0f, 0.0f, 0.0f, 0.0f].ptr);
				glMaterialfv(faces, GL_SPECULAR, [0.0f, 0.0f, 0.0f, 0.0f].ptr);
				*/

				if (state.materialColorComponents & LightComponents.GU_AMBIENT)
				{
					glMaterialfv(GL_FRONT_AND_BACK, GL_AMBIENT,  state.ambientModelColor.ptr);
				}
				if (state.materialColorComponents & LightComponents.GU_DIFFUSE)
				{
					glMaterialfv(GL_FRONT_AND_BACK, GL_DIFFUSE,  state.diffuseModelColor.ptr);
				}
				if (state.materialColorComponents & LightComponents.GU_SPECULAR)
				{
					glMaterialfv(GL_FRONT_AND_BACK, GL_SPECULAR, state.specularModelColor.ptr);
				}

				if ((state.materialColorComponents & LightComponents.GU_AMBIENT) && (state.materialColorComponents & LightComponents.GU_DIFFUSE)) {
					flags = GL_AMBIENT_AND_DIFFUSE;
				} else if (state.materialColorComponents & LightComponents.GU_AMBIENT) {
					flags = GL_AMBIENT;
				} else if (state.materialColorComponents & LightComponents.GU_DIFFUSE) {
					flags = GL_DIFFUSE;
				} else if (state.materialColorComponents & LightComponents.GU_SPECULAR) {
					flags = GL_SPECULAR;
				} else {
					throw(new NotImplementedException("Error!"));
				}
				//flags = GL_SPECULAR;
            	glColorMaterial(GL_FRONT_AND_BACK, flags);
            	//glEnable(GL_COLOR_MATERIAL);
			}
			
			glMaterialfv(GL_FRONT_AND_BACK, GL_EMISSION, state.emissiveModelColor.ptr);
			//writefln("%s, %s, %s, %s", state.ambientModelColor, state.diffuseModelColor, state.specularModelColor, state.emissiveModelColor);
		}

		void prepareCulling() {
			if (state.vertexType.transform2D) {
				glDisable(GL_CULL_FACE);
			} else {
				if (!glEnableDisable(GL_CULL_FACE, state.backfaceCullingEnabled)) {
					version (VERSION_ENABLED_STATE_CORTOCIRCUIT) return;
				}

				glFrontFace(state.frontFaceDirection ? GL_CW : GL_CCW);
			}
		}

		void prepareScissor() {
			if (!glEnableDisable(GL_SCISSOR_TEST, !state.scissor.isFull)) {
				version (VERSION_ENABLED_STATE_CORTOCIRCUIT) return;
			}

			glScissor(
				state.scissor.x1,
				272 - state.scissor.y2,
				state.scissor.x2 - state.scissor.x1,
				state.scissor.y2 - state.scissor.y1
			);
		}

		void prepareLogicOp() {
			glEnableDisable(GL_COLOR_LOGIC_OP, state.logicalOperation.enabled);		
			glLogicOp(LogicalOperationTranslate[state.logicalOperation.operation]);
		}

		// http://jerome.jouvie.free.fr/OpenGl/Tutorials/Tutorial13.php
		// http://code.google.com/p/jpcsp/source/browse/trunk/src/jpcsp/graphics/VideoEngine.java
		// http://www.sjbaker.org/steve/omniv/opengl_lighting.html
		// http://www.sorgonet.com/linux/openglguide/parte2.html
		void prepareLighting() {
			if (!glEnableDisable(GL_LIGHTING, state.lighting.enabled) && (state.texture.mapMode != TextureMapMode.GU_ENVIRONMENT_MAP)) {
				version (VERSION_ENABLED_STATE_CORTOCIRCUIT) return;
			}
			
			glLightModeli(GL_LIGHT_MODEL_COLOR_CONTROL, state.lighting.lightModel ? GL_SEPARATE_SPECULAR_COLOR : GL_SINGLE_COLOR);
			glLightModelfv(GL_LIGHT_MODEL_AMBIENT, state.lighting.ambientLightColor.ptr);

			foreach (n, ref light; state.lighting.lights) {
				auto GL_LIGHT_n = GL_LIGHT0 + n;

				if (!glEnableDisable(GL_LIGHT_n, light.enabled)) {
					version (VERSION_ENABLED_STATE_CORTOCIRCUIT) continue;
				}
				
				/*
				if (light.kind == LightComponents.GU_DIFFUSE_AND_SPECULAR) {
				} else {
					glLightfv(GL_LIGHT_n, GL_SPECULAR , [0.0f, 0, 0, 0].ptr);
				}
				*/
				glLightfv(GL_LIGHT_n, GL_SPECULAR , light.specularColor.pointer);
				glLightfv(GL_LIGHT_n, GL_AMBIENT  , light.ambientColor.pointer);
				glLightfv(GL_LIGHT_n, GL_DIFFUSE  , light.diffuseColor.pointer);

				light.position.t = 1.0;
				glLightfv(GL_LIGHT_n, GL_POSITION , light.position.pointer);
				
				glLightf(GL_LIGHT_n, GL_CONSTANT_ATTENUATION , light.attenuation.constant);
				glLightf(GL_LIGHT_n, GL_LINEAR_ATTENUATION   , light.attenuation.linear);
				glLightf(GL_LIGHT_n, GL_QUADRATIC_ATTENUATION, light.attenuation.quadratic);

				if (light.type == LightType.GU_SPOTLIGHT) {
					glLightfv(GL_LIGHT_n, GL_SPOT_DIRECTION , light.spotDirection.pointer);
					glLightf (GL_LIGHT_n, GL_SPOT_EXPONENT  , light.spotExponent);
					glLightf (GL_LIGHT_n, GL_SPOT_CUTOFF    , light.spotCutoff);
				} else {
					glLightf (GL_LIGHT_n, GL_SPOT_EXPONENT  , 0);
					glLightf (GL_LIGHT_n, GL_SPOT_CUTOFF    , 180);
				}
				
				//writefln("ambientColor : %f, %f, %f, %f", light.ambientColor.pointer[0], light.ambientColor.pointer[1], light.ambientColor.pointer[2], light.ambientColor.pointer[3]);
				//writefln("diffuseColor : %f, %f, %f, %f", light.diffuseColor.pointer[0], light.diffuseColor.pointer[1], light.diffuseColor.pointer[2], light.diffuseColor.pointer[3]);
				//writefln("specularColor: %f, %f, %f, %f", light.specularColor.pointer[0], light.specularColor.pointer[1], light.specularColor.pointer[2], light.specularColor.pointer[3]);
				//writefln("LIGHT(%d) : %s", n, light);
			}
		}
		
		void prepareAlphaTest() {
			if (!glEnableDisable(GL_ALPHA_TEST, state.alphaTest.enabled)) {
				version (VERSION_ENABLED_STATE_CORTOCIRCUIT) return;
			}

			glAlphaFunc(
				TestTranslate[state.alphaTest.func],
				state.alphaTest.value
			);
		}
		
		void prepareDepth() {
			glDepthRange(state.depth.rangeFar, state.depth.rangeNear);
		}

		// http://www.openorg/resources/faq/technical/depthbuffer.htm
		void prepareDepthTest() {
			//return;

			if (!glEnableDisable(GL_DEPTH_TEST, state.depth.testEnabled)) {
				version (VERSION_ENABLED_STATE_CORTOCIRCUIT) return;
			}
			glDepthFunc(TestTranslate[state.depth.testFunc]);
		}
		
		void prepareDepthWrite() {
			//return;
			
			glDepthMask(state.depth.mask == 0);

			if (state.depth.mask) {
				version (VERSION_ENABLED_STATE_CORTOCIRCUIT) return;
			}

			//glDepthRange(state.depthRangeNear, state.depthRangeFar);
		}

		void prepareStencil() {
			if (!glEnableDisable(GL_STENCIL_TEST, state.stencil.testEnabled)) {
				version (VERSION_ENABLED_STATE_CORTOCIRCUIT) return;
			}

			//if (state.stencilFuncFunc == 2) { outputDepthAndStencil(); assert(0); }
			
			glStencilFunc(
				TestTranslate[state.stencil.funcFunc],
				state.stencil.funcRef,
				state.stencil.funcMask
			);
			
			glStencilOp(
				StencilOperationTranslate[state.stencil.operationSfail ],
				StencilOperationTranslate[state.stencil.operationDpfail],
				StencilOperationTranslate[state.stencil.operationDppass]
			);
		}

		void prepareFog() {
			if (!glEnableDisable(GL_FOG, state.fog.enabled)) {
				version (VERSION_ENABLED_STATE_CORTOCIRCUIT) return;
			}
			
			glFogi(GL_FOG_MODE, GL_LINEAR);
			//glFogf(GL_FOG_DENSITY, 0.35);
			glHint(GL_FOG_HINT, GL_DONT_CARE);

			glFogfv(GL_FOG_COLOR, state.fog.color.pointer);
			
			if (state.fog.dist != 0.0) {
				glFogf(GL_FOG_START, state.fog.end - (1 / state.fog.dist));
				glFogf(GL_FOG_END, state.fog.end);
			}
				
			//writefln("%f, %f", state.fog.end - (1 / state.fog.dist), state.fog.end);
		}

		//glEnable(GL_NORMALIZE);
		//glColorMask(cast(bool)state.colorMask[0], cast(bool)state.colorMask[1], cast(bool)state.colorMask[2], cast(bool)state.colorMask[3]);
		glColorMask(true, true, true, true);
		glEnableDisable(GL_LINE_SMOOTH, state.lineSmoothEnabled);
		glShadeModel(state.shadeModel ? GL_SMOOTH : GL_FLAT);
		glMaterialf(GL_FRONT, GL_SHININESS, state.lighting.specularPower);
		glTexEnvfv(GL_TEXTURE_ENV, GL_TEXTURE_ENV_COLOR, state.textureEnviromentColor.ptr);
		
		prepareStencil();
		prepareScissor();
		prepareBlend();
		prepareCulling();
		prepareTexture();
		prepareLogicOp();
		prepareAlphaTest();
		prepareDepth();
		prepareDepthTest();
		prepareDepthWrite();
		prepareFog();
		prepareLighting();
		prepareColors();
	}
	
	void implInit() {
		glHint(GL_LINE_SMOOTH_HINT, GL_NICEST);
		glTexEnvi(GL_TEXTURE_ENV, GL_COMBINE_RGB, GL_MODULATE);
		glTexEnvi(GL_TEXTURE_ENV, GL_SOURCE0_RGB, GL_TEXTURE);
		glTexEnvi(GL_TEXTURE_ENV, GL_OPERAND0_RGB, GL_SRC_COLOR);
		glTexEnvi(GL_TEXTURE_ENV, GL_SOURCE1_RGB, GL_PREVIOUS);
		glTexEnvi(GL_TEXTURE_ENV, GL_OPERAND1_RGB, GL_SRC_COLOR);
		glTexEnvi(GL_TEXTURE_ENV, GL_COMBINE_ALPHA, GL_REPLACE);
		glTexEnvi(GL_TEXTURE_ENV, GL_SOURCE0_ALPHA, GL_PREVIOUS);
		glTexEnvi(GL_TEXTURE_ENV, GL_OPERAND0_ALPHA, GL_SRC_ALPHA);
		glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_COMBINE);
	}

	void drawBegin(PrimitiveFlags flags) {
		setStateStopWatch.start();
		scope (exit) setStateStopWatch.stop();
		
		version (VERSION_ENABLED_STATE_CORTOCIRCUIT_EX) {
			// @TODO: To avoid checking the whole struct, we could increment a uint inside the struct, every time we preform an update.
			// If that value has changed, then check the whole state.
			if (prevState.RealState == (*state).RealState && (flags == prevPrimitiveFlags)) {
				//prepareTexture();
				//if (state.textureMappingEnabled) getTexture(state.textures[0], state.clut).bind();
				return;
			}
		}
		
		// @TEMP @HACK
		//state.depth.testEnabled = false;
		//state.alphaTest.enabled = false;

		//writefln("drawBegin[1]");
		if (state.clearingMode) {
			//writefln("drawBegin[1a]");
			drawBeginClear(flags);
		} else {
			//writefln("drawBegin[1b]");
			drawBeginNormal(flags);
		}
		//writefln("drawBegin[2]");
		drawBeginCommon();
		//writefln("drawBegin[3]");
	}
	
	void drawEnd(PrimitiveFlags flags) {
		prevState = *state;
		prevPrimitiveFlags = flags;
	}
}

/*
version (unittest) {
	import core.thread;
}

// cls && dmd ..\..\..\utils\opend ..\types.d -version=TEST_GPUOPENGL -unittest -run GpuOpend
unittest {
	auto gpuImpl = new GpuOpengl;
	(new Thread({
		gpuImpl.init();
	})).start();
}
version (TEST_GPUOPENGL) static void main() {}
*/