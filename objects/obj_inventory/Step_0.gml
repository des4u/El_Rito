for (var i = 0; i < array_length(global.stash); i++) {
    var _it = global.stash[i];
    if (_it.lit || _it.light_ref != -1) light_off(_it);
}

for (var i = 0; i < array_length(global.party); i++) {
    var _key = global.party[i];
    var _it  = char_item_get(_key);
    if (is_undefined(_it)) continue;

    if (!_it.lit) {
        if (_it.light_ref != -1) { light_remove(_it.light_ref); _it.light_ref = -1; }
        continue;
    }

    var _inst = party_get_instance(_key);
    if (!instance_exists(_inst)) {
        if (_it.light_ref != -1) { light_remove(_it.light_ref); _it.light_ref = -1; }
        continue;
    }

    _it.durability = max(_it.durability - _it.drain_rate, 0);
    if (_it.durability <= 0) {
        light_off(_it);
        continue;
    }

    if (_it.light_ref == -1) {
        _it.light_ref = light_add(_inst.x, _inst.y, _it.radius, _it.strength,
                                  _it.type, _it.cr, _it.cg, _it.cb);
    }

    var _f = (_it.durability < 0.15) ? choose(0.4, 0.7, 1.0, 0.6, 0.9) : 1.0;
    _it.light_ref.radius     = _it.radius * _f;
    _it.light_ref.brightness = _it.strength * _f;
    light_move(_it.light_ref, _inst.x, _inst.y);
}

if (!global.inv_unlocked) exit;

if (keyboard_check_pressed(ord("R")) && !dialog_blocks_input()) {
    if (global.inv_open) {
        global.inv_open = false;
    } else {
        var _c = global.controlled;
        if (instance_exists(_c) && !_c.cutscene_locked && !global.switching) {
            global.inv_open = true;
        }
    }
}

if (!global.inv_open) {
    if (!is_undefined(drag_item)) {
        stash_add(drag_item);
        drag_item = undefined;
    }
    exit;
}

if (keyboard_check_pressed(vk_escape)) {
    global.inv_open = false;
    exit;
}

var _mx = device_mouse_x_to_gui(0);
var _my = device_mouse_y_to_gui(0);
var _L  = inv_layout();

if (mouse_check_button_pressed(mb_left) && is_undefined(drag_item)) {
    for (var i = 0; i < array_length(_L.chars); i++) {
        var _c = _L.chars[i];
        if (point_in_rectangle(_mx, _my, _c.x, _c.y, _c.x + _L.s, _c.y + _L.s)) {
            var _it = char_item_take(_c.key);
            if (!is_undefined(_it)) {
                drag_item = _it;
                drag_from = "char";
                drag_key  = _c.key;
            }
            break;
        }
    }
}

if (mouse_check_button_pressed(mb_left) && is_undefined(drag_item)) {
    for (var i = 0; i < array_length(global.stash); i++) {
        var _s = _L.stash[i];
        if (point_in_rectangle(_mx, _my, _s.x, _s.y, _s.x + _L.s, _s.y + _L.s)) {
            drag_item = stash_remove_at(i);
            drag_from = "stash";
            drag_key  = "";
            break;
        }
    }
}

if (mouse_check_button_released(mb_left) && !is_undefined(drag_item)) {
    var _done = false;

    for (var i = 0; i < array_length(_L.chars); i++) {
        var _c = _L.chars[i];
        if (!point_in_rectangle(_mx, _my, _c.x, _c.y, _c.x + _L.s, _c.y + _L.s)) continue;

        var _prev = char_item_take(_c.key);
        if (!is_undefined(_prev)) {
            if (drag_from == "char") {
                global.char_item[$ drag_key] = _prev;
            } else {
                stash_add(_prev);
            }
        }
        global.char_item[$ _c.key] = drag_item;
        drag_item = undefined;
        _done = true;
        break;
    }

    if (!_done) {
        for (var i = 0; i < array_length(_L.stash); i++) {
            var _s = _L.stash[i];
            if (!point_in_rectangle(_mx, _my, _s.x, _s.y, _s.x + _L.s, _s.y + _L.s)) continue;
            if (stash_add(drag_item)) {
                drag_item = undefined;
                _done = true;
            }
            break;
        }
    }

    if (!is_undefined(drag_item)) {
        if (drag_from == "char") {
            global.char_item[$ drag_key] = drag_item;
        } else {
            stash_add(drag_item);
        }
        drag_item = undefined;
    }
}