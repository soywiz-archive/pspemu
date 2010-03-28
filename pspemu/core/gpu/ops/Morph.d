module pspemu.core.gpu.ops.Morph;

template Gpu_Morph() {
	// Morph Weight
	mixin (ArrayOperation("MW", 0, 7, q{
		gpu.state.morphWeights[Index] = command.float1;
	}));
}
