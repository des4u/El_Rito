#macro STASH_MAX 3
function item_make(_type) {
    var _it = {
        type       : _type,
        name       : "Objeto",
        icon       : -1,
        durability : 1.0,
        drain_rate : 0.0002,
        radius     : 80,
        strength   : 0.9,
        cr : 1, cg : 1, cb : 1,
        lit        : false,
        light_ref  : -1
    };
    switch (_type) {
        case "candle":
            _it.name = "Cirio";
            _it.icon = spr_Candle;
            _it.drain_rate = 0.0003;
            _it.radius = 80;  _it.strength = 0.9;
            _it.cr = 0.90; _it.cg = 0.75; _it.cb = 0.40;
        break;
        case "lantern":
            _it.name = "Lampara";
            _it.icon = spr_Lantern;
            _it.drain_rate = 0.0001;
            _it.radius = 120; _it.strength = 1.0;
            _it.cr = 0.75; _it.cg = 0.85; _it.cb = 1.00;
        break;
        case "flashlight":
            _it.name = "Linterna";
            _it.icon = spr_Flashlight;
            _it.drain_rate = 0.00008;
            _it.radius = 160; _it.strength = 1.0;
            _it.cr = 0.85; _it.cg = 0.90; _it.cb = 1.00;
        break;
    }
    return _it;
}
function stash_add(_item) {
    if (is_undefined(_item)) return false;
    if (array_length(global.stash) >= STASH_MAX) return false;
    array_push(global.stash, _item);
    return true;
}
function stash_add_type(_type) {
    return stash_add(item_make(_type));
}
function stash_remove_at(_i) {
    if (_i < 0 || _i >= array_length(global.stash)) return undefined;
    var _it = global.stash[_i];
    array_delete(global.stash, _i, 1);
    return _it;
}
function stash_is_full() {
    return array_length(global.stash) >= STASH_MAX;
}
function char_item_get(_key) {
    if (!variable_struct_exists(global.char_item, _key)) return undefined;
    return global.char_item[$ _key];
}
function char_item_take(_key) {
    var _it = char_item_get(_key);
    if (!is_undefined(_it)) light_off(_it);
    global.char_item[$ _key] = undefined;
    return _it;
}
function char_light_toggle(_key) {
    var _it = char_item_get(_key);
    if (is_undefined(_it)) return false;
    if (_it.lit) { light_off(_it); return false; }
    if (_it.durability <= 0) return false;
    _it.lit = true;
    return true;
}
function key_to_display(_key) {
    switch (_key) {
        case "sofi":    return "Sofi";
        case "alberto": return "Alberto";
        case "santi":   return "Santiago";
        case "diana":   return "Diana";
        case "carlos":  return "Carlos";
    }
    return _key;
}
function inv_layout() {
    var _gw = display_get_gui_width();
    var _gh = display_get_gui_height();
    var _pw = 760;
    var _ph = 460;
    var _px = floor((_gw - _pw) * 0.5);
    var _py = floor((_gh - _ph) * 0.5);
    var _s   = 72;
    var _gap = 16;
    var _chars = [];
    var _n  = array_length(global.party);
    var _rw = _n * _s + max(0, _n - 1) * _gap;
    var _cx = _px + floor((_pw - _rw) * 0.5);
    for (var i = 0; i < _n; i++) {
        array_push(_chars, {
			key : global.party[i],
			x   : _cx + i * (_s + _gap),
			y   : _py + 80
		});
    }
    var _stash = [];
    var _sw = STASH_MAX * _s + (STASH_MAX - 1) * _gap;
    var _sx = _px + floor((_pw - _sw) * 0.5);
    for (var i = 0; i < STASH_MAX; i++) {
        array_push(_stash, { x : _sx + i * (_s + _gap), y : _py + 248 });
    }
    return {
        px : _px, py : _py, pw : _pw, ph : _ph, s : _s,
        chars : _chars,
        stash : _stash
    };
}
function inv_draw_slot(_x, _y, _s, _item, _hover) {
    draw_set_color(make_color_rgb(20, 19, 24));
    draw_set_alpha(0.92);
    draw_rectangle(_x, _y, _x + _s, _y + _s, false);
    draw_set_color(_hover ? make_color_rgb(212, 200, 162) : make_color_rgb(120, 120, 132));
    draw_set_alpha(_hover ? 0.9 : 0.4);
    draw_rectangle(_x, _y, _x + _s, _y + _s, true);
    draw_set_alpha(1);
    if (is_undefined(_item)) return;
    draw_set_color(c_white);
    if (_item.icon != -1) {
        draw_sprite_stretched(_item.icon, 0, _x + 7, _y + 7, _s - 14, _s - 14);
    }
    var _by = _y + _s - 6;
    draw_set_color(make_color_rgb(45, 43, 50));
    draw_rectangle(_x + 5, _by, _x + _s - 5, _by + 3, false);
    draw_set_color(_item.lit ? make_color_rgb(235, 205, 115) : make_color_rgb(110, 120, 140));
    draw_rectangle(_x + 5, _by, _x + 5 + (_s - 10) * _item.durability, _by + 3, false);
    draw_set_color(c_white);
    draw_set_alpha(1);
}
