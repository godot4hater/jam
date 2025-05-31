shader_type spatial;
render_mode cull_disabled;

uniform sampler2D albedo_texture: source_color, filter_nearest;
uniform sampler2D roughness_texture;
uniform sampler2D normal_texture;
uniform sampler2D noise_texture: source_color;

void vertex(){
	float r = texture(noise_texture, vec2(UV.x + (TIME * 0.12), UV.y)).r;
	vec4 normal = texture(normal_texture, UV);
	NORMAL = normal.xyz;
	VERTEX += (NORMAL) * (r * 0.025);
}

void fragment() {
	vec4 color = texture(albedo_texture, UV);
	ALBEDO = color.rgb * COLOR.rgb;
	ROUGHNESS = texture(roughness_texture, UV).x;
	SPECULAR = 0.75;
	RIM = 0.5;
}
