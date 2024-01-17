shader_type canvas_item;
uniform vec3 replacement_color:source_color;

void fragment() {
	vec3 color_without_green = COLOR.rgb * vec3(1, 0, 1);
	float amount_of_red_and_blue = length(color_without_green);
	float red_and_blue_mask = step(0.05, amount_of_red_and_blue);
	
	vec3 retained_color = COLOR.rgb * red_and_blue_mask;
	float green_mask = (1.0 - red_and_blue_mask) * COLOR.g;
	vec3 mask_replacement_color = replacement_color * green_mask;
	
	COLOR.rgb = vec3(retained_color + mask_replacement_color);
}
