shader_type spatial;

uniform sampler2D noise_tx;
uniform vec3 tile_color: source_color;
uniform vec3 tile_spot_color: source_color;
uniform float noise_cutoff = 0.2;
uniform float texture_scale = 4.0;
uniform float noise_scale = 0.5;

void fragment() {
	vec2 world_uv_offset = (NODE_POSITION_WORLD.xz) / texture_scale;
	vec2 uv = UV * noise_scale + world_uv_offset;
	float noise = texture(noise_tx, uv).r;

	//vec2 noise_uv = UV + world_uv_offset; // smaller scale for noise distortion
	//vec2 offset = (texture(noise_tx, noise_uv).rg - 0.5) * 0.1; // tweak strength
	//vec2 final_uv = UV + world_uv_offset + offset;
	//float noise = texture(noise_tx, final_uv).r;

	if (noise > noise_cutoff){
		ALBEDO = tile_color;
	}
	else {
		ALBEDO = tile_spot_color;
	}
}
