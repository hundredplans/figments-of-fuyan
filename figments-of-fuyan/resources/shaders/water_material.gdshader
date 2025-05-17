shader_type spatial;

uniform vec3 color: source_color;

void fragment() {
	ALBEDO = color;
	METALLIC = 0.75;
	ROUGHNESS = 0.2;
}
