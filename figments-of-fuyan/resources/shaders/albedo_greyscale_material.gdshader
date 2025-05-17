shader_type spatial;

uniform vec3 color: source_color;
instance uniform float max_grey = 0.1;

void fragment() {
	ALBEDO = color;
	ALBEDO = vec3(dot(ALBEDO.rgb, vec3(max_grey)));
}	
