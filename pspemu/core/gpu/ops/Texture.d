module pspemu.core.gpu.ops.Texture;

template Gpu_Texture() {
	static pure string TextureArrayOperation(string type, string code) { return ArrayOperation(type, 0, 7, code); }

	// Texture Pixel Storage Mode
	auto OP_TPSM() {
		with (gpu.state) {
			textureFormat = cast(PixelFormats)command.param24;
		}
	}
	
	// Texture Mode
	auto OP_TMODE() {
		with (gpu.state) {
			textureSwizzled  = command.extract!(uint, 0, 8)() != 0;
			mipmapShareClut  = command.extract!(uint, 8, 8)() == 0;
			mipMapLevel      = command.extract!(uint, 16, 8)();
		}
	}

	// Texture Base Pointer
	mixin (TextureArrayOperation("TBPx", q{
		with (gpu.state.textures[Index]) {
			address &= 0xFF000000;
			address |= command.param24;
		}
	}));

	// Texture Buffer Width.
	mixin (TextureArrayOperation("TBWx", q{
		with (gpu.state.textures[Index]) {
			buffer_width = command.extract!(uint, 0, 16)(); // ???
			address &= 0x00FFFFFF;
			address |= command.extract!(uint, 16, 8)() << 24;
		}
	}));

	// Texture Size
	mixin (TextureArrayOperation("TSIZEx", q{
		with (gpu.state.textures[Index]) {
			width  = 1 << command.extract!(uint, 0, 8)();
			height = 1 << command.extract!(uint, 8, 8)();
			format   = gpu.state.textureFormat;
			swizzled = gpu.state.textureSwizzled;
		}
	}));

	// Texture Flush
	auto OP_TFLUSH() {
	}

	// Texture Sync
	auto OP_TSYNC() {
	}

	// Texture FiLTer
	auto OP_TFLT() {
		with (gpu.state) {
			textureFilterMin = ((command.param24 >> 0) & 0x7) & 0x1; // only GL_NEAREST, GL_LINEAR (no mipmaps) (& 0x1)
			textureFilterMag = ((command.param24 >> 8) & 0x7) & 0x1; // only GL_NEAREST, GL_LINEAR (no mipmaps) (& 0x1)
		}
	}

	// Texture WRAP
	auto OP_TWRAP() {
		with (gpu.state) {
			textureWrapS = (command.param24 >> 0) & 0xFF;
			textureWrapT = (command.param24 >> 8) & 0xFF;
		}
	}

	// Texture enviroment Mode
	auto OP_TFUNC() {
		with (gpu.state) {
			textureEnvMode = command.param24 & 0x07;
		}
	}

	// UV SCALE
	auto OP_USCALE () { gpu.state.textureScale.u = command.float1; }
	auto OP_VSCALE () { gpu.state.textureScale.v = command.float1; }

	// UV OFFSET
	auto OP_UOFFSET() { gpu.state.textureOffset.u = command.float1; }
	auto OP_VOFFSET() { gpu.state.textureOffset.v = command.float1; }
}
