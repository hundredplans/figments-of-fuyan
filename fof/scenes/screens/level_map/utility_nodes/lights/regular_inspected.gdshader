shader_type spatial;
uniform vec3 hover_color;

void fragment() {
	ALBEDO = hover_color;
}
