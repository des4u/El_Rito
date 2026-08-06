if (instance_number(obj_shader_controller) > 1) {
    instance_destroy();
    exit;
}

shd_vhs_shader = shd_vhs;
uni_time       = shader_get_uniform(shd_vhs_shader, "u_time");
uni_resolution = shader_get_uniform(shd_vhs_shader, "u_resolution");
uni_intensity  = shader_get_uniform(shd_vhs_shader, "u_intensity");

vhs_intensity        = 0.0;
vhs_target_intensity = 0.8;
vhs_enabled          = true;
global.story_party_set = false;
game_set_speed(25, gamespeed_fps);
gpu_set_texfilter(false);
shadow_surf = -1;
uni_shadowmap = shader_get_sampler_index(shd_vhs_shader, "u_shadowmap");
surf = -1;
depth = -9998;
audio_play_sound(snd_vhs, 0, true);
combined_surf = -1;
uni_ambient     = shader_get_uniform(shd_vhs_shader, "u_ambient");
uni_lights      = shader_get_uniform(shd_vhs_shader, "u_lights");
uni_light_colors= shader_get_uniform(shd_vhs_shader, "u_light_colors");
uni_light_count = shader_get_uniform(shd_vhs_shader, "u_light_count");
uni_view_scale = shader_get_uniform(shd_vhs_shader, "u_view_scale");
window_set_size(VHS_WIN_W, VHS_WIN_H);
window_center();
display_set_gui_size(VHS_WIN_W, VHS_WIN_H);
global.vhs_perspective = false;
ambient_r = 0.00;
ambient_g = 0.00;
ambient_b = 0.00;
target_ambient_r = ambient_r;
target_ambient_g = ambient_g;
target_ambient_b = ambient_b;
ambient_speed    = 0.02;
uni_flicker     = shader_get_uniform(shd_vhs_shader, "u_flicker_intensity");
flicker_intensity = 1.0;
light_list = ds_list_create();

// --- Player vision ---
uni_player_pos    = shader_get_uniform(shd_vhs_shader, "u_player_pos");
uni_player_radius = shader_get_uniform(shd_vhs_shader, "u_player_radius");
player_vision_enabled = true;
player_vision_radius  = 220;  // radio en pixels del mundo
player_screen_x = 0.5;
player_screen_y = 0.5;
player_vis_radius_px = 0.0;


if (!variable_global_exists("controlled")) {
    global.controlled = noone;
}

gpu_set_tex_repeat(false);