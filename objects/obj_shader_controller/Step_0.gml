vhs_intensity = lerp(vhs_intensity, vhs_target_intensity, 0.07);
ambient_r = lerp(ambient_r, target_ambient_r, ambient_speed);
ambient_g = lerp(ambient_g, target_ambient_g, ambient_speed);
ambient_b = lerp(ambient_b, target_ambient_b, ambient_speed);
if (abs(ambient_r - target_ambient_r) < 0.01) ambient_r = target_ambient_r;
if (abs(ambient_g - target_ambient_g) < 0.01) ambient_g = target_ambient_g;
if (abs(ambient_b - target_ambient_b) < 0.01) ambient_b = target_ambient_b;

if (keyboard_check_pressed(vk_f11)) {
    window_set_fullscreen(!window_get_fullscreen());
}