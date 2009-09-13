///////////////////////////////////////////////////////////////////////////////
// psp vertex shader
// by soywiz 2008
///////////////////////////////////////////////////////////////////////////////

// Transform2D flag
uniform bool transform2D;
uniform mat4 boneMatrix;
uniform vec2 boneOffset;

// Sprites
uniform vec4 spriteCenter;
attribute int spriteCorner;

// Morphing
uniform mat4 BoneMatrix[8];
attribute float boneWeights[8];

// Morphing
uniform float morphWeights[8];

//uniform bool MorphMatrix_done;
//uniform mat4 MorphMatrix[8];

uniform int morphCount;

uniform mat4 WorldMatrix;

void doSkinning(inout vec4 vertex) {
	vec4 pos = vec4(0, 0, 0, 0);
	
	for (int n = 0; n < morphCount; n++) {
		if (boneWeights[n] != 0) {
			pos += (boneWeights[n] * vertex) * transpose(BoneMatrix[n]) * WorldMatrix;
			//pos += (BoneMatrix[n] * vertex) * boneWeights[n]; 
		}
	}
	
	vertex = pos;
	//vertex = WorldMatrix * pos;
}

void main() {
	vec4 pos = gl_Vertex;
	
	gl_TexCoord[0] = gl_TextureMatrix[0] * gl_MultiTexCoord0;
	//lightDir = normalize(vec3(gl_LightSource[0].position));
	gl_FrontColor = gl_Color;

	if (transform2D) {
		//gl_Position = gl_ProjectionMatrix * gl_ModelViewMatrix * pos;
		gl_Position = ftransform();
		return;
	}
	
	if (morphCount) {
		doSkinning(pos);
	} else {
		pos = WorldMatrix * pos;
	}
	
	gl_Position = gl_ModelViewProjectionMatrix * pos;
}