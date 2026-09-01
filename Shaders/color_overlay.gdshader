shader_type canvas_item;
render_mode unshaded;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;
uniform vec3 flash_color : source_color = vec3(1.0, 1.0, 1.0);
instance uniform float flash_value : hint_range(0.0, 1.0, 0.) = 0.1;

void fragment() {
	vec4 group_texture_color = textureLod(screen_texture, SCREEN_UV, 0.0);
	vec3 flashed_texture_color = mix(group_texture_color.rgb, flash_color, flash_value).rgb;
	COLOR = vec4(flashed_texture_color, group_texture_color.a);
}
