module pspemu.core.gpu.ops.Colors;

template Gpu_Colors() {
	// Ambient Model Color/Alpha
	auto OP_AMC() { gpu.state.ambientModelColor.rgb[] = command.float3[]; }
	auto OP_AMA() { gpu.state.ambientModelColor.alpha = command.float4[0]; }

	// Diffuse Model Color/Alpha
	auto OP_DMC() { gpu.state.diffuseModelColor.rgb[] = command.float3[]; }
	auto OP_DMA() { gpu.state.diffuseModelColor.alpha = command.float4[0]; }

	// Specular Model Color/Alpha
	auto OP_SMC() { gpu.state.specularModelColor.rgb[] = command.float3[]; }
	auto OP_SMA() { gpu.state.specularModelColor.alpha = command.float4[0]; }

	// Texture Environment Color
	auto OP_TEC() { gpu.state.textureEnviromentColor.rgb[] = command.float3[]; }

	// Material Color
	auto OP_CMAT() { gpu.state.materialColor.rgb[] = command.float3[]; }
}
