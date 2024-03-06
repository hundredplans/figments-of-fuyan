shader_type canvas_item;

uniform vec4 modulate : source_color;
uniform float SPEED = 0.2;
uniform vec2 DIRECTION = vec2(1.0, 0.0);

void fragment(){
	COLOR = texture(TEXTURE, UV - (DIRECTION * TIME * SPEED)) * modulate;
}
