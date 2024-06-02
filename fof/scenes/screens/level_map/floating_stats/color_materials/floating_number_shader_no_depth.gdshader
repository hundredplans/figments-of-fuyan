// NOTE: Shader automatically converted from Godot Engine 4.2.1.stable's StandardMaterial3D.

shader_type spatial;
render_mode blend_mix,depth_draw_opaque,cull_back,diffuse_burley,specular_schlick_ggx,unshaded,depth_test_disabled;
uniform vec3 albedo : source_color;
uniform float distance_fade_min;
uniform float distance_fade_max;
uniform float specular;

void fragment() {
	ALBEDO = albedo;
	SPECULAR = specular;
	{
		float fade_distance = length(VERTEX);
		const vec3 magic = vec3(0.06711056f, 0.00583715f, 52.9829189f);		float fade = clamp(smoothstep(distance_fade_min, distance_fade_max, fade_distance), 0.0, 1.0);
		if (fade < 0.001 || fade < fract(magic.z * fract(dot(FRAGCOORD.xy, magic.xy)))) {
			discard;
		}
	}
}
