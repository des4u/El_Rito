if (!vhs_enabled) exit;
if (!surface_exists(application_surface)) exit;

var _sw = display_get_gui_width();
var _sh = display_get_gui_height();
var _t  = current_time / 1000.0;

if (surface_exists(surf) && (surface_get_width(surf) != _sw || surface_get_height(surf) != _sh)) {
    surface_free(surf);
    surf = -1;
}
if (surface_exists(shadow_surf) && (surface_get_width(shadow_surf) != _sw || surface_get_height(shadow_surf) != _sh)) {
    surface_free(shadow_surf);
    shadow_surf = -1;
}
if (!surface_exists(surf))        surf        = surface_create(_sw, _sh);
if (!surface_exists(shadow_surf)) shadow_surf = surface_create(_sw, _sh);

surface_set_target(surf);
    draw_clear_alpha(c_black, 1);
    gpu_set_blendmode(bm_normal);
    draw_surface_stretched(application_surface, 0, 0, _sw, _sh);
surface_reset_target();

var _cx = camera_get_view_x(view_camera[0]);
var _cy = camera_get_view_y(view_camera[0]);
var _vw = camera_get_view_width(view_camera[0]);
var _vh = camera_get_view_height(view_camera[0]);
var _scale_x = _sw / _vw;
var _scale_y = _sh / _vh;

var _count = min(ds_list_size(light_list), 16);
var _lights_arr = array_create(_count * 4, 0);
var _colors_arr = array_create(_count * 4, 0);

for (var i = 0; i < _count; i++) {
    var _l = light_list[| i];
    var _type_id = 0;
    if (_l.type == "candle")  _type_id = 1;
    if (_l.type == "lantern") _type_id = 2;
    if (_l.type == "window")  _type_id = 3;

    var _lx = _l.x;
    var _ly = _l.y;
    if (_l.world_space) {
        _lx = (_l.x - _cx) * _scale_x;
        _ly = (_l.y - _cy) * _scale_y;
    }

    _lights_arr[i * 4 + 0] = _lx;
    _lights_arr[i * 4 + 1] = _ly;
    _lights_arr[i * 4 + 2] = _l.radius * _scale_x;
    _lights_arr[i * 4 + 3] = _l.brightness;
    _colors_arr[i * 4 + 0] = _l.cr;
    _colors_arr[i * 4 + 1] = _l.cg;
    _colors_arr[i * 4 + 2] = _l.cb;
    _colors_arr[i * 4 + 3] = _type_id;
}

var _ctrl = global.controlled;
var _psx = 0.5;
var _psy = 0.5;
var _prpx = 0.0;
if (player_vision_enabled && _ctrl != noone && instance_exists(_ctrl)) {
    _psx  = (_ctrl.x - _cx) * _scale_x / _sw;
    _psy  = (_ctrl.y - _cy) * _scale_y / _sh;
    _prpx = player_vision_radius * _scale_x;
}

surface_set_target(shadow_surf);
    draw_clear(c_black);
    draw_set_color(c_white);
    draw_set_alpha(1);
    with (obj_wall) {
        var _wx1 = (bbox_left   - _cx) * _scale_x;
        var _wy1 = (bbox_top    - _cy) * _scale_y;
        var _wx2 = (bbox_right  - _cx) * _scale_x;
        var _wy2 = (bbox_bottom - _cy) * _scale_y;
        draw_rectangle(_wx1, _wy1, _wx2, _wy2, false);
    }
surface_reset_target();

shader_set(shd_vhs_shader);
    texture_set_stage(uni_shadowmap, surface_get_texture(shadow_surf));
    gpu_set_tex_repeat_ext(uni_shadowmap, false);
    gpu_set_tex_filter_ext(uni_shadowmap, false);
    shader_set_uniform_f(uni_time,          _t);
    shader_set_uniform_f(uni_resolution,    _sw, _sh);
    shader_set_uniform_f(uni_intensity,     vhs_intensity);
    shader_set_uniform_f(uni_ambient,       ambient_r, ambient_g, ambient_b);
    shader_set_uniform_f(uni_flicker,       flicker_intensity);
    shader_set_uniform_i(uni_light_count,   _count);
    shader_set_uniform_f(uni_player_pos,    _psx, _psy);
    shader_set_uniform_f(uni_player_radius, _prpx);
    if (_count > 0) {
        shader_set_uniform_f_array(uni_lights,       _lights_arr);
        shader_set_uniform_f_array(uni_light_colors, _colors_arr);
    }
    draw_surface(surf, 0, 0);
shader_reset();