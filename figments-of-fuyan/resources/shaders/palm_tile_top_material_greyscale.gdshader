shader_type spatial;

uniform sampler2D noise_tx;
uniform vec3 tile_color: source_color;
uniform vec3 tile_spot_color: source_color;
uniform float noise_cutoff = 0.2;
uniform float max_grey = 0.1;
uniform float texture_scale = 4.0;

void fragment() {
	vec2 world_uv_offset = (NODE_POSITION_WORLD.xz) / texture_scale;
	vec2 uv = UV + world_uv_offset;
	float noise = texture(noise_tx, uv).r;
	if (noise > noise_cutoff){
		ALBEDO = tile_color;
	}
	else {
		ALBEDO = tile_spot_color;
	}
	ALBEDO = vec3(dot(ALBEDO.rgb, vec3(max_grey)));
}


