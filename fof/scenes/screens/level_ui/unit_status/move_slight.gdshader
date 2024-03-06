shader_type canvas_item;

void vertex() {
	VERTEX.y += sin(TIME * 3.0) * 3.0 * UV.x;
}