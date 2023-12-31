shader_type spatial;

uniform sampler2D _a;
uniform sampler2D heightmap;
uniform sampler2D normals;
uniform sampler2D radialHeight;
uniform sampler2D radialColor;
uniform float heightRatio = 1.0;

void vertex() {
	VERTEX.y += texture(heightmap, UV).r * texture(radialHeight, UV).r * heightRatio;
}

void fragment() {
	ALBEDO = texture(_a, UV).rgb * texture(radialColor, UV).rgb;
	NORMAL_MAP = texture(normals, UV).xyz;
	METALLIC = 0.3;
	ROUGHNESS = 0.7;
}