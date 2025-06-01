shader_type spatial;
render_mode cull_disabled;

uniform sampler2D albedo_texture: source_color, filter_nearest;
uniform float roughness: hint_range(0, 1) = 0.8;
uniform bool use_roughness_texture = false;
uniform sampler2D roughness_texture: hint_default_white;
uniform float metallic: hint_range(0, 1) = 0.0;
uniform bool use_metallic_texture = false;
uniform sampler2D metallic_texture: hint_default_black;
uniform float normalmap: hint_range(0, 1) = 1.0;
uniform sampler2D normal_texture: hint_normal;

uniform float scroll_x: hint_range(-10, 10) = 0.0;
uniform float scroll_y: hint_range(-10, 10) = 0.0;

uniform sampler2D noise_texture: source_color;

void vertex(){
	float r = texture(noise_texture, vec2(UV.x + (TIME * 0.12), UV.y)).r;
	VERTEX += (NORMAL) * (r * 0.025);
}

void fragment() {

	float delta_x = TIME * scroll_x;
	float delta_y = TIME * scroll_y;
	vec2 uv = vec2(UV.x + delta_x, UV.y + delta_y);

	vec4 texture_color = texture(albedo_texture, uv);
	vec4 vertex_color = COLOR;
	ALBEDO = texture_color.rgb * vertex_color.rgb;
	ROUGHNESS = roughness;
	if (use_roughness_texture) {
		ROUGHNESS = roughness * texture(roughness_texture, uv).r;
	}
	METALLIC = metallic;
	if (use_metallic_texture) {
		METALLIC = metallic * texture(metallic_texture, uv).r;
	}
	NORMAL_MAP = mix(NORMAL_MAP, texture(normal_texture, uv).rgb, normalmap);

	SPECULAR = 0.75;
	RIM = 0.5;
}
