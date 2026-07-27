persistent = true;

shader_freeze = shd_fx_freeze;
shader_fade   = shd_fx_fade;
shader_static = shd_fx_static;

uni_freeze_time = shader_get_uniform(shader_freeze, "u_time");
uni_freeze_res  = shader_get_uniform(shader_freeze, "u_resolution");

uni_fade_time   = shader_get_uniform(shader_fade, "u_time");
uni_fade_res    = shader_get_uniform(shader_fade, "u_resolution");

uni_static_time = shader_get_uniform(shader_static, "u_time");
uni_static_res  = shader_get_uniform(shader_static, "u_resolution");

fx_active = false;
fx_type   = 0;
depth = -10000
surf = -1;