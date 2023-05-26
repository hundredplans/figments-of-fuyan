shader_type canvas_item;

uniform float size;
uniform float blue = 1.0;

void fragment() { // fragment runs through every UV
	COLOR = vec4(UV,0.6,0.9); // since UV is a Vec2 you only need 3 params
	COLOR = texture(TEXTURE, UV); 
	COLOR.b = blue;
}

void vertex() {
	 VERTEX += vec2(cos(TIME)*100.0, sin(TIME)*100.0);
}
