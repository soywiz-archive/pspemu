module pspemu.core.gpu.ops.Fog;

template Gpu_Fog() {
	// void sceGuFog(float near, float far, unsigned int color);

	// Fog COLor
	auto OP_FCOL() {
		gpu.state.fogColor.rgb[] = command.float3[];
	}

	// Fog FAR
	auto OP_FFAR() {
		gpu.state.fogEnd = command.float1;
	}

	// Fog DISTance
	auto OP_FDIST() {
		gpu.state.fogDist = command.float1;
	}
}
