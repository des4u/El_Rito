persistent = true;

// Shaders
shd_freeze = shd_trans_freeze;
shd_fade   = shd_trans_fade;
shd_static = shd_trans_static;

// Uniforms freeze
uni_freeze_time     = shader_get_uniform(shd_freeze, "u_time");
uni_freeze_progress = shader_get_uniform(shd_freeze, "u_progress");
uni_freeze_res      = shader_get_uniform(shd_freeze, "u_resolution");

// Uniforms fade
uni_fade_time     = shader_get_uniform(shd_fade, "u_time");
uni_fade_progress = shader_get_uniform(shd_fade, "u_progress");
uni_fade_res      = shader_get_uniform(shd_fade, "u_resolution");

// Uniforms static
uni_static_time     = shader_get_uniform(shd_static, "u_time");
uni_static_progress = shader_get_uniform(shd_static, "u_progress");
uni_static_res      = shader_get_uniform(shd_static, "u_resolution");

// Estado de transicion
trans_active    = false;
trans_type      = 0;
trans_progress  = 0.0;
trans_duration  = 1.2;
trans_target    = -1;
trans_timer     = 0.0;
trans_changed   = false;

// Estado de fade in
fadein_active   = false;
fadein_type     = 0;
fadein_progress = 0.0;
fadein_duration = 1.0;
fadein_timer    = 0.0;

surf = -1;
depth = -9999;
effect_active   = false;
effect_type     = 0;
effect_progress = 0.0;
effect_timer    = 0.0;
effect_speed    = 1.5; 

trans_black_duration = 0.5; 
trans_black_timer    = 0.0;
trans_black_waiting  = false;