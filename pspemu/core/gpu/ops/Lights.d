module pspemu.core.gpu.ops.Lights;

template Gpu_Lights() {
	static pure string LightArrayOperation(string type, string code) { return ArrayOperation(type, 0, 3, code); }

	// Specular POWer
	auto OP_SPOW() { gpu.state.specularPower = command.float1; }
	auto OP_LMODE() { gpu.state.lightModel = cast(LightModel)command.param24; }

	// pspemu.core.gpu.ops.Colors
	//"ALC"			, // 0x|| - Ambient Light Color
	//"ALA"			, // 0x|| - Ambient Light Alpha

	// Light Type
	mixin(LightArrayOperation("LT" , q{
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
	mixin(LightArrayOperation("LXP", q{ gpu.state.lights[Index / 3].position.x = command.float1; }));
	mixin(LightArrayOperation("LYP", q{ gpu.state.lights[Index / 3].position.y = command.float1; }));
	mixin(LightArrayOperation("LZP", q{ gpu.state.lights[Index / 3].position.z = command.float1; }));

	// spot Light Direction (X, Y, Z)
	mixin(LightArrayOperation("LXD", q{ gpu.state.lights[Index / 3].spotDirection.x = command.float1; }));
	mixin(LightArrayOperation("LYD", q{ gpu.state.lights[Index / 3].spotDirection.y = command.float1; }));
	mixin(LightArrayOperation("LZD", q{ gpu.state.lights[Index / 3].spotDirection.z = command.float1; }));
	
	// Light Constant/Linear/Quadratic Attenuation
	mixin(LightArrayOperation("LCA", q{ gpu.state.lights[Index / 3].attenuation.constant  = command.float1; }));
	mixin(LightArrayOperation("LLA", q{ gpu.state.lights[Index / 3].attenuation.linear    = command.float1; }));
	mixin(LightArrayOperation("LQA", q{ gpu.state.lights[Index / 3].attenuation.quadratic = command.float1; }));

	// SPOT light EXPonent/CUToff
	mixin(LightArrayOperation("SPOTEXP", q{ gpu.state.lights[Index].spotLightExponent = command.float1; }));
	mixin(LightArrayOperation("SPOTCUT", q{ gpu.state.lights[Index].spotLightCutoff   = command.float1; }));

	// Ambient/Diffuse/Specular Light Color
	mixin(LightArrayOperation("ALC", q{ gpu.state.lights[Index / 3].ambientLightColor.rgb[]  = command.float3[]; }));
	mixin(LightArrayOperation("DLC", q{ gpu.state.lights[Index / 3].diffuseLightColor.rgb[]  = command.float3[]; }));
	mixin(LightArrayOperation("SLC", q{ gpu.state.lights[Index / 3].specularLightColor.rgb[] = command.float3[]; }));

	// 
	mixin(LightArrayOperation("LTE", q{ gpu.state.lights[Index].enabled = command.bool1; }));
}
