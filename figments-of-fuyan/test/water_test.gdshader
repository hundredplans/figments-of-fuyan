shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_burley, specular_schlick_ggx;

uniform vec4 albedo : source_color;
uniform sampler2D texture_albedo : source_color, filter_linear_mipmap, repeat_enable;

uniform vec3 uv1_scale;
uniform sampler2D texture_normal;

varying float height;
varying vec3 world_pos;

uniform sampler2D wave;
uniform float noise_scale = 10.0;
uniform float height_scale = 0.15;
uniform float time_scale : hint_range(0.0, 0.2, 0.005) = 0.025;

void vertex() {
	world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	height = texture(wave, world_pos.xz / noise_scale + TIME * time_scale).r;
	VERTEX.y += height * height_scale;
	UV = UV * uv1_scale.xy;
}

void fragment() {
	vec3 normal = texture(texture_normal, UV).rgb;
	NORMAL = normal;
	vec4 albedo_tex = texture(texture_albedo, UV);
	ALBEDO = albedo.rgb * albedo_tex.rgb;
}
