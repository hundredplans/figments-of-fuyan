shader_type canvas_item;

instance uniform vec4 outline_color;
instance uniform int border_size;

void fragment() {
    if (COLOR.a < 0.01) {
        for(int y = -border_size; y <= border_size; y++) {
            for(int x = -border_size; x <= border_size; x++) {
                vec2 pos = vec2(float(x), float(y));
                if(texture(TEXTURE, UV + (pos * TEXTURE_PIXEL_SIZE)).a > 0.99) {
                    COLOR = vec4(outline_color.r, outline_color.g, outline_color.b, 1.0);
                    break;
                }
            }
        }
    }
}