shader_type canvas_item;
uniform vec4 outline_color: source_color = vec4(1, 1, 1, 1);
uniform int BORDER_SIZE = 3;

void fragment() {
    if (COLOR.a < 0.01) {
        for(int y = -BORDER_SIZE; y <= BORDER_SIZE; y++) {
            for(int x = -BORDER_SIZE; x <= BORDER_SIZE; x++) {
                vec2 pos = vec2(float(x), float(y));
                if(texture(TEXTURE, UV + (pos * TEXTURE_PIXEL_SIZE)).a > 0.99) {
                    COLOR = outline_color;
                    break;
                }
            }
        }
    }
}