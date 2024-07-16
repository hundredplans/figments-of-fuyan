// NOTE: Shader automatically converted from Godot Engine 4.2.1.stable's StandardMaterial3D.

shader_type spatial;
render_mode blend_mix,depth_prepass_alpha,cull_back;
uniform vec4 albedo : source_color;
uniform sampler2D texture_albedo : source_color,filter_linear_mipmap,repeat_enable;

uniform float time_value;
uniform float max_grey;
uniform float grow;

void vertex() {
	VERTEX+=NORMAL*grow;
}

void fragment() {
	vec2 base_uv = UV;
	vec4 albedo_tex = texture(texture_albedo,base_uv);
	ALBEDO = albedo.rgb * albedo_tex.rgb;
	
	float grey = dot(ALBEDO.rgb, vec3(max_grey));
	ALBEDO = mix(ALBEDO.rgb, vec3(grey), time_value);
	ALPHA = 1.0 - time_value;
}
