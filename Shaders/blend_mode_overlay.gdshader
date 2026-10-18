shader_type canvas_item;


uniform float overlay_opacity : hint_range(0.0, 1.0) = 1.0;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

vec3 overlay(vec3 base, vec3 blend) {
    vec3 limit = step(0.5, base);
    return mix(2.0 * base * blend, 1.0 - 2.0 * (1.0 - base) * (1.0 - blend), limit);
}

void fragment() {
    vec4 screen_color = texture(SCREEN_TEXTURE, SCREEN_UV);
    vec4 tex_color = texture(TEXTURE, UV);
    
    // Calculate the full overlay color
    vec3 overlay_rgb = overlay(screen_color.rgb, tex_color.rgb);
    
    // Mix between the original background and the overlay effect using opacity and texture alpha
    float final_blend_amount = tex_color.a * overlay_opacity;
    vec3 final_rgb = mix(screen_color.rgb, overlay_rgb, final_blend_amount);
    
    COLOR = vec4(final_rgb, screen_color.a);
}
