shader_type canvas_item;

// hint_screen_texture = Use screen texture as the value
// repeat_disable (doesn't repeat outside)
// filter_nearest pixel perfect not aliased
uniform sampler2D screen_texture:hint_screen_texture,repeat_disable,filter_nearest;
uniform sampler2D noise_texture:repeat_enable;

void fragment() { // SCREEN_UV = current pixel
	// texture returns the texture at SCREEN_UV coordinates aka the value of the pixel
	vec3 noise_color = texture(noise_texture, SCREEN_UV + (TIME / 10.0)).rgb;
	vec3 color = texture(screen_texture, SCREEN_UV + (noise_color.b / 20.0)).rgb;
	color.b *= 0.8;
	color.r *= 1.2;
	color.g *= 1.2;
	COLOR.rgb = color;
}
