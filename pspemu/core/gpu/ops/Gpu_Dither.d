module pspemu.core.gpu.ops.Gpu_Dither;

template Gpu_Dither() {
	/**
	 * Set ordered pixel dither matrix
	 *
	 * This dither matrix is only applied if GU_DITHER is enabled.
	 *
	 * @param matrix - Dither matrix
	 **/
	// void sceGuSetDither(const ScePspIMatrix4* matrix);
	// sendCommandi(226,(matrix->x.x & 0x0f)|((matrix->x.y & 0x0f) << 4)|((matrix->x.z & 0x0f) << 8)|((matrix->x.w & 0x0f) << 12));
	// sendCommandi(227,(matrix->y.x & 0x0f)|((matrix->y.y & 0x0f) << 4)|((matrix->y.z & 0x0f) << 8)|((matrix->y.w & 0x0f) << 12));
	// sendCommandi(228,(matrix->z.x & 0x0f)|((matrix->z.y & 0x0f) << 4)|((matrix->z.z & 0x0f) << 8)|((matrix->z.w & 0x0f) << 12));
	// sendCommandi(229,(matrix->w.x & 0x0f)|((matrix->w.y & 0x0f) << 4)|((matrix->w.z & 0x0f) << 8)|((matrix->w.w & 0x0f) << 12));
	// Dither
	mixin (ArrayOperation("OP_DTH_n", 0, 3, q{
		alias Index rowIndex;
	}));
}
