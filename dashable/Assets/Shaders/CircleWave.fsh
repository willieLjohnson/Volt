// A circular pulsating wave effect
// Uniform: u_speed, speed and direction of travel.
// Uniform: u_brightness, color brightness.
// Uniform: u_strength, wave intensity.
// Uniform: u_density, wave size.
// Uniform: u_center, the gradient's center poin. (0.5, 0.5) is dead center.
// Uniform: u_color, the SKColor to use.

void main() {
    vec4 current_color = SKDefaultShading();
    if (current_color.a > 0.0) {
        float wave_speed = -(u_time * u_speed * 10.0);
        vec3 brightness = vec3(u_brightness);
        float pixel_distance = distance(v_tex_coord, u_center);
        vec3 gradient_color = vec3(u_color.r, u_color.g, u_color.b) * brightness;
        float color_strength = pow(1.0 - pixel_distance, 3.0);

        color_strength *= u_strength;

        float wave_density = u_density * pixel_distance;
        float cosine = cos(wave_speed + wave_density);
        float cosine_adjustment = (0.5 * cosine) + 0.5;
        float luma = color_strength * (u_strength + cosine_adjustment);

        luma *= 1.0 - (pixel_distance * 2.0);
        luma = max(0.0, luma);

        vec4 final_color = vec4(gradient_color * luma, luma);

        gl_FragColor = final_color * current_color.a * v_color_mix.a;
    } else {
        gl_FragColor = current_color;
    }
}


