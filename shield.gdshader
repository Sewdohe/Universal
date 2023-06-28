shader_type canvas_item;

uniform float scale = 100.0;
uniform sampler2D SCREEN_TEXTURE: hint_screen_texture, filter_linear_mipmap;

void fragment() {
	vec2 modified_uv = UV - 0.5;
	vec2 local_uv = vec2(fract((modified_uv * length(modified_uv)) * scale)) - 0.5;
	
	float large_dist = length(modified_uv);
	float grid_dist = length(local_uv);
	float grid_alpha = smoothstep(0.1, 0.05, grid_dist)
						* (smoothstep(0.5, 0.4, large_dist) * smoothstep(0.25, 0.5, large_dist));
						
	
	float uv_height = SCREEN_PIXEL_SIZE.y / TEXTURE_PIXEL_SIZE.y;
	vec2 shield_uv = vec2(SCREEN_UV.x, SCREEN_UV.y + uv_height * UV.y);
	
	vec3 final_color = mix(vec3(0.0, 1.0, 1.0), texture(SCREEN_TEXTURE, shield_uv).rgb, 0.01);
	float final_alpha = grid_alpha;
	COLOR = vec4(final_color, final_alpha);
}
