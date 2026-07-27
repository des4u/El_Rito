if (keyboard_check_pressed(vk_f9)) {
    active = !active;
    editing = false;
    filtering = false;
    keyboard_string = "";
    if (active) {
        refresh_globals();
        refresh_actives();
        if (instance_exists(obj_shader_controller)) {
            prev_vision = obj_shader_controller.player_vision_enabled;
            obj_shader_controller.player_vision_enabled = false;
        }
        light_set_ambient(1, 1, 1, true);
    } else {
        stack = [];
        if (instance_exists(obj_shader_controller)) {
            obj_shader_controller.player_vision_enabled = prev_vision;
        }
    }
}

global.devmenu = active;
if (msg_t > 0) msg_t--;
if (!active) exit;

while (array_length(stack) > 0) {
    var _r = cur_ref();
    if (is_struct(_r) || is_array(_r) || is_inst(_r)) break;
    pop_ref();
}

if (editing) {
    if (keyboard_check_pressed(vk_escape)) { editing = false; keyboard_string = ""; }
    if (keyboard_check_pressed(vk_enter)) {
        apply_edit(keyboard_string);
        editing = false;
        keyboard_string = "";
    }
    exit;
}

if (filtering) {
    filter = keyboard_string;
    sel = 0;
    top = 0;
    if (keyboard_check_pressed(vk_escape)) { filter = ""; filtering = false; keyboard_string = ""; }
    else if (keyboard_check_pressed(vk_enter)) { filtering = false; keyboard_string = ""; }
    exit;
}

if (keyboard_check_pressed(vk_tab)) {
    filtering = true;
    keyboard_string = filter;
    exit;
}

if (keyboard_check_pressed(vk_f7)) ui_lines = min(ui_lines + 2, 30);
if (keyboard_check_pressed(vk_f8)) ui_lines = max(ui_lines - 2, 5);

if (array_length(stack) == 0 && tab == 3) refresh_actives();

var _deep = array_length(stack) > 0;

if (keyboard_check_pressed(vk_backspace) && _deep) pop_ref();

if (!_deep) {
    if (keyboard_check_pressed(vk_right)) { tab = (tab + 1) mod 4; sel = 0; top = 0; filter = ""; }
    if (keyboard_check_pressed(vk_left))  { tab = (tab + 3) mod 4; sel = 0; top = 0; filter = ""; }
} else {
    if (keyboard_check_pressed(vk_left)) pop_ref();
}

var _l = list_of();
var _n = array_length(_l);

if (_n > 0) {
    if (keyboard_check_pressed(vk_down)) sel = (sel + 1) mod _n;
    if (keyboard_check_pressed(vk_up))   sel = (sel + _n - 1) mod _n;
    if (keyboard_check_pressed(vk_pagedown)) sel = min(sel + rows, _n - 1);
    if (keyboard_check_pressed(vk_pageup))   sel = max(sel - rows, 0);
    if (mouse_wheel_down()) sel = min(sel + 1, _n - 1);
    if (mouse_wheel_up())   sel = max(sel - 1, 0);
    if (keyboard_check_pressed(vk_enter)) do_action();
}

if (keyboard_check_pressed(vk_delete)) {
    if (!_deep && tab == 3 && _n > 0) {
        var _t = _l[clamp(sel, 0, _n - 1)];
        if (instance_exists(_t)) {
            notify("destruido " + object_get_name(_t.object_index));
            instance_destroy(_t);
            refresh_actives();
            sel = max(sel - 1, 0);
        }
    } else {
        var _i = instance_position(mouse_x, mouse_y, all);
        if (_i != noone && _i != id) { instance_destroy(_i); notify("destruido"); }
    }
}

_n = array_length(list_of());
sel = clamp(sel, 0, max(_n - 1, 0));
if (sel < top) top = sel;
if (sel > top + rows - 1) top = sel - rows + 1;
top = clamp(top, 0, max(_n - rows, 0));