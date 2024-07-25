shader_type canvas_item;

uniform float move_speed = 20.0;
void vertex() {
	if (UV.x > 0.6) {
		VERTEX.x += sin(TIME * move_speed);
	}
	else if (UV.x < 0.2) {
		VERTEX.x -= sin(TIME * move_speed);
	}
}
