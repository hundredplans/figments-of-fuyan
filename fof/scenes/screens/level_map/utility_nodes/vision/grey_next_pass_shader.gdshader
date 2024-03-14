shader_type spatial;

void fragment() {
	float grey = (ALBEDO.r + ALBEDO.g + ALBEDO.b) * 0.05;
	ALBEDO = vec3(grey);
}