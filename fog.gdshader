shader_type canvas_item;

uniform sampler2D noise1: repeat_enable;
uniform sampler2D noise2: repeat_enable;
uniform vec2 scroll = vec2(0.05, 0.05);
uniform vec2 scroll2 = vec2(-0.05, -0.05);
uniform float distortion_strength: hint_range(-1,1) = 0.2;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

void fragment() {
	vec4 noise_col = texture(noise, UV + scroll * TIME);
	vec4 screen_col = texture(SCREEN_TEXTURE, SCREEN_UV + distortion_strength * noise_col.rr);
	COLOR = screen_col;
}
