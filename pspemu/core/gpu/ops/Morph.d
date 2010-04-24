module pspemu.core.gpu.ops.Morph;

template Gpu_Morph() {
	// Morph Weight
	mixin (ArrayOperation("OP_MW_n", 0, 7, q{
		gpu.state.morphWeights[Index] = command.float1;
	}));
}
