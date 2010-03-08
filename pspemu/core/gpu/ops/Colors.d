module pspemu.core.gpu.ops.Colors;

template Gpu_Colors() {
	// Ambient Model Color/Alpha
	auto OP_AMC() { gpu.info.ambientModelColor.components[0..3] = command.float4[0..3]; }
	auto OP_AMA() { gpu.info.ambientModelColor.alpha = command.float4[0]; }

	// Diffuse Model Color/Alpha
	auto OP_DMC() { gpu.info.diffuseModelColor.components[0..3] = command.float4[0..3]; }
	auto OP_DMA() { gpu.info.diffuseModelColor.alpha = command.float4[0]; }

	// Specular Model Color/Alpha
	auto OP_SMC() { gpu.info.specularModelColor.components[0..3] = command.float4[0..3]; }
	auto OP_SMA() { gpu.info.specularModelColor.alpha = command.float4[0]; }
}
