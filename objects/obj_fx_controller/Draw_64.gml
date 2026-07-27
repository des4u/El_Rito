if (!surface_exists(surf)) {
    surf = surface_create(display_get_gui_width(), display_get_gui_height());
}

surface_copy(surf, 0, 0, application_surface);

if (!fx_active) exit;

var _t  = current_time / 1000.0;
var _w  = display_get_gui_width();
var _h  = display_get_gui_height();
var _shd = -1;

if (fx_type == 0) _shd = shader_freeze;
if (fx_type == 1) _shd = shader_fade;
if (fx_type == 2) _shd = shader_static;

shader_set(_shd);
    if (fx_type == 0) {
        shader_set_uniform_f(uni_freeze_time, _t);
        shader_set_uniform_f(uni_freeze_res,  _w, _h);
    }
    if (fx_type == 1) { //bugeado por shader
        shader_set_uniform_f(uni_fade_time, _t);
        shader_set_uniform_f(uni_fade_res,  _w, _h);
    }
    if (fx_type == 2) {
        shader_set_uniform_f(uni_static_time, _t);
        shader_set_uniform_f(uni_static_res,  _w, _h);
    }
    draw_surface(surf, 0, 0);
shader_reset();