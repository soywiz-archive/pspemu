module pspemu.core.gpu.impl.GpuOpengl;

// http://www.opengl.org/resources/code/samples/win32_tutorial/wglinfo.c

//version = VERSION_GL_BITMAP_RENDERING;

import std.c.windows.windows;
import std.windows.syserror;
import std.stdio;

import pspemu.utils.Utils;

import std.contracts;

import pspemu.utils.OpenGL;

import pspemu.core.Memory;
import pspemu.core.gpu.Types;
import pspemu.core.gpu.GpuState;
import pspemu.core.gpu.GpuImpl;
import pspemu.utils.Math;

import pspemu.core.gpu.impl.GpuOpenglUtils;

class GpuOpengl : GpuImplAbstract {
	mixin OpenglBase;
	mixin OpenglUtils;

	/// Previous state to check changes in the new state and perform new operations.
	GpuState prevState;
	glProgram program;

	glUniform gla_tex;
	glUniform gla_clut;
	glUniform gla_clutOffset;
	glUniform gla_clutUse;
	glUniform gla_textureUse;
	
	void init() {
		openglInit();
		openglPostInit();
		program = new glProgram();
		program.attach(new glFragmentShader(import("shader.fragment")));
		program.attach(new glVertexShader(import("shader.vertex")));
		program.link();
		//program.use();

		/*
		gla_tex          = program.getUniform("tex");
		gla_clut         = program.getUniform("clut");
		gla_clutOffset   = program.getUniform("clutOffset");
		gla_clutUse      = program.getUniform("clutUse");
		gla_textureUse   = program.getUniform("textureUse");
		*/

		//program.use(0);
	}

	void reset() {
		textureCache = null;
	}

	void startDisplayList() {
		// Here we should invalidate texture cache? and recheck hashes of the textures?
		foreach (texture; textureCache) {
			texture.markForRecheck = true;
		}
	}

	void endDisplayList() {
	}

	void clear() {
		uint flags = 0;
		if (state.clearFlags & 0x100) flags |= GL_COLOR_BUFFER_BIT; // target
		if (state.clearFlags & 0x200) flags |= GL_ACCUM_BUFFER_BIT | GL_STENCIL_BUFFER_BIT; // stencil/alpha
		if (state.clearFlags & 0x400) flags |= GL_DEPTH_BUFFER_BIT; // zbuffer
		glClear(flags);
	}

	void draw(VertexState[] vertexList, PrimitiveType type, PrimitiveFlags flags) {
		/*
		static if (1) {
			writefln("type:%d, vertexcount:%d, flags:%d", type, vertexList.length, flags);
			writefln("  %s", vertexList[0]);
			writefln("  %s", vertexList[1]);
		}
		*/
	
		void putVertex(ref VertexState vertex) {
			if (flags.hasTexture ) glTexCoord2f(vertex.u, vertex.v);
			if (flags.hasColor   ) glColor4f(vertex.r, vertex.g, vertex.b, vertex.a);
			if (flags.hasNormal  ) glNormal3f(vertex.nx, vertex.ny, vertex.nz);
			if (flags.hasPosition) glVertex3f(vertex.px, vertex.py, vertex.pz);
			//writefln("UV(%f, %f)", vertex.u, vertex.v);
			//writefln("POS(%f, %f, %f)", vertex.px, vertex.py, vertex.pz);
		}

		drawBegin();
		{
			switch (type) {
				// Special primitive that doesn't have equivalent in OpenGL.
				// With two points specify a GL_QUAD.
				// http://www.opengl.org/registry/specs/ARB/point_sprite.txt
				// http://cirl.missouri.edu/gpu/glsl_lessons/glsl_geometry_shader/index.html
				case PrimitiveType.GU_SPRITES:
					static string spriteVertexInterpolate(string vx, string vy) {
						string s;
						s ~= "vertex.px = " ~ vx ~ ".px; vertex.py = " ~ vy ~ ".py;";
						s ~= "vertex.nx = " ~ vx ~ ".px; vertex.ny = " ~ vy ~ ".py;";
						s ~= "vertex.u  = " ~ vx ~ ".u ; vertex.v  = " ~ vy ~ ".v;";
						return s;
					}

					glPushAttrib(GL_CULL_FACE);
					{
						glDisable(GL_CULL_FACE);
						glBegin(GL_QUADS);
						{
							for (int n = 0; n < vertexList.length; n += 2) {
								VertexState v1 = vertexList[n + 0], v2 = vertexList[n + 1], vertex = void;
								vertex = v1;
								
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
				// Normal primitives that have equivalent in OpenGL.
				default: {
					glBegin(PrimitiveTypeTranslate[type]);
					{
						foreach (ref vertex; vertexList) putVertex(vertex);
					}
					glEnd();
				} break;
			}
		}
		drawEnd();
	}

	void flush() {
		glFlush();
	}

	void frameLoad(void* buffer) {
		//bitmapData[0..512 * 272] = (cast(uint *)drawBufferAddress)[0..512 * 272];
		glDrawPixels(
			state.drawBuffer.width, 272,
			GlPixelFormats[state.drawBuffer.format].external,
			GlPixelFormats[state.drawBuffer.format].opengl,
			buffer
		);
	}
	
	version (VERSION_GL_BITMAP_RENDERING) {
	} else {
		ubyte[4 * 512 * 272] buffer_temp;
	}

	void frameStore(void* buffer) {
		//(cast(uint *)drawBufferAddress)[0..512 * 272] = bitmapData[0..512 * 272];
		glPixelStorei(GL_UNPACK_ALIGNMENT, cast(int)GlPixelFormats[state.drawBuffer.format].size);
		//writefln("%d, %d", state.drawBuffer.width, 272);
		glReadPixels(
			0, 0, // x, y
			state.drawBuffer.width, 272, // w, h
			GlPixelFormats[state.drawBuffer.format].external,
			GlPixelFormats[state.drawBuffer.format].opengl,
			&buffer_temp
		);
		for (int n = 0; n < 272; n++) {
			int m = 271 - n;
			state.drawBuffer.row(buffer, n)[] = state.drawBuffer.row(&buffer_temp, m)[];
		}
	}
}

template OpenglUtils() {
	Texture[string] textureCache;
	//Clut[uint] clutCache;
	
	bool glEnableDisable(int type, bool enable) {
		if (enable) glEnable(type); else glDisable(type);
		return enable;
	}

	Texture getTexture(TextureState textureState, ClutState clutState) {
		Texture texture = void;
		string hash = textureState.toString ~ clutState.toString;
		if ((hash in textureCache) is null) {
			texture = new Texture();
			textureCache[hash] = texture;
		} else {
			texture = textureCache[hash];
		}
		texture.update(state.memory, textureState, clutState);
		return texture;
	}

	void drawBegin() {
		void prepareMatrix() {
			if (state.vertexType.transform2D) {
				glMatrixMode(GL_PROJECTION); glLoadIdentity();
				glOrtho(0.0f, 512.0f, 272.0f, 0.0f, -1.0f, 1.0f);
				glMatrixMode(GL_MODELVIEW); glLoadIdentity();
				//writefln("transform");
			} else {
				//writefln("no transform");
				glMatrixMode(GL_PROJECTION); glLoadIdentity();
				glMultMatrixf(state.projectionMatrix.pointer);

				glMatrixMode(GL_MODELVIEW); glLoadIdentity();
				glMultMatrixf(state.viewMatrix.pointer);
				glMultMatrixf(state.worldMatrix.pointer);
			}
			/*
			writefln("Projection:\n%s", state.projectionMatrix);
			writefln("View:\n%s", state.viewMatrix);
			writefln("World:\n%s", state.worldMatrix);
			*/
		}

		void prepareTexture() {
			if (!glEnableDisable(GL_TEXTURE_2D, state.textureMappingEnabled)) return;

			//glEnable(GL_BLEND);
			glActiveTexture(GL_TEXTURE0);
			glMatrixMode(GL_TEXTURE);
			glLoadIdentity();
			
			if (state.vertexType.transform2D && (state.textureScale.u == 1 && state.textureScale.v == 1)) {
				glScalef(1.0f / state.textures[0].width, 1.0f / state.textures[0].height, 1);
			} else {
				glScalef(state.textureScale.u, state.textureScale.v, 1);
			}
			glTranslatef(state.textureOffset.u, state.textureOffset.v, 0);
			
			if (state.textureMappingEnabled) {
				glEnable(GL_TEXTURE_2D);
				getTexture(state.textures[0], state.clut).bind();
				//writefln("tex0:%s", state.textures[0]);

				glEnable(GL_CLAMP_TO_EDGE);
				glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, state.textureFilterMin ? GL_LINEAR : GL_NEAREST);
				glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, state.textureFilterMag ? GL_LINEAR : GL_NEAREST);
				glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, state.textureWrapS);
				glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, state.textureWrapT);

				glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, TextureEnvModeTranslate[state.textureEnvMode]);

			} else {
				glDisable(GL_TEXTURE_2D);
			}
		}
		
		void prepareStencil() {
			if (!glEnableDisable(GL_STENCIL_TEST, state.stencilTestEnabled)) return;

			//writefln("%d, %d, %d", state.stencilFuncFunc, state.stencilFuncRef, state.stencilFuncMask);
			glStencilFunc(
				TestTranslate[state.stencilFuncFunc],
				state.stencilFuncRef,
				state.stencilFuncMask
			);
			//glCheckError();

			glStencilOp(
				StencilOperationTranslate[state.stencilOperationSfail ],
				StencilOperationTranslate[state.stencilOperationDpfail],
				StencilOperationTranslate[state.stencilOperationDppass]
			);
			//glCheckError();
		}

		void prepareBlend() {
			if (!glEnableDisable(GL_BLEND, state.alphaBlendEnabled)) return;

			glBlendEquation(BlendEquationTranslate[state.blendEquation]);
			glBlendFunc(BlendFuncSrcTranslate[state.blendFuncSrc], BlendFuncDstTranslate[state.blendFuncDst]);
		}

		void prepareColors() {
			glEnableDisable(GL_COLOR_LOGIC_OP, state.logicalOperationEnabled);
			glColor4fv(state.ambientModelColor.ptr);
		}

		void prepareCulling() {
			if (!glEnableDisable(GL_CULL_FACE, state.backfaceCullingEnabled)) return;

			glFrontFace(state.faceCullingOrder ? GL_CW : GL_CCW);
		}

		void prepareScissor() {
			if ((state.scissor.x1 <= 0 && state.scissor.y1 <= 0) && (state.scissor.x2 >= 480 && state.scissor.y2 >= 272)) {
				glDisable(GL_SCISSOR_TEST);
				return;
			}

			glEnable(GL_SCISSOR_TEST);
			glScissor(
				state.scissor.x1,
				272 - state.scissor.y2,
				state.scissor.x2 - state.scissor.x1,
				state.scissor.y2 - state.scissor.y1
			);
		}

		void prepareLogicOp() {
			glLogicOp(LogicalOperationTranslate[state.logicalOperation]);
		}

		// http://jerome.jouvie.free.fr/OpenGl/Tutorials/Tutorial13.php
		void prepareLighting() {
			return; // @TODO. Temporary disabled.

			if (!glEnableDisable(GL_LIGHTING, state.lightingEnabled)) return;

			for (int n = 0; n < 4; n++) {
				LightState* light = &state.lights[n];
				if (!glEnableDisable(GL_LIGHT0 + n, light.enabled)) continue;

				glLightfv(GL_LIGHT0 + n, GL_POSITION , light.position.pointer);

				glLightfv(GL_LIGHT0 + n, GL_AMBIENT  , light.ambientLightColor.pointer);
				glLightfv(GL_LIGHT0 + n, GL_DIFFUSE  , light.diffuseLightColor.pointer);
				glLightfv(GL_LIGHT0 + n, GL_SPECULAR , light.specularLightColor.pointer);

				// Spot.
				glLightfv(GL_LIGHT0 + n, GL_SPOT_DIRECTION, light.spotDirection.pointer);
				glLightfv(GL_LIGHT0 + n, GL_SPOT_EXPONENT , &light.spotLightExponent);
				glLightfv(GL_LIGHT0 + n, GL_SPOT_CUTOFF   , &light.spotLightCutoff);
			}
		}
		
		void prepareAlphaTest() {
			if (!glEnableDisable(GL_ALPHA_TEST, state.alphaTestEnabled)) return;

			glAlphaFunc(
				TestTranslate[state.alphaTestFunc],
				state.alphaTestValue
			);
		}
		
		void prepareDepthTest() {
			if (!glEnableDisable(GL_DEPTH_TEST, state.depthTestEnabled)) return;
		}
		

		glShadeModel(state.shadeModel ? GL_SMOOTH : GL_FLAT);
		glDepthMask(state.depthMask);
		glDepthFunc(TestTranslate[state.depthFunc]);
		glDepthRange(state.depthRangeNear, state.depthRangeFar);
		//writefln("%d, %f, %f", state.depthFunc, state.depthRangeNear, state.depthRangeFar);

		prepareMatrix();
		prepareStencil();
		prepareScissor();
		prepareBlend();
		prepareCulling();
		prepareColors();
		prepareTexture();
		prepareLighting();
		prepareLogicOp();
		prepareAlphaTest();
		prepareDepthTest();
		
		glFogfv(GL_FOG_COLOR, state.fogColor.pointer);
		glFogf(GL_FOG_START, state.fogEnd - (1 / state.fogDist));
		glFogf(GL_FOG_END, state.fogEnd);
	}
	
	void drawEnd() {
		prevState = *state;
	}
}

class Texture {
	GLuint gltex;
	bool markForRecheck;
	bool refreshAnyway;
	uint textureHash, clutHash;
	
	this() {
		glGenTextures(1, &gltex);
		markForRecheck = true;
		refreshAnyway = true;
	}

	~this() {
		glDeleteTextures(1, &gltex);
	}

	void bind() {
		glEnable(GL_TEXTURE_2D);
		glBindTexture(GL_TEXTURE_2D, gltex);
	}

	void update(Memory memory, ref TextureState textureState, ref ClutState clutState) {
		if (markForRecheck || refreshAnyway) {
			ubyte[] emptyBuffer;

			auto textureData = textureState.address ? (cast(ubyte*)memory.getPointer(textureState.address))[0..textureState.totalSize] : emptyBuffer;
			//auto clutData    = clutState.address    ? (cast(ubyte*)memory.getPointer(clutState.address))[0..textureState.paletteRequiredComponents] : emptyBuffer;
			auto clutData    = clutState.address ? clutState.data : emptyBuffer;
		
			if (markForRecheck) {
				markForRecheck = false;

				auto currentTextureHash = std.zlib.crc32(textureState.address, textureData);
				if (currentTextureHash != textureHash) {
					textureHash = currentTextureHash;
					refreshAnyway = true;
				}

				auto currentClutHash = std.zlib.crc32(clutState.address, clutData);
				if (currentClutHash != clutHash) {
					clutHash = currentClutHash;
					refreshAnyway = true;
				}
			}
			
			if (refreshAnyway) {
				refreshAnyway = false;
				updateActually(textureData, clutData, textureState, clutState);
				//writefln("texture updated");
			} else {
				//writefln("texture reuse");
			}
		}
	}

	void updateActually(ubyte[] textureData, ubyte[] clutData, ref TextureState textureState, ref ClutState clutState) {
		auto texturePixelFormat = GlPixelFormats[textureState.format];
		auto clutPixelFormat    = GlPixelFormats[clutState.format];
		GlPixelFormat* glPixelFormat;
		static ubyte[] textureDataUnswizzled, textureDataWithPaletteApplied;

		writefln("Updated: %s", textureState);
		if (textureState.hasPalette) writefln("  %s", clutState);

		glActiveTexture(GL_TEXTURE0);
		bind();

		// Unswizzle texture.
		if (textureState.swizzled) {
			//writefln("swizzled: %d, %d", textureDataUnswizzled.length, textureData.length);
			if (textureDataUnswizzled.length < textureData.length) textureDataUnswizzled.length = textureData.length;

			unswizzle(textureData, textureDataUnswizzled[0..textureData.length], textureState);
			textureData = textureDataUnswizzled[0..textureData.length];
		}

		if (textureState.hasPalette) {
			int textureSizeWithPaletteApplied = PixelFormatSize(clutState.format, textureState.width * textureState.height);
			//writefln("palette: %d, %d", textureDataWithPaletteApplied.length, textureSizeWithPaletteApplied);
			if (textureDataWithPaletteApplied.length < textureSizeWithPaletteApplied) textureDataWithPaletteApplied.length = textureSizeWithPaletteApplied;
			applyPalette(textureData, clutData, textureDataWithPaletteApplied.ptr, textureState, clutState);
			textureData = textureDataWithPaletteApplied[0..textureSizeWithPaletteApplied];
			glPixelFormat = cast(GlPixelFormat *)&clutPixelFormat;
		} else {
			glPixelFormat = cast(GlPixelFormat *)&texturePixelFormat;
		}

		// @TODO: Check this!
		glPixelStorei(GL_UNPACK_ALIGNMENT, cast(int)glPixelFormat.size);
		glPixelStorei(GL_UNPACK_ROW_LENGTH, textureState.buffer_width);
		//glPixelStorei(GL_UNPACK_ROW_LENGTH, PixelFormatUnpackSize(textureState.format, textureState.buffer_width) / 2);
		
		glTexImage2D(
			GL_TEXTURE_2D,
			0,
			glPixelFormat.internal,
			textureState.width,
			textureState.height,
			0,
			glPixelFormat.external,
			glPixelFormat.opengl,
			textureData.ptr
		);

		//writefln("update(%d) :: %08X, %s, %d", gltex, textureData.ptr, textureState, textureState.totalSize);
	}

	static void unswizzle(ubyte[] inData, ubyte[] outData, ref TextureState textureState) {
		int rowWidth = textureState.rwidth;
		int pitch    = (rowWidth - 16) / 4;
		int bxc      = rowWidth / 16;
		int byc      = textureState.height / 8;

		uint* src = cast(uint*)inData.ptr;
		
		auto ydest = outData.ptr;
		for (int by = 0; by < byc; by++) {
			auto xdest = ydest;
			for (int bx = 0; bx < bxc; bx++) {
				auto dest = cast(uint*)xdest;
				for (int n = 0; n < 8; n++, dest += pitch) {
					*(dest++) = *(src++);
					*(dest++) = *(src++);
					*(dest++) = *(src++);
					*(dest++) = *(src++);
				}
				xdest += 16;
			}
			ydest += rowWidth * 8;
		}
	}

	static void applyPalette(ubyte[] textureData, ubyte[] clutData, ubyte* textureDataWithPaletteApplied, ref TextureState textureState, ref ClutState clutState) {
		uint clutEntrySize = clutState.colorEntrySize;
		void writeValue(uint index) {
			textureDataWithPaletteApplied[0..clutEntrySize] = (clutData.ptr + index * clutEntrySize)[0..clutEntrySize];
			textureDataWithPaletteApplied += clutEntrySize;
		}
		switch (textureState.format) {
			case PixelFormats.GU_PSM_T4:
				foreach (indexes; textureData) {
					writeValue((indexes >> 0) & 0xF);
					writeValue((indexes >> 4) & 0xF);
				}
			break;
			case PixelFormats.GU_PSM_T8: foreach (index; textureData) writeValue(index); break;
			case PixelFormats.GU_PSM_T16: foreach (index; cast(ushort[])textureData) writeValue(index); break;
			case PixelFormats.GU_PSM_T32: foreach (index; cast(uint[])textureData) writeValue(index); break;
		}
	}
}

/*
version (unittest) {
	import core.thread;
}

// cls && dmd ..\..\..\utils\opengl.d ..\types.d -version=TEST_GPUOPENGL -unittest -run GpuOpengl.d
unittest {
	auto gpuImpl = new GpuOpengl;
	(new Thread({
		gpuImpl.init();
	})).start();
}
version (TEST_GPUOPENGL) static void main() {}
*/