shader_type spatial;

uniform sampler2D texture_albedo;
void fragment() {
	ALBEDO *= texture(texture_albedo, UV).rgb;
	//ALBEDO = vec3(1, 0.953, 0.11);
}
