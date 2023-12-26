shader_type spatial;

uniform sampler2D _a;
uniform sampler2D heightmap;
uniform sampler2D normals;
uniform float heightRatio = 1.0;

void vertex() {
	VERTEX.y += texture(heightmap, UV).r * heightRatio;
}

void fragment() {
	ALBEDO = texture(_a, UV).rgb;
	NORMAL_MAP = texture(normals, UV).xyz;
}