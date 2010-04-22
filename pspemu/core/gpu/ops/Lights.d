module pspemu.core.gpu.ops.Lights;

template Gpu_Lights() {
	string LightArrayOperation(string type, string code, int step = 1) { return ArrayOperation(type, 0, 3, code, step); }
	string LightArrayOperationStep3(string type, string code) { return LightArrayOperation(type, code, 3); }

	// Specular POWer
	auto OP_SPOW() { gpu.state.specularPower = command.float1; }
	auto OP_LMODE() { gpu.state.lightModel = cast(LightModel)command.param24; }

	// pspemu.core.gpu.ops.Colors
	//"ALC"			, // 0x|| - Ambient Light Color
	//"ALA"			, // 0x|| - Ambient Light Alpha

	// Light Type
	mixin(LightArrayOperation("LTx" , q{
		with (gpu.state.lights[Index]) {
			type = cast(LightType )((command.param24 >> 8) & 3);
			kind = cast(LightModel)((command.param24 >> 0) & 3);
			switch (type) {
				case LightType.GU_DIRECTIONAL:
					position.z = 0.0;
				break;
				case LightType.GU_POINTLIGHT:
					position.z = 1.0;
					spotLightCutoff = 180;
				break;
				case LightType.GU_SPOTLIGHT:
					position.z = 1.0;
				break;
			}
		}
	}));

	// Light Position (X, Y, Z)
	mixin(LightArrayOperationStep3("LXPx", q{ gpu.state.lights[Index].position.x = command.float1; }));
	mixin(LightArrayOperationStep3("LYPx", q{ gpu.state.lights[Index].position.y = command.float1; }));
	mixin(LightArrayOperationStep3("LZPx", q{ gpu.state.lights[Index].position.z = command.float1; }));

	// spot Light Direction (X, Y, Z)
	mixin(LightArrayOperationStep3("LXDx", q{ gpu.state.lights[Index].spotDirection.x = command.float1; }));
	mixin(LightArrayOperationStep3("LYDx", q{ gpu.state.lights[Index].spotDirection.y = command.float1; }));
	mixin(LightArrayOperationStep3("LZDx", q{ gpu.state.lights[Index].spotDirection.z = command.float1; }));
	
	// Light Constant/Linear/Quadratic Attenuation
	mixin(LightArrayOperationStep3("LCAx", q{ gpu.state.lights[Index].attenuation.constant  = command.float1; }));
	mixin(LightArrayOperationStep3("LLAx", q{ gpu.state.lights[Index].attenuation.linear    = command.float1; }));
	mixin(LightArrayOperationStep3("LQAx", q{ gpu.state.lights[Index].attenuation.quadratic = command.float1; }));

	// SPOT light EXPonent/CUToff
	mixin(LightArrayOperation("SPOTEXPx", q{ gpu.state.lights[Index].spotLightExponent = command.float1; }));
	mixin(LightArrayOperation("SPOTCUTx", q{ gpu.state.lights[Index].spotLightCutoff   = command.float1; }));

	// Ambient/Diffuse/Specular Light Color
	mixin(LightArrayOperationStep3("ALCx", q{ gpu.state.lights[Index].ambientLightColor.rgb[]  = command.float3[]; }));
	mixin(LightArrayOperationStep3("DLCx", q{ gpu.state.lights[Index].diffuseLightColor.rgb[]  = command.float3[]; }));
	mixin(LightArrayOperationStep3("SLCx", q{ gpu.state.lights[Index].specularLightColor.rgb[] = command.float3[]; }));

	// LighT Enable
	mixin(LightArrayOperation("LTEx", q{ gpu.state.lights[Index].enabled = command.bool1; }));
}
