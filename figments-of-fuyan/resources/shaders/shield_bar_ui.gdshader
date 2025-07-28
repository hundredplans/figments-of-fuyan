shader_type canvas_item;
uniform vec4 lowest_color: source_color;
uniform vec4 highest_color: source_color;
uniform float line_width = 48.0;
uniform float spacing = 96.0;
uniform float color_speed = 2.0;
uniform float speed = 20.0;
uniform vec2 rect_size = vec2(1070.0, 30.0);

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec2 pixel = UV * rect_size;
	pixel.x += (-TIME) * speed;
	float d = mod(pixel.x + pixel.y, spacing);
	if (d < line_width){
		float t = (sin(TIME * color_speed) + 1.0) * 0.5;
		COLOR = mix(lowest_color, highest_color, t);
	}
	else {
		discard;
	}
}

