module pspemu.core.gpu.ops.Texture;

template Gpu_Texture() {
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
	
	alias OP_TBP_n OP_TBP0, OP_TBP1, OP_TBP2, OP_TBP3, OP_TBP4, OP_TBP5, OP_TBP6, OP_TBP7;
	auto OP_TBP_n() {
		uint N = command.opcode - Opcode.TBP0;
		with (gpu.state.textures[N]) {
			address &= 0xFF000000;
			address |= command.param24;
		}
	}

	alias OP_TBW_n OP_TBW0, OP_TBW1, OP_TBW2, OP_TBW3, OP_TBW4, OP_TBW5, OP_TBW6, OP_TBW7;
	auto OP_TBW_n() {
		int N = command.opcode - Opcode.TBW0;
		with (gpu.state.textures[N]) {
			//width    = param16; // ???
			address &= 0x00FFFFFF;
			address |= (command.param24 << 8) & 0xFF000000;
		}
	}

	alias OP_TSIZE_n OP_TSIZE0, OP_TSIZE1, OP_TSIZE2, OP_TSIZE3, OP_TSIZE4, OP_TSIZE5, OP_TSIZE6, OP_TSIZE7;
	auto OP_TSIZE_n() {
		int N = command.opcode - Opcode.TSIZE0;
		with (gpu.state.textures[N]) {
			width  = 1 << ((command.param24 >> 0) & 0xFF);
			height = 1 << ((command.param24 >> 8) & 0xFF);
			format = gpu.state.textureFormat;
		}
	}

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
