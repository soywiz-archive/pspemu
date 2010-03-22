module pspemu.core.gpu.ops.Colors;

template Gpu_Colors() {
	// Ambient Model Color/Alpha
	auto OP_AMC() { gpu.info.ambientModelColor.rgb[] = command.float4[]; }
	auto OP_AMA() { gpu.info.ambientModelColor.alpha = command.float4[0]; }

	// Diffuse Model Color/Alpha
	auto OP_DMC() { gpu.info.diffuseModelColor.rgb[] = command.float4[]; }
	auto OP_DMA() { gpu.info.diffuseModelColor.alpha = command.float4[0]; }

	// Specular Model Color/Alpha
	auto OP_SMC() { gpu.info.specularModelColor.rgb[] = command.float4[]; }
	auto OP_SMA() { gpu.info.specularModelColor.alpha = command.float4[0]; }

	// Material Color
	auto OP_CMAT() { gpu.info.materialColor.rgb[] = command.float4[]; }
}
