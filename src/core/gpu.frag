///////////////////////////////////////////////////////////////////////////////
// psp fragment shader
// by soywiz 2008
///////////////////////////////////////////////////////////////////////////////

// Color LookUp Table
uniform sampler1D clut;
uniform bool clutUse;
uniform int clutOffset;
uniform bool textureUse;

// Texture
uniform sampler2D tex;

void main() {
	vec4 color;
	
	// If there is clut
	if (clutUse) {
		// tex must have GL_NEAR
		color = texture2D(tex, gl_TexCoord[0].st);
		color = texture1D(clut, round(color.r + clutOffset));
	} else {
		if (textureUse) {
			color = gl_Color * texture2D(tex, gl_TexCoord[0].st);
		} else {
			color = gl_Color;
		}
	}
	
	//color = vec4(1, 1, 1, 1);
	
	gl_FragColor = color;
}