shader_type canvas_item;

uniform vec4 modulate : source_color;
uniform float speed = 0.2;

void fragment(){
	COLOR = texture(TEXTURE, UV - (vec2(1.0, 0.0) * TIME * speed)) * modulate;
}
