module pspemu.core.gpu.impl.GpuOpenglTexture;

//debug = DEBUG_TEXTURE_UPDATE;
//version = VERSION_CACHE_ALWAYS_VALID;

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
		//refreshAnyway = true;
		if (markForRecheck || refreshAnyway) {
			ubyte[] emptyBuffer;

			auto textureData = textureState.address ? (cast(ubyte*)memory.getPointer(textureState.address))[0..textureState.totalSize] : emptyBuffer;
			//auto clutData    = clutState.address    ? (cast(ubyte*)memory.getPointer(clutState.address))[0..textureState.paletteRequiredComponents] : emptyBuffer;
			auto clutData    = clutState.address ? clutState.data : emptyBuffer;
		
			if (markForRecheck) {
				markForRecheck = false;

				version (VERSION_CACHE_ALWAYS_VALID) {
				} else {
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

		debug (DEBUG_TEXTURE_UPDATE) {
			writefln("Updated: %s", textureState);
			if (textureState.hasPalette) writefln("  %s", clutState);
		}
		
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
		void writeValue2(ubyte value) {
			textureDataWithPaletteApplied[0..clutEntrySize] = value;
			textureDataWithPaletteApplied += clutEntrySize;
		}
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
			case PixelFormats.GU_PSM_T8 :
				foreach (index; textureData) {
					writeValue(index);
				}
			break;
			case PixelFormats.GU_PSM_T16: foreach (index; cast(ushort[])textureData) writeValue(index); break;
			case PixelFormats.GU_PSM_T32: foreach (index; cast(uint[])textureData) writeValue(index); break;
		}
	}

	}