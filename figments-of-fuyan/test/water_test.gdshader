shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_burley, specular_schlick_ggx;

uniform vec4 albedo : source_color;
uniform sampler2D texture_albedo : source_color, filter_linear_mipmap, repeat_enable;

uniform vec3 uv1_scale;
uniform sampler2D texture_normal;

void vertex() {
	UV = UV * uv1_scale.xy;
}

void fragment() {
	vec3 normal = texture(texture_normal, UV).rgb;
	NORMAL = normal;
	vec4 albedo_tex = texture(texture_albedo, UV);
	ALBEDO = albedo.rgb * albedo_tex.rgb;
}
