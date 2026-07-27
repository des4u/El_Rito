if (!surface_exists(surf)) exit;
var _t  = current_time / 1000.0;
var _w  = display_get_gui_width();
var _h  = display_get_gui_height();

if (trans_active) {
	if (trans_type == 4) {
		draw_set_color(c_black);
		draw_rectangle(0, 0, _w, _h, false);
		draw_set_alpha(1);
		exit;
	}
    if (trans_type == 3) {
        draw_set_alpha(trans_progress);
        draw_set_color(c_black);
        draw_rectangle(0, 0, _w, _h, false);
        draw_set_alpha(1);
        exit;
    }
    var _shd = -1;
    if (trans_type == 0) _shd = shd_freeze;
    if (trans_type == 1) _shd = shd_fade;
    if (trans_type == 2) _shd = shd_static;
    shader_set(_shd);
        if (trans_type == 0) {
            shader_set_uniform_f(uni_freeze_time,     _t);
            shader_set_uniform_f(uni_freeze_progress, trans_progress);
            shader_set_uniform_f(uni_freeze_res,      _w, _h);
        }
        if (trans_type == 1) { //este lo hice con el shader, pero no funciona y de hecho bugea todo, usar el 3
            shader_set_uniform_f(uni_fade_time,     _t);
            shader_set_uniform_f(uni_fade_progress, trans_progress);
            shader_set_uniform_f(uni_fade_res,      _w, _h);
        }
        if (trans_type == 2) {
            shader_set_uniform_f(uni_static_time,     _t);
            shader_set_uniform_f(uni_static_progress, trans_progress);
            shader_set_uniform_f(uni_static_res,      _w, _h);
        }
        draw_surface(surf, 0, 0);
    shader_reset();
    exit;
}

if (fadein_active) {
	if (fadein_type == 4) {
		draw_set_alpha(1.0 - fadein_progress);
		draw_set_color(c_black);
		draw_rectangle(0, 0, _w, _h, false);
		draw_set_alpha(1);
		exit;
	}
    if (fadein_type == 3) {
        draw_set_alpha(1.0 - fadein_progress);
        draw_set_color(c_black);
        draw_rectangle(0, 0, _w, _h, false);
        draw_set_alpha(1);
        exit;
    }
    var _inv = 1.0 - fadein_progress;
    var _shd = -1;
    if (fadein_type == 0) _shd = shd_freeze;
    if (fadein_type == 1) _shd = shd_fade;
    if (fadein_type == 2) _shd = shd_static;
    shader_set(_shd);
        if (fadein_type == 0) {
            shader_set_uniform_f(uni_freeze_time,     _t);
            shader_set_uniform_f(uni_freeze_progress, _inv);
            shader_set_uniform_f(uni_freeze_res,      _w, _h);
        }
        if (fadein_type == 1) {
            shader_set_uniform_f(uni_fade_time,     _t);
            shader_set_uniform_f(uni_fade_progress, _inv);
            shader_set_uniform_f(uni_fade_res,      _w, _h);
        }
        if (fadein_type == 2) {
            shader_set_uniform_f(uni_static_time,     _t);
            shader_set_uniform_f(uni_static_progress, _inv);
            shader_set_uniform_f(uni_static_res,      _w, _h);
        }
        draw_surface(surf, 0, 0);
    shader_reset();
}

if (effect_active) {
    var _shd = -1;
    if (effect_type == 0) _shd = shd_freeze;
    if (effect_type == 1) _shd = shd_fade;
    if (effect_type == 2) _shd = shd_static;
    shader_set(_shd);
        if (effect_type == 0) {
            shader_set_uniform_f(uni_freeze_time,     _t);
            shader_set_uniform_f(uni_freeze_progress, effect_progress);
            shader_set_uniform_f(uni_freeze_res,      _w, _h);
        }
        if (effect_type == 1) {
            shader_set_uniform_f(uni_fade_time,     _t);
            shader_set_uniform_f(uni_fade_progress, effect_progress);
            shader_set_uniform_f(uni_fade_res,      _w, _h);
        }
        if (effect_type == 2) {
            shader_set_uniform_f(uni_static_time,     _t);
            shader_set_uniform_f(uni_static_progress, effect_progress);
            shader_set_uniform_f(uni_static_res,      _w, _h);
        }
        draw_surface(surf, 0, 0);
    shader_reset();
}