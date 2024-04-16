shader_type canvas_item;
uniform int BORDER_SIZE = 3;

void fragment() {
	if (COLOR.a < 0.01) {
	    for(int y = -BORDER_SIZE; y <= BORDER_SIZE; y++) {
		    for(int x = -BORDER_SIZE; x <= BORDER_SIZE; x++) {
				vec2 pos = vec2(float(x), float(y));
		        if(texture(TEXTURE, UV + (pos * TEXTURE_PIXEL_SIZE)).a > 0.99) {
		            COLOR = vec4(1.0 , 1.0, 1.0, 1.0);
		            break;
		        }
			}
	    }
	}
}