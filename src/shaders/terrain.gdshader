shader_type spatial;

uniform sampler2D _a;
uniform sampler2D heightmap;
uniform float heightRatio = 1.0;

vec3 calc_normal(vec2 uv) { 
    const vec3 off = vec3(-1,0,1);
    vec2 texelSize = 1.0 / vec2(textureSize(heightmap, 0));

    float left = texture(heightmap, uv + texelSize * off.xy).x;
    float right = texture(heightmap, uv + texelSize * off.zy).x;
    float top = texture(heightmap, uv + texelSize * off.yx).x;
    float down = texture(heightmap, uv + texelSize * off.yz).x;

    return normalize(vec3(left-right, 2.0, down-top));
}

void vertex() {
	VERTEX.y += texture(heightmap, UV).r * heightRatio;
	NORMAL = calc_normal(UV); 
}

void fragment() {
	ALBEDO = texture(_a, UV).rgb;
}

void light() {
	// Called for every pixel for every light affecting the material.
}