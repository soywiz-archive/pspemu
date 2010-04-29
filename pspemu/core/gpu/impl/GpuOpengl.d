module pspemu.core.gpu.impl.GpuOpengl;

/*
http://code.google.com/p/jpcsp/source/browse/trunk/src/jpcsp/graphics/VideoEngine.java
http://code.google.com/p/pspemu/source/browse/branches/old/src/core/gpu.d
http://code.google.com/p/pspplayer/source/browse/trunk/Noxa.Emulation.Psp.Video.OpenGL/OglDriver_Processing.cpp
*/

//debug = DEBUG_CLEAR_MODE;

version = VERSION_ENABLE_FRAME_LOAD; // Disabled temporary
//version = VERSION_HOLD_DEPTH_BUFFER_IN_MEMORY; // Disabled temporary
version = VERSION_ENABLED_STATE_CORTOCIRCUIT;
version = VERSION_ENABLED_STATE_CORTOCIRCUIT_EX;

//debug = DEBUG_OUTPUT_DEPTH_AND_STENCIL;
//debug = DEBUG_PRIM_PERFORMANCE;
//debug = DEBUG_FRAME_TRANSFER;

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
	
	ubyte[4 * 512 * 272] tempBufferData;

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
	}
	
	void fastTrxKickToFrameBuffer() {
		// trxkick:TextureTransfer(Size(480, 272) : SRC(addr=08EB4510, w=480, XY(0, 0))-DST(addr=04088000, w=512, XY(0, 0))) : Bpp:4
		//writefln("trxkick:%s", state.textureTransfer);
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

	void test(string reason) {
		/+
		glClearColor(0.0, 0.0, 1.0, 1.0);
		glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

		glColor4f(1f, 1f, 1f, 1f);
		glColorMask(true, true, true, true);
		glDisable(GL_DEPTH_TEST);
        glDisable(GL_BLEND);
        glDisable(GL_ALPHA_TEST);
        glDisable(GL_FOG);
        glDisable(GL_LIGHTING);
        glDisable(GL_LOGIC_OP);
        glDisable(GL_STENCIL_TEST);
        glDisable(GL_SCISSOR_TEST);
		/*
		glStencilFunc(GL_ALWAYS, 1, 1);
		glStencilOp(GL_ZERO, GL_ZERO, GL_REPLACE);
		glEnable(GL_DEPTH_TEST);
		*/

		glMatrixMode(GL_PROJECTION); glLoadIdentity();
		glOrtho(0.0f, 512.0f, 272.0f, 0.0f, -1.0f, 1.0f);
		glMatrixMode(GL_MODELVIEW); glLoadIdentity();

		+/
		
		/*
		tempBufferData[] = 0xFF;
		glWindowPos2i(0, 0);
		glPixelZoom(1.0f, 1.0f);
		glDrawPixels(
			512, 272,
			GL_RGBA,
			GL_UNSIGNED_INT_8_8_8_8_REV,
			&tempBufferData[0]
		);
		*/
		
		//glFlush(); glFinish();
		
		writefln("GpuOpengl.test('%s')", reason);
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
			if (flags.hasColor   ) glColor4fv(&vertex.r);
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
		scope microSecondsStart = microSecondsTick;
		
		version (VERSION_ENABLE_FRAME_LOAD) {
			/*
			glColorMask(true, true, true, true);
			glPixelZoom(1.0f, 1.0f);
			glRasterPos2s(0, 0);
			*/

			//return;
			if (colorBuffer !is null) {
				//bitmapData[0..512 * 272] = (cast(uint *)drawBufferAddress)[0..512 * 272];
				glWindowPos2i(0, 272 - 0);
				glPixelZoom(1.0f, -1.0f);
				/*for (int n = 0; n < 272; n++) {
					int m = 271 - n;
					//int m = n;
					state.drawBuffer.row(&tempBufferData, m)[] = state.drawBuffer.row(colorBuffer, n)[];
				}*/
				
				GlPixelFormat glPixelFormat = GlPixelFormats[state.drawBuffer.format];
				glPixelStorei(GL_UNPACK_ALIGNMENT, cast(uint)glPixelFormat.size);

				glDrawPixels(
					state.drawBuffer.width, 272,
					glPixelFormat.external,
					//GL_RGB,
					glPixelFormat.opengl,
					//&tempBufferData
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
		
		debug (DEBUG_FRAME_TRANSFER) writefln("frameLoad(%08X, %08X) : microseconds:%d", cast(uint)colorBuffer, cast(uint)depthBuffer, microSecondsTick - microSecondsStart);
	}

	void frameStore(void* colorBuffer, void* depthBuffer) {
		scope microSecondsStart = microSecondsTick;

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

template OpenglUtils() {
	Texture[string] textureCache;
	//Clut[uint] clutCache;
	
	bool glEnableDisable(int type, bool enable) {
		if (enable) glEnable(type); else glDisable(type);
		return enable;
	}

	void outputDepthAndStencil() {
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
				//glOrtho(0.0f, 512.0f, 272.0f, 0.0f, -1.0f, 1.0f);
				glOrtho(0, 512, 272, 0, 0, -0xFFFF);
				//glTranslatef(0, 1, 0);
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

		//if (state.clearFlags & ClearBufferMask.GU_COLOR_BUFFER_BIT) glClear(GL_DEPTH_BUFFER_BIT);
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
			
			//if (state.vertexType.transform2D && (state.textureScale.uv == Vector(1.0, 1.0))) {
			if (state.vertexType.transform2D) {
				glScalef(1.0f / state.textures[0].width, 1.0f / state.textures[0].height, 1);
			} else {
				glTranslatef(state.textureOffset.u, state.textureOffset.v, 0);
				glScalef(state.textureScale.u, state.textureScale.v, 1);
			}
			
			glEnable(GL_TEXTURE_2D);
			getTexture(state.textures[0], state.clut).bind();
			//writefln("tex0:%s", state.textures[0]);

			glEnable(GL_CLAMP_TO_EDGE);
			glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, state.textureFilterMin ? GL_LINEAR : GL_NEAREST);
			glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, state.textureFilterMag ? GL_LINEAR : GL_NEAREST);
			glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, state.textureWrapU);
			glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, state.textureWrapV);

			//glTexEnvf(GL_TEXTURE_ENV, GL_RGB_SCALE, 1.0); // 2.0 in scale_2x
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

		// http://www.openorg/sdk/docs/man/xhtml/glColorMaterial.xml
		// http://www.openorg/discussion_boards/ubbthreads.php?ubb=showflat&Number=238308
		void prepareColors() {
			//auto faces = GL_FRONT;
			auto faces = GL_FRONT_AND_BACK;
			
			//return;

			glEnableDisable(GL_COLOR_LOGIC_OP, state.logicalOperationEnabled);		
			glEnableDisable(GL_COLOR_MATERIAL, cast(bool)state.materialColorComponents);
			glColor4fv(state.ambientModelColor.ptr);
			
			if (state.lightingEnabled) {
				int flags;
				glMaterialfv(faces, GL_AMBIENT , [0.0f, 0.0f, 0.0f, 0.0f].ptr);
				glMaterialfv(faces, GL_DIFFUSE , [0.0f, 0.0f, 0.0f, 0.0f].ptr);
				glMaterialfv(faces, GL_SPECULAR, [0.0f, 0.0f, 0.0f, 0.0f].ptr);

				if (state.materialColorComponents & LightComponents.GU_AMBIENT) {
					glMaterialfv(GL_FRONT, GL_AMBIENT,  state.ambientModelColor.ptr);
				}
				if (state.materialColorComponents & LightComponents.GU_DIFFUSE) {
					glMaterialfv(GL_FRONT, GL_DIFFUSE,  state.diffuseModelColor.ptr);
				}
				if (state.materialColorComponents & LightComponents.GU_SPECULAR) {
					glMaterialfv(GL_FRONT, GL_SPECULAR, state.specularModelColor.ptr);
				}

				if ((state.materialColorComponents & LightComponents.GU_AMBIENT) && (state.materialColorComponents & LightComponents.GU_DIFFUSE)) {
					flags = GL_AMBIENT_AND_DIFFUSE;
				} else if (state.materialColorComponents & LightComponents.GU_AMBIENT) {
					flags = GL_AMBIENT;
				} else if (state.materialColorComponents & LightComponents.GU_DIFFUSE) {
					flags = GL_DIFFUSE;
				} else if (state.materialColorComponents & LightComponents.GU_SPECULAR) {
					flags = GL_SPECULAR;
				}
            	glColorMaterial(GL_FRONT_AND_BACK, flags);
            	glEnable(GL_COLOR_MATERIAL);
			}
			
			glDisable(GL_COLOR_MATERIAL);

			glMaterialfv(GL_FRONT, GL_EMISSION, state.emissiveModelColor.ptr);
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
			glLogicOp(LogicalOperationTranslate[state.logicalOperation]);
		}

		// http://jerome.jouvie.free.fr/OpenGl/Tutorials/Tutorial13.php
		// http://code.google.com/p/jpcsp/source/browse/trunk/src/jpcsp/graphics/VideoEngine.java
		// http://www.sjbaker.org/steve/omniv/opengl_lighting.html
		// http://www.sorgonet.com/linux/openglguide/parte2.html
		void prepareLighting() {
			if (!glEnableDisable(GL_LIGHTING, state.lightingEnabled)) {
				version (VERSION_ENABLED_STATE_CORTOCIRCUIT) return;
			}
			
			glLightModeli(GL_LIGHT_MODEL_COLOR_CONTROL, state.lightModel ? GL_SEPARATE_SPECULAR_COLOR : GL_SINGLE_COLOR);
			glLightModelfv(GL_LIGHT_MODEL_AMBIENT, state.ambientLightColor.ptr);

			foreach (n, ref light; state.lights) {
				auto GL_LIGHT_n = GL_LIGHT0 + n;

				if (!glEnableDisable(GL_LIGHT_n, light.enabled)) {
					version (VERSION_ENABLED_STATE_CORTOCIRCUIT) continue;
				}
				
				if (light.kind == LightComponents.GU_DIFFUSE_AND_SPECULAR) {
					glLightfv(GL_LIGHT_n, GL_SPECULAR , light.specularColor.pointer);
				} else {
					glLightfv(GL_LIGHT_n, GL_SPECULAR , [0.0f, 0, 0, 0].ptr);
				}
				
				glLightfv(GL_LIGHT_n, GL_AMBIENT  , light.ambientColor.pointer);
				glLightfv(GL_LIGHT_n, GL_DIFFUSE  , light.diffuseColor.pointer);

				light.position.t = 1.0;
				glLightfv(GL_LIGHT_n, GL_POSITION , light.position.pointer);
				
				glLightf(GL_LIGHT_n, GL_CONSTANT_ATTENUATION , light.attenuation.constant);
				glLightf(GL_LIGHT_n, GL_LINEAR_ATTENUATION   , light.attenuation.linear);
				glLightf(GL_LIGHT_n, GL_QUADRATIC_ATTENUATION, light.attenuation.quadratic);
				
				glLightfv(GL_LIGHT_n, GL_SPOT_DIRECTION , light.spotDirection.pointer);
				glLightf (GL_LIGHT_n, GL_SPOT_EXPONENT  , light.spotExponent);
				glLightf (GL_LIGHT_n, GL_SPOT_CUTOFF    , light.spotCutoff);
				
				//writefln("ambientColor : %f, %f, %f, %f", light.ambientColor.pointer[0], light.ambientColor.pointer[1], light.ambientColor.pointer[2], light.ambientColor.pointer[3]);
				//writefln("diffuseColor : %f, %f, %f, %f", light.diffuseColor.pointer[0], light.diffuseColor.pointer[1], light.diffuseColor.pointer[2], light.diffuseColor.pointer[3]);
				//writefln("specularColor: %f, %f, %f, %f", light.specularColor.pointer[0], light.specularColor.pointer[1], light.specularColor.pointer[2], light.specularColor.pointer[3]);
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
			
			glDepthMask(state.depthMask == 0);

			if (state.depthMask) {
				version (VERSION_ENABLED_STATE_CORTOCIRCUIT) return;
			}

			//glDepthRange(state.depthRangeNear, state.depthRangeFar);
			glDepthRange(state.depthRangeFar, state.depthRangeNear);
		}

		void prepareStencil() {
			if (!glEnableDisable(GL_STENCIL_TEST, state.stencilTestEnabled)) {
				version (VERSION_ENABLED_STATE_CORTOCIRCUIT) return;
			}

			//if (state.stencilFuncFunc == 2) { outputDepthAndStencil(); assert(0); }
			
			glStencilFunc(
				TestTranslate[state.stencilFuncFunc],
				state.stencilFuncRef,
				state.stencilFuncMask
			);
			
			glStencilOp(
				StencilOperationTranslate[state.stencilOperationSfail ],
				StencilOperationTranslate[state.stencilOperationDpfail],
				StencilOperationTranslate[state.stencilOperationDppass]
			);
		}

		void prepareFog() {
			if (!glEnableDisable(GL_FOG, state.fogEnabled)) {
				version (VERSION_ENABLED_STATE_CORTOCIRCUIT) return;
			}

			glFogfv(GL_FOG_COLOR, state.fogColor.pointer);
			glFogf(GL_FOG_START, state.fogEnd - (1 / state.fogDist));
			glFogf(GL_FOG_END, state.fogEnd);
		}

		//glEnable(GL_NORMALIZE);
		//glColorMask(cast(bool)state.colorMask[0], cast(bool)state.colorMask[1], cast(bool)state.colorMask[2], cast(bool)state.colorMask[3]);
		glColorMask(true, true, true, true);
		glEnableDisable(GL_LINE_SMOOTH, state.lineSmoothEnabled);
		glHint(GL_LINE_SMOOTH_HINT, GL_NICEST);
		glShadeModel(state.shadeModel ? GL_SMOOTH : GL_FLAT);

		prepareStencil();
		prepareScissor();
		prepareBlend();
		prepareCulling();
		prepareTexture();
		prepareLogicOp();
		prepareAlphaTest();
		prepareDepthTest();
		prepareDepthWrite();
		prepareFog();
		prepareLighting();
		prepareColors();
	}

	void drawBegin() {
		if (prevState.RealState == (*state).RealState) {
			version (VERSION_ENABLED_STATE_CORTOCIRCUIT_EX) {
				//prepareTexture();
				//if (state.textureMappingEnabled) getTexture(state.textures[0], state.clut).bind();
				return;
			}
		}

		if (state.clearingMode) {
			drawBeginClear();
		} else {
			drawBeginNormal();
		}
		drawBeginCommon();
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