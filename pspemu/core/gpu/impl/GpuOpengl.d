module pspemu.core.gpu.impl.GpuOpengl;

/*
http://code.google.com/p/jpcsp/source/browse/trunk/src/jpcsp/graphics/VideoEngine.java
http://code.google.com/p/pspemu/source/browse/branches/old/src/core/gpu.d
http://code.google.com/p/pspplayer/source/browse/trunk/Noxa.Emulation.Psp.Video.OpenGL/OglDriver_Processing.cpp
*/

//debug = DEBUG_CLEAR_MODE;

version = VERSION_HOLD_DEPTH_BUFFER_IN_MEMORY;
version = VERSION_ENABLED_STATE_CORTOCIRCUIT;
version = VERSION_ENABLED_STATE_CORTOCIRCUIT_EX;

//debug = DEBUG_OUTPUT_DEPTH_AND_STENCIL;
//debug = DEBUG_PRIM_PERFORMANCE;

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
import pspemu.core.gpu.impl.GpuOpenglTexture;

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
		setVSync(0);
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
		debug (DEBUG_PRIM_PERFORMANCE) writefln("-");

		// Here we should invalidate texture cache? and recheck hashes of the textures?
		foreach (texture; textureCache) {
			texture.markForRecheck = true;
		}
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

	void clear() {
		/*
		uint flags = 0;
		if (state.clearFlags & ClearBufferMask.GU_COLOR_BUFFER_BIT  ) flags |= GL_COLOR_BUFFER_BIT; // target
		if (state.clearFlags & ClearBufferMask.GU_STENCIL_BUFFER_BIT) flags |= GL_ACCUM_BUFFER_BIT | GL_STENCIL_BUFFER_BIT; // stencil/alpha
		if (state.clearFlags & ClearBufferMask.GU_DEPTH_BUFFER_BIT  ) flags |= GL_DEPTH_BUFFER_BIT; // zbuffer
		
		//glClear(flags);
		//writefln("clear: %08b", state.clearFlags );
		*/
	}

	void draw(VertexState[] vertexList, PrimitiveType type, PrimitiveFlags flags) {
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
			if (flags.hasColor   ) glColor4f(vertex.r, vertex.g, vertex.b, vertex.a);
			if (flags.hasNormal  ) glNormal3f(vertex.nx, vertex.ny, vertex.nz);
			if (flags.hasPosition) glVertex3f(vertex.px, vertex.py, vertex.pz);
			//writefln("UV(%f, %f)", vertex.u, vertex.v);
			debug (DEBUG_CLEAR_MODE) if (state.clearingMode) writefln("POS(%f, %f, %f) : COL(%f, %f, %f, %f)", vertex.px, vertex.py, vertex.pz, vertex.r, vertex.g, vertex.b, vertex.a);
		}
		
		debug (DEBUG_CLEAR_MODE) if (state.clearingMode) writefln("--");

		drawBegin();
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
						return s;
					}

					glPushAttrib(GL_CULL_FACE);
					{
						glDisable(GL_CULL_FACE);
						glBegin(GL_QUADS);
						{
							for (int n = 0; n < vertexList.length; n += 2) {
								VertexState v1 = vertexList[n + 0], v2 = vertexList[n + 1], vertex = void;
								vertex = v2;
								
								debug (DEBUG_CLEAR_MODE) if (state.clearingMode) writefln("(%f,%f,%f)-(%f,%f,%f)", v1.px, v1.py, v1.pz, v2.px, v2.py, v2.pz);
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

	// http://hitmen.c02.at/files/yapspd/psp_doc/chap10.html#sec10
	// @TODO @FIXME - Depth should be swizzled.

	void frameLoad(void* colorBuffer, void* depthBuffer) {
		//return;
		if (colorBuffer !is null) {
			//bitmapData[0..512 * 272] = (cast(uint *)drawBufferAddress)[0..512 * 272];
			glDrawPixels(
				state.drawBuffer.width, 272,
				GlPixelFormats[state.drawBuffer.format].external,
				GlPixelFormats[state.drawBuffer.format].opengl,
				colorBuffer
			);
		}
		
		version (VERSION_HOLD_DEPTH_BUFFER_IN_MEMORY) {
			if ((depthBuffer !is null) && (colorBuffer != depthBuffer)) {
				glDrawPixels(
					state.depthBuffer.width, 272,
					GL_DEPTH_COMPONENT,
					GL_UNSIGNED_SHORT,
					colorBuffer
				);
			}
		}
	}
	
	version (VERSION_GL_BITMAP_RENDERING) {
	} else {
		ubyte[4 * 512 * 272] colorBufferTemp;
	}
	
	void outputDepthAndStencil() {
		scope temp = new ubyte[1024 * 1024];
		glPixelStorei(GL_UNPACK_ALIGNMENT, 1);
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
	}

	void frameStore(void* colorBuffer, void* depthBuffer) {
		//return;
		if (colorBuffer !is null) {
			//(cast(uint *)drawBufferAddress)[0..512 * 272] = bitmapData[0..512 * 272];
			glPixelStorei(GL_UNPACK_ALIGNMENT, cast(int)GlPixelFormats[state.drawBuffer.format].size);
			//writefln("%d, %d", state.drawBuffer.width, 272);
			glReadPixels(
				0, 0, // x, y
				state.drawBuffer.width, 272, // w, h
				GlPixelFormats[state.drawBuffer.format].external,
				GlPixelFormats[state.drawBuffer.format].opengl,
				&colorBufferTemp
			);
			for (int n = 0; n < 272; n++) {
				int m = 271 - n;
				state.drawBuffer.row(colorBuffer, n)[] = state.drawBuffer.row(&colorBufferTemp, m)[];
			}
		}

		version (VERSION_HOLD_DEPTH_BUFFER_IN_MEMORY) {
			if ((depthBuffer !is null) && (colorBuffer != depthBuffer)) {
				glPixelStorei(GL_UNPACK_ALIGNMENT, 1);
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
	
	void drawBeginCommon() {
		void prepareMatrix() {
			if (state.vertexType.transform2D) {
				glMatrixMode(GL_PROJECTION); glLoadIdentity();
				glOrtho(0.0f, 512.0f, 272.0f, 0.0f, -1.0f, 1.0f);
				glMatrixMode(GL_MODELVIEW); glLoadIdentity();
			} else {
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

		prepareMatrix();
	}

	void drawBeginClear() {
		bool ccolorMask, calphaMask;
		
		//glGetTexEnvfv(GL_TEXTURE_ENV, GL_RGB_SCALE, clearModeRgbScale, 0);
		//glGetTexEnviv(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, clearModeTextureEnvMode, 0);
		//glTexEnvf(GL_TEXTURE_ENV, GL_RGB_SCALE, 1.0f);
		//glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_REPLACE);

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

		//glClearDepth(0.0); glClear(GL_DEPTH_BUFFER_BIT);

		//glClear(GL_DEPTH_BUFFER_BIT | GL_STENCIL_BUFFER_BIT);
	}
	
	void drawBeginNormal() {
		void prepareTexture() {
			if (!glEnableDisable(GL_TEXTURE_2D, state.textureMappingEnabled)) {
				version (VERSION_ENABLED_STATE_CORTOCIRCUIT) return;
			}

			//glEnable(GL_BLEND);
			glActiveTexture(GL_TEXTURE0);
			glMatrixMode(GL_TEXTURE);
			glLoadIdentity();
			
			if (state.vertexType.transform2D && (state.textureScale.uv == Vector(1.0, 1.0))) {
				glScalef(1.0f / state.textures[0].width, 1.0f / state.textures[0].height, 1);
			} else {
				glScalef(state.textureScale.u, state.textureScale.v, 1);
			}
			glTranslatef(state.textureOffset.u, state.textureOffset.v, 0);
			
			glEnable(GL_TEXTURE_2D);
			getTexture(state.textures[0], state.clut).bind();
			//writefln("tex0:%s", state.textures[0]);

			glEnable(GL_CLAMP_TO_EDGE);
			glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, state.textureFilterMin ? GL_LINEAR : GL_NEAREST);
			glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, state.textureFilterMag ? GL_LINEAR : GL_NEAREST);
			glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, state.textureWrapU);
			glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, state.textureWrapV);

			glTexEnvf(GL_TEXTURE_ENV, GL_RGB_SCALE, 1.0); // 2.0 in scale_2x
			glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, TextureEnvModeTranslate[state.textureEffect]);
		}
		
		void prepareBlend() {
			if (!glEnableDisable(GL_BLEND, state.alphaBlendEnabled)) {
				version (VERSION_ENABLED_STATE_CORTOCIRCUIT) return;
			}

			glBlendEquation(BlendEquationTranslate[state.blendEquation]);
			glBlendFunc(BlendFuncSrcTranslate[state.blendFuncSrc], BlendFuncDstTranslate[state.blendFuncDst]);
			glBlendColor(
				state.fixColorDst.r,
				state.fixColorDst.g,
				state.fixColorDst.b,
				state.fixColorDst.a
			);
		}

		void prepareColors() {
			//auto faces = GL_FRONT;
			auto faces = GL_FRONT_AND_BACK;

			glEnableDisable(GL_COLOR_LOGIC_OP, state.logicalOperationEnabled);
			
			glColor4fv(state.ambientModelColor.ptr);
			glEnableDisable(GL_COLOR_MATERIAL, cast(bool)state.materialColorComponents);
			
			if (!state.lightingEnabled) {
				glDisable(GL_COLOR_MATERIAL);
			} else {
				// http://www.openorg/sdk/docs/man/xhtml/glColorMaterial.xml
				// http://www.openorg/discussion_boards/ubbthreads.php?ubb=showflat&Number=238308
				/*
				glMaterialfv(faces, GL_AMBIENT , [1.0f, 1.0f, 1.0f, 1.0f].ptr);
				glMaterialfv(faces, GL_DIFFUSE , [1.0f, 1.0f, 1.0f, 1.0f].ptr);
				glMaterialfv(faces, GL_SPECULAR, [1.0f, 1.0f, 1.0f, 1.0f].ptr);
				if (state.materialColorComponents & LightComponents.GU_AMBIENT ) glMaterialfv(faces, GL_AMBIENT,  state.ambientModelColor.ptr);
				if (state.materialColorComponents & LightComponents.GU_DIFFUSE ) glMaterialfv(faces, GL_DIFFUSE,  state.diffuseModelColor.ptr);
				//if (state.materialColorComponents & LightComponents.GU_SPECULAR) glMaterialfv(faces, GL_SPECULAR, state.specularModelColor.ptr);
				*/
			}
			
			state.specularModelColor.a = state.diffuseModelColor.a = state.ambientModelColor.a = 1.0;
			glMaterialfv(faces, GL_AMBIENT,  state.ambientModelColor.ptr);
			glMaterialfv(faces, GL_DIFFUSE,  state.diffuseModelColor.ptr);
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
			glLogicOp(LogicalOperationTranslate[state.logicalOperation]);
		}

		// http://jerome.jouvie.free.fr/OpenGl/Tutorials/Tutorial13.php
		// http://code.google.com/p/jpcsp/source/browse/trunk/src/jpcsp/graphics/VideoEngine.java
		void prepareLighting() {
			if (!glEnableDisable(GL_LIGHTING, state.lightingEnabled)) {
				version (VERSION_ENABLED_STATE_CORTOCIRCUIT) return;
			}

			//glLightModeli(GL_LIGHT_MODEL_COLOR_CONTROL, state.lightModel);

			foreach (n, ref light; state.lights) {
				auto GL_LIGHT_n = GL_LIGHT0 + n;

				if (!glEnableDisable(GL_LIGHT_n, light.enabled)) {
					version (VERSION_ENABLED_STATE_CORTOCIRCUIT) continue;
				}

				if (light.type == LightType.GU_SPOTLIGHT) {
					glLightfv(GL_LIGHT_n, GL_SPOT_DIRECTION, light.spotDirection.pointer);
					glLightf(GL_LIGHT_n, GL_SPOT_EXPONENT , light.spotLightExponent);
					glLightf(GL_LIGHT_n, GL_SPOT_CUTOFF   , light.spotLightCutoff);
				} else {
					glLightf(GL_LIGHT_n, GL_SPOT_EXPONENT, 0);
					glLightf(GL_LIGHT_n, GL_SPOT_CUTOFF, 180);
				}
				
				glLightfv(GL_LIGHT_n, GL_POSITION , light.position.pointer);

				light.ambientLightColor.a = light.diffuseLightColor.a = light.specularLightColor.a = 1.0;

				//glLightfv(GL_LIGHT_n, GL_AMBIENT  , light.ambientLightColor.pointer);
				glLightfv(GL_LIGHT_n, GL_DIFFUSE  , light.diffuseLightColor.pointer);
				glLightfv(GL_LIGHT_n, GL_SPECULAR , light.specularLightColor.pointer);
				
				glLightf(GL_LIGHT_n, GL_CONSTANT_ATTENUATION , light.attenuation.constant);
				glLightf(GL_LIGHT_n, GL_LINEAR_ATTENUATION   , light.attenuation.linear);
				glLightf(GL_LIGHT_n, GL_QUADRATIC_ATTENUATION, light.attenuation.quadratic);
				
				//writefln("LIGHT(%d) : %s", n, light);
			}
		}
		
		void prepareAlphaTest() {
			if (!glEnableDisable(GL_ALPHA_TEST, state.alphaTestEnabled)) {
				version (VERSION_ENABLED_STATE_CORTOCIRCUIT) return;
			}

			glAlphaFunc(
				TestTranslate[state.alphaTestFunc],
				state.alphaTestValue
			);
		}

		// http://www.openorg/resources/faq/technical/depthbuffer.htm
		void prepareDepthTest() {
			//return;

			if (!glEnableDisable(GL_DEPTH_TEST, state.depthTestEnabled)) {
				version (VERSION_ENABLED_STATE_CORTOCIRCUIT) return;
			}
			glDepthFunc(TestTranslate[state.depthFunc]);
		}
		
		void prepareDepthWrite() {
			//return;
			
			glDepthMask(state.depthMask != 0);
			if (!state.depthMask) {
				version (VERSION_ENABLED_STATE_CORTOCIRCUIT) return;
			}

			//glDepthRange(state.depthRangeNear, state.depthRangeFar);
			glDepthRange(state.depthRangeFar, state.depthRangeNear);
		}

		void prepareStencil() {
			//return;

			if (!glEnableDisable(GL_STENCIL_TEST, state.stencilTestEnabled)) {
				version (VERSION_ENABLED_STATE_CORTOCIRCUIT) return;
			}

			//writefln("%d, %d, %d : %d, %d, %d", state.stencilFuncFunc, state.stencilFuncRef, state.stencilFuncMask, state.stencilOperationSfail, state.stencilOperationDpfail, state.stencilOperationDppass);
			/*
			1, 1, 1 : 0, 0, 2
			2, 1, 1 : 0, 0, 0
			*/
			
			//if (state.stencilFuncFunc == 2) { outputDepthAndStencil(); assert(0); }
			
			glStencilFunc(
				TestTranslate[state.stencilFuncFunc],
				state.stencilFuncRef,
				state.stencilFuncMask
			);
			
			//writefln("glStencilFunc(%d, %d, %d)", TestTranslate[state.stencilFuncFunc], state.stencilFuncRef, state.stencilFuncMask);
			
			//glCheckError();

			glStencilOp(
				StencilOperationTranslate[state.stencilOperationSfail ],
				StencilOperationTranslate[state.stencilOperationDpfail],
				StencilOperationTranslate[state.stencilOperationDppass]
			);
			//glCheckError();
			
			//glStencilMask(0xFFFF);
		}

		void prepareFog() {
			if (!glEnableDisable(GL_FOG, state.fogEnabled)) {
				version (VERSION_ENABLED_STATE_CORTOCIRCUIT) return;
			}

			glFogfv(GL_FOG_COLOR, state.fogColor.pointer);
			glFogf(GL_FOG_START, state.fogEnd - (1 / state.fogDist));
			glFogf(GL_FOG_END, state.fogEnd);
		}

		prepareColors();
		glShadeModel(state.shadeModel ? GL_SMOOTH : GL_FLAT);
		prepareStencil();
		prepareScissor();
		prepareBlend();
		prepareCulling();
		prepareTexture();
		prepareLighting();
		prepareLogicOp();
		prepareAlphaTest();
		prepareDepthTest();
		prepareDepthWrite();
		prepareFog();

		//glColorMask(cast(bool)state.colorMask[0], cast(bool)state.colorMask[1], cast(bool)state.colorMask[2], cast(bool)state.colorMask[3]);
		glColorMask(true, true, true, true);
		glEnableDisable(GL_LINE_SMOOTH, state.lineSmoothEnabled);
		glHint(GL_LINE_SMOOTH_HINT, GL_NICEST);
	}

	void drawBegin() {
		if (prevState.RealState == (*state).RealState) {
			version (VERSION_ENABLED_STATE_CORTOCIRCUIT_EX) {
				//prepareTexture();
				//if (state.textureMappingEnabled) getTexture(state.textures[0], state.clut).bind();
				return;
			}
		}

		drawBeginCommon();
		if (state.clearingMode) {
			drawBeginClear();
		} else {
			drawBeginNormal();
		}
	}
	
	void drawEnd() {
		prevState = *state;
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