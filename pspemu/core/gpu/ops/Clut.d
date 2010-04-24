module pspemu.core.gpu.ops.Clut;

/**
 * CLUT (Color LookUp Table) opcodes.
 */
template Gpu_Clut() {
	/**
	 * Upload CLUT (Color Lookup Table)
	 *
	 * @note Data must be aligned to 1 quad word (16 bytes)
	 *
	 * @param num_blocks - How many blocks of 8 entries to upload (32*8 is 256 colors)
	 * @param cbp        - Pointer to palette (16 byte aligned)
	 **/
	///void sceGuClutLoad(int num_blocks, const void* cbp); // OP_CBP + OP_CBPH + OP_CLOAD

	// Clut Buffer Pointer (High)
	// Clut LOAD
	auto OP_CBP () { gpu.state.clut.address = (gpu.state.clut.address & 0xFF000000) | (command.param24 << 0); }
	auto OP_CBPH() { gpu.state.clut.address = (gpu.state.clut.address & 0x00FFFFFF) | (command.param24 << 8); }
	auto OP_CLOAD() {
		ubyte num_entries = command.extract!(ubyte);
		
		/*
		gpu.state.uploadedClut = gpu.state.clut;
		int size = gpu.state.clut.blocksSize(num_entries);
		gpu.state.uploadedClut.data = gpu.state.clut.address ? gpu.memory[gpu.state.clut.address..gpu.state.clut.address + size].dup : [];
		*/
		int size = gpu.state.clut.blocksSize(num_entries);
		gpu.state.clut.data = gpu.state.clut.address ? gpu.memory[gpu.state.clut.address..gpu.state.clut.address + size].dup : [];
	}

	/**
	 * Set current CLUT mode
	 *
	 * Available pixel formats for palettes are:
	 *   - GU_PSM_5650
	 *   - GU_PSM_5551
	 *   - GU_PSM_4444
	 *   - GU_PSM_8888
	 *
	 * @param cpsm  - Which pixel format to use for the palette
	 * @param shift - Shifts color index by that many bits to the right
	 * @param mask  - Masks the color index with this bitmask after the shift (0-0xFF)
	 * @param a3    - Unknown, set to 0
	 **/
	///void sceGuClutMode(uint cpsm, uint shift, uint mask, uint a3); // OP_CMODE

	// Clut MODE
	auto OP_CMODE() {
		gpu.state.clut.format = command.extract!(PixelFormats, 0, 2);
		gpu.state.clut.shift  = command.extract!(uint,  2, 5);
		gpu.state.clut.mask   = command.extract!(uint,  8, 8);
		gpu.state.clut.start  = command.extract!(uint, 16, 5) << 4;
	}
}
