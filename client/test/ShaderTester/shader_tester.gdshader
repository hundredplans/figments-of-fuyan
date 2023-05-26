shader_type spatial;
render_mode specular_toon;

uniform sampler2D noise;

float wave(vec2 position){
	position += texture(noise, position / 10.0).x * 2.0 - 1.0; // * 2 -1 maps the value from 0.0, 1.0 to -1.0, 1.0
	vec2 wv = 1.0 - abs(sin(position)); // sin(position) returns a vec2 with two values between -1.0 to 1.0, abs turns this into a 0.0 to 1.0
	// 1.0 is necessary to inverse the value, sin generates 0 at the center and 1 at edges, 1.0 - inverses that, in this case
	// 0 is top, 1 is bottom this puts the peak of the wave at the top
	return pow(1.0 - pow(wv.x * wv.y, 0.65), 4.0); // wv is between 0 and 1 due to previous statement
	// its raised to an arbitrary power then subtracted by 1 resulting in a range of 0.0 to 1.0 still
	// raised to the power of 4 produces a smaller value when the number is close to 1 and bigger when its close to 0
}

float height(vec2 position, float time) { // dont question it...
  float d = wave((position + time) * 0.4) * 0.3;
  d += wave((position - time) * 0.3) * 0.3;
  d += wave((position + time) * 0.5) * 0.2;
  d += wave((position - time) * 0.6) * 0.2;
  return d;
}

float _height(vec2 position, float time) {
	vec2 offset = 0.01 * cos(position + time); // cos confines a value to between -1 and 1, 0.01 confines the value to between -0.01 and 0.01
	vec2 confined_position = position / 10.0; // 2.0 is the size, position is confined to -1 and 1
	vec2 confined_offset_position = confined_position - offset; // - offset since it can be -0.01 to 0.01 
	return texture(noise, confined_offset_position).x; // we take .x of the noise texture, can be x,y,z
	// texture takes a texture (noise) and a UV (position between 0 and 1)
}

void vertex() {
	vec2 pos = VERTEX.xz; // we get the .xz of each coordinate
	float k = height(pos, TIME);
	NORMAL = normalize(vec3(k - height(pos + vec2(0.1, 0.0), TIME), 0.1, k - height(pos + vec2(0.0, 0.1), TIME))); // computes NORMAL manually
	// ^ creates a vec3 with vec3(difference in z height, 0.1, difference in x height), this somehow gives a normal
	VERTEX.y = k;
}

void fragment() {
	float fresnel = sqrt(1.0 - dot(NORMAL, VIEW));
	RIM = 0.2;
	METALLIC = 0.0;
	ROUGHNESS = 0.01 * (1.0 - fresnel);
	ALBEDO = vec3(0.01, 0.03, 0.05) + (0.1 * fresnel);
}

