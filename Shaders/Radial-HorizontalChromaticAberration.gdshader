shader_type canvas_item;

uniform float intensity: hint_range(0.0, 5.0, 0.1) = 1.0;
uniform float threshold: hint_range(0.0, 2.0, 0.1) = 1.0;

uniform sampler2D screen_texture : hint_screen_texture, filter_nearest;

float vector_angle(vec2 v) {
    if (abs(v.x) < 0.0001 && abs(v.y) < 0.0001) {
        return 0.0; // Default angle for zero vector
    }
    return atan(v.y, v.x);
}

vec2 rotate_vector(vec2 v, float cos_theta, float sin_theta) {
    return vec2(
        v.x * cos_theta - v.y * sin_theta,
        v.x * sin_theta + v.y * cos_theta
    );
}

void fragment() {
	// Horizontal displacement only (no rotation)
	// Blue shifts left (-1), Red stays (0), Green shifts right (+1)
	vec2 r_displacement = vec2(0.0, 0.0);   // Red stays centered
	vec2 g_displacement = vec2(1.0, 0.0);   // Green shifts right
	vec2 b_displacement = vec2(-1.0, 0.0);  // Blue shifts left
	
	vec2 center = vec2(0.5);
	vec2 dir = SCREEN_UV - center;
	float dist = 2.0 * length(dir);
	
	float effect = exp(intensity * (dist - threshold));
	float displacement_amount = effect * intensity;
	
	vec2 r_uv = SCREEN_UV + r_displacement * displacement_amount * SCREEN_PIXEL_SIZE;
	vec2 g_uv = SCREEN_UV + g_displacement * displacement_amount * SCREEN_PIXEL_SIZE;
	vec2 b_uv = SCREEN_UV + b_displacement * displacement_amount * SCREEN_PIXEL_SIZE;
	
	float r = texture(screen_texture, r_uv, 0.0).r;
	float g = texture(screen_texture, g_uv, 0.0).g;
	float b = texture(screen_texture, b_uv, 0.0).b;
	float a = texture(screen_texture, SCREEN_UV).a;
	
	COLOR = vec4(r, g, b, a);
}
