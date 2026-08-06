function sun_set(_dir, _len, _alpha) {
    global.sun.active = true;
    global.sun.dir    = _dir;
    global.sun.len    = _len;
    global.sun.alpha  = _alpha;
}

function sun_off() {
    global.sun.active = false;
}

function scr_shadow_cast(_dir, _len, _alpha) {
    scr_shadow_cast_ext(sprite_index, image_index, x, y, image_xscale, image_yscale, _dir, _len, _alpha);
}

function scr_shadow_draw() {
    scr_shadow_dispatch_ext(sprite_index, image_index, x, y, image_xscale, image_yscale);
}

function scr_shadow_cast_ext(_spr, _img, _x, _y, _xsc, _ysc, _dir, _len, _alpha) {
    if (_spr == -1) return;
    var _xs    = abs(_xsc);
    var _ys    = abs(_ysc);
    var _w     = sprite_get_width(_spr) * _xs;
    var _h     = sprite_get_height(_spr) * _ys;
    var _left  = _x - sprite_get_xoffset(_spr) * _xs;
    var _right = _left + _w;
	var _foot  = _y - sprite_get_yoffset(_spr) * _ys + (sprite_get_bbox_bottom(_spr) + 1) * _ys;
    var _px    = lengthdir_x(_h * _len, _dir);
    var _py    = lengthdir_y(_h * _len, _dir) * 0.45;
    var _x1 = _left + _px;
    var _x2 = _right + _px;
    var _x3 = _right;
    var _x4 = _left;
    if (_xsc < 0) {
        _x1 = _right + _px;
        _x2 = _left + _px;
        _x3 = _left;
        _x4 = _right;
    }
    gpu_set_fog(true, c_black, 0, 1);
    draw_sprite_pos(_spr, _img, _x1, _foot + _py, _x2, _foot + _py, _x3, _foot, _x4, _foot, _alpha);
    gpu_set_fog(false, c_black, 0, 1);
}

function scr_shadow_dispatch_ext(_spr, _img, _x, _y, _xsc, _ysc) {
    if (global.sun.active) {
        scr_shadow_cast_ext(_spr, _img, _x, _y, _xsc, _ysc, global.sun.dir, global.sun.len, global.sun.alpha);
        return;
    }
    if (!instance_exists(obj_shader_controller)) return;
    var _list  = obj_shader_controller.light_list;
    var _n     = ds_list_size(_list);
    var _drawn = 0;
    for (var _i = 0; _i < _n; _i++) {
        var _l = _list[| _i];
        if (_l.type == "body") continue;
        var _range = _l.radius * 1.6;
        var _dist  = point_distance(_x, _y, _l.x, _l.y);
        if (_dist > _range || _dist < 4) continue;
        var _fade = 1 - (_dist / _range);
        scr_shadow_cast_ext(_spr, _img, _x, _y, _xsc, _ysc, point_direction(_l.x, _l.y, _x, _y), 0.35 + 0.6 * _fade, 0.3 * _fade * min(_l.brightness, 1));
        _drawn++;
        if (_drawn >= 3) break;
    }
}

function asset_shadows_scan() {
    var _out    = [];
    var _layers = layer_get_all();
    for (var _i = 0; _i < array_length(_layers); _i++) {
        var _lyr  = _layers[_i];
        var _name = layer_get_name(_lyr);
        if (string_copy(_name, 1, 3) == "ns_") continue;
        var _els = layer_get_all_elements(_lyr);
        for (var _j = 0; _j < array_length(_els); _j++) {
            var _el = _els[_j];
            if (layer_get_element_type(_el) != layerelementtype_sprite) continue;
            var _spr = layer_sprite_get_sprite(_el);
            if (_spr == -1) continue;
			static _skip = ["ventana", "window"];
			var _sname = string_lower(sprite_get_name(_spr));
			var _omitir = false;
			for (var _k = 0; _k < array_length(_skip); _k++) {
			if (string_pos(_skip[_k], _sname) > 0) {
				_omitir = true;
				break;
			}
		}
if (_omitir) continue;			
            array_push(_out, {
                spr : _spr,
                img : layer_sprite_get_index(_el),
                x   : layer_sprite_get_x(_el),
                y   : layer_sprite_get_y(_el),
                xs  : layer_sprite_get_xscale(_el),
                ys  : layer_sprite_get_yscale(_el)
            });
        }
    }
    return _out;
}

function hora_set(_h) {
    global.hora = clamp(_h, 0, 24) mod 24;
    if (global.room_exterior) scr_daylight_apply();
}

function scr_daylight_apply(_instant = false) {
    var _h = global.hora;
    static _keys = [
        [0,  0.05, 0.06, 0.12],
        [5,  0.05, 0.06, 0.12],
        [7,  0.55, 0.35, 0.30],
        [9,  0.95, 0.92, 0.85],
        [17, 0.90, 0.88, 0.80],
        [19, 0.65, 0.38, 0.30],
        [21, 0.07, 0.08, 0.15],
        [24, 0.05, 0.06, 0.12]
    ];
    var _r = 0.05, _g = 0.06, _b = 0.12;
    for (var _i = 0; _i < array_length(_keys) - 1; _i++) {
        var _a = _keys[_i];
        var _c = _keys[_i + 1];
        if (_h >= _a[0] && _h <= _c[0]) {
            var _t = (_h - _a[0]) / (_c[0] - _a[0]);
            _r = lerp(_a[1], _c[1], _t);
            _g = lerp(_a[2], _c[2], _t);
            _b = lerp(_a[3], _c[3], _t);
            break;
        }
    }
    light_set_ambient(_r, _g, _b, _instant);
    if (_h >= 7 && _h <= 19) {
        var _mediodia = abs(_h - 13) / 6;
        var _dir = 180 + ((_h - 7) / 12) * 180;
        sun_set(_dir, 0.25 + 0.75 * _mediodia, 0.20 + 0.15 * (1 - _mediodia));
    } else {
        sun_off();
    }
}