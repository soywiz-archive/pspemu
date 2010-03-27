module pspemu.core.gpu.ops.Texture;

template Gpu_Texture() {
	static pure string TextureArrayOperation(string type, string code) { return ArrayOperation(type, 0, 7, code); }

	auto OP_TPSM() { // Texture Pixel Storage Mode
		with (gpu.state) {
			textureFormat = command.param24;
		}
	}
	
	auto OP_TMODE() { // Texture Mode
		with (gpu.state) {
			textureSwizzled  = (command.param24 >>  0) & 0x1;
			mipMapLevel      = (command.param24 >> 16) & 0x3;
		}
	}

	mixin (TextureArrayOperation("TBP", q{
		with (gpu.state.textures[Index]) {
			address &= 0xFF000000;
			address |= command.param24;
		}
	}));

	mixin (TextureArrayOperation("TBW", q{
		with (gpu.state.textures[Index]) {
			//width    = param16; // ???
			address &= 0x00FFFFFF;
			address |= (command.param24 << 8) & 0xFF000000;
		}
	}));

	mixin (TextureArrayOperation("TSIZE", q{
		with (gpu.state.textures[Index]) {
			width  = 1 << ((command.param24 >> 0) & 0xFF);
			height = 1 << ((command.param24 >> 8) & 0xFF);
			format   = gpu.state.textureFormat;
			swizzled = gpu.state.textureSwizzled;
		}
	}));

	auto OP_TFLUSH() {
	}

	auto OP_TSYNC() {
	}

	auto OP_TFLT() {
		with (gpu.state) {
			textureFilterMin = ((command.param24 >> 0) & 0x7) & 0x1; // only GL_NEAREST, GL_LINEAR (no mipmaps) (& 0x1)
			textureFilterMag = ((command.param24 >> 8) & 0x7) & 0x1; // only GL_NEAREST, GL_LINEAR (no mipmaps) (& 0x1)
		}
	}

	auto OP_TWRAP() {
		with (gpu.state) {
			textureWrapS = (command.param24 >> 0) & 0xFF;
			textureWrapT = (command.param24 >> 8) & 0xFF;
		}
	}

	auto OP_TFUNC() {
		with (gpu.state) {
			textureEnvMode = command.param24 & 0x07;
		}
	}
	
	auto OP_USCALE () { gpu.state.textureScale.u = command.float1; }
	auto OP_VSCALE () { gpu.state.textureScale.v = command.float1; }
	auto OP_UOFFSET() { gpu.state.textureOffset.u = command.float1; }
	auto OP_VOFFSET() { gpu.state.textureOffset.v = command.float1; }
}
