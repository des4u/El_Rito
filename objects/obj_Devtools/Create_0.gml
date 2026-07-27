if (instance_number(object_index) > 1) { instance_destroy(); exit; }

persistent = true;
depth = -16000;
global.devmenu = false;

active = false;
tab = 0;
sel = 0;
top = 0;
rows = 12;
ui_lines = 11;
editing = false;
filtering = false;
filter = "";
edit_ref = -1;
edit_key = "";
msg = "";
msg_t = 0;
prev_vision = true;
stack = [];

tab_names = ["ROOMS", "OBJETOS", "GLOBALS", "ACTIVOS"];

col_bg     = make_color_rgb(8, 12, 10);
col_bg2    = make_color_rgb(18, 26, 21);
col_accent = make_color_rgb(70, 255, 130);
col_fg     = make_color_rgb(225, 255, 235);
col_dim    = make_color_rgb(105, 150, 120);
col_edit   = make_color_rgb(255, 215, 80);

dev_font = -1;
if (asset_get_type("fnt_dev") == asset_font) dev_font = asset_get_index("fnt_dev");

inst_builtin = ["x", "y", "hspeed", "vspeed", "speed", "direction", "sprite_index", "image_index", "image_speed", "image_xscale", "image_yscale", "image_angle", "image_alpha", "image_blend", "depth", "visible", "solid", "persistent"];

all_rooms = [];
for (var i = 0; i < 1000; i++) if (room_exists(i)) array_push(all_rooms, i);

all_objs = [];
for (var i = 0; i < 5000; i++) if (object_exists(i)) array_push(all_objs, i);

all_vars = [];
all_inst = [];

dtext = function(_x, _y, _str, _sc) {
    var _o = max(1, round(_sc * 0.18));
    draw_text_transformed(_x, _y, _str, _sc, _sc, 0);
    draw_text_transformed(_x + _o, _y, _str, _sc, _sc, 0);
}

notify = function(_t) { msg = _t; msg_t = 120; }

is_inst = function(_v) {
    var _t = typeof(_v);
    if (_t == "ref") return instance_exists(_v);
    if (_t != "number" && _t != "int32" && _t != "int64") return false;
    if (_v < 100000 || _v != floor(_v)) return false;
    return instance_exists(_v);
}

preview = function(_v) {
    if (is_undefined(_v)) return "undefined";
    if (is_method(_v))    return "<method>";
    if (is_array(_v))     return "<array " + string(array_length(_v)) + ">";
    if (is_struct(_v))    return "<struct>";
    if (is_bool(_v))      return _v ? "true" : "false";
    if (is_string(_v))    return "\"" + _v + "\"";
    if (is_inst(_v))      return "<" + object_get_name(_v.object_index) + ">";
    return string(_v);
}

refresh_globals = function() {
    all_vars = variable_instance_get_names(global);
    array_sort(all_vars, true);
}
refresh_globals();

refresh_actives = function() {
    all_inst = [];
    with (all) if (id != other.id) array_push(other.all_inst, id);
}

ref_names = function(_r) {
    if (is_array(_r)) {
        var _a = [];
        for (var i = 0; i < array_length(_r); i++) array_push(_a, string(i));
        return _a;
    }
    if (is_struct(_r)) {
        var _a = variable_struct_get_names(_r);
        array_sort(_a, true);
        return _a;
    }
    if (is_inst(_r)) {
        var _a = variable_instance_get_names(_r);
        var _seen = {};
        for (var i = 0; i < array_length(_a); i++) variable_struct_set(_seen, _a[i], 1);
        for (var i = 0; i < array_length(inst_builtin); i++) {
            if (!variable_struct_exists(_seen, inst_builtin[i])) array_push(_a, inst_builtin[i]);
        }
        array_sort(_a, true);
        return _a;
    }
    return [];
}

ref_get = function(_r, _k) {
    if (is_array(_r)) return _r[real(_k)];
    if (is_struct(_r)) return variable_struct_get(_r, _k);
    return variable_instance_get(_r, _k);
}

ref_set = function(_r, _k, _v) {
    if (is_array(_r)) { _r[real(_k)] = _v; return; }
    if (is_struct(_r)) { variable_struct_set(_r, _k, _v); return; }
    variable_instance_set(_r, _k, _v);
}

cur_ref = function() {
    var _c = array_length(stack);
    if (_c == 0) return undefined;
    return stack[_c - 1].ref;
}

push_ref = function(_r, _name) {
    array_push(stack, { ref: _r, name: _name });
    sel = 0; top = 0; filter = "";
}

pop_ref = function() {
    if (array_length(stack) > 0) { array_pop(stack); sel = 0; top = 0; filter = ""; }
}

row_key = function(_v) {
    if (array_length(stack) > 0) return string(_v);
    switch (tab) {
        case 0: return room_get_name(_v);
        case 1: return object_get_name(_v);
        case 2: return _v;
        case 3: return instance_exists(_v) ? object_get_name(_v.object_index) : "destruido";
    }
    return "";
}

row_label = function(_v) {
    if (array_length(stack) > 0) return string(_v) + " = " + preview(ref_get(cur_ref(), _v));
    switch (tab) {
        case 0: return room_get_name(_v);
        case 1: return object_get_name(_v);
        case 2: return _v + " = " + preview(variable_global_exists(_v) ? variable_global_get(_v) : undefined);
        case 3:
            if (!instance_exists(_v)) return "<destruido>";
            return object_get_name(_v.object_index) + "   " + string(floor(_v.x)) + "," + string(floor(_v.y));
    }
    return "";
}

list_of = function() {
    var _src = [];
    if (array_length(stack) > 0) _src = ref_names(cur_ref());
    else {
        switch (tab) {
            case 0: _src = all_rooms; break;
            case 1: _src = all_objs; break;
            case 2: _src = all_vars; break;
            case 3: _src = all_inst; break;
        }
    }
    if (filter == "") return _src;
    var _f = string_lower(filter);
    var _out = [];
    for (var i = 0; i < array_length(_src); i++) {
        if (string_pos(_f, string_lower(row_key(_src[i]))) > 0) array_push(_out, _src[i]);
    }
    return _out;
}

start_edit = function(_ref, _key, _val) {
    editing = true;
    edit_ref = _ref;
    edit_key = _key;
    keyboard_string = is_string(_val) ? _val : string(_val);
}

open_value = function(_ref, _key, _val) {
    if (is_struct(_val) || is_array(_val) || is_inst(_val)) { push_ref(_val, _key); return; }
    if (is_bool(_val)) {
        if (_ref == -1) variable_global_set(_key, !_val); else ref_set(_ref, _key, !_val);
        notify(_key + " = " + string(!_val));
        return;
    }
    if (is_real(_val) || is_string(_val)) { start_edit(_ref, _key, _val); return; }
    notify("no editable");
}

do_action = function() {
    var _l = list_of();
    if (array_length(_l) == 0) return;
    sel = clamp(sel, 0, array_length(_l) - 1);
    var _v = _l[sel];

    if (array_length(stack) > 0) {
        var _r = cur_ref();
        open_value(_r, _v, ref_get(_r, _v));
        return;
    }

    switch (tab) {
        case 0:
            door_goto(_v,"-1");
            notify("room -> " + room_get_name(_v));
        break;
        case 1:
            instance_create_depth(mouse_x, mouse_y, 0, _v);
            notify("creado " + object_get_name(_v));
        break;
        case 2:
            open_value(-1, _v, variable_global_exists(_v) ? variable_global_get(_v) : 0);
        break;
        case 3:
            if (instance_exists(_v)) push_ref(_v, object_get_name(_v.object_index) + " " + string(real(_v)));
            else notify("ya no existe");
        break;
    }
}

apply_edit = function(_txt) {
    var _old = (edit_ref == -1) ? variable_global_get(edit_key) : ref_get(edit_ref, edit_key);
    var _new = _txt;
    if (is_real(_old)) {
        try { _new = real(_txt); }
        catch (_e) { notify("valor invalido"); return; }
    }
    if (edit_ref == -1) variable_global_set(edit_key, _new);
    else ref_set(edit_ref, edit_key, _new);
    notify(edit_key + " = " + preview(_new));
}