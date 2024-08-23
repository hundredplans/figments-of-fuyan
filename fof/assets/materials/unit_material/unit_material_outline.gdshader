// NOTE: Shader automatically converted from Godot Engine 4.2.1.stable's StandardMaterial3D.

shader_type spatial;
render_mode blend_mix,depth_prepass_alpha,cull_front,unshaded;
uniform vec4 albedo : source_color;
uniform float grow;

uniform float time_value;
uniform float max_grey;
uniform float red_multiply;
uniform float green_multiply;

void vertex() {
	VERTEX+=NORMAL*grow;
}

void fragment() {
	ALBEDO = albedo.rgb;

	float grey = dot(ALBEDO.rgb, vec3(max_grey));
	ALBEDO = mix(ALBEDO.rgb, vec3(grey), time_value);
	ALPHA = 1.0 - time_value;
	ALBEDO.r *= red_multiply;
	ALBEDO.g *= green_multiply;
}
