function light_add(_x, _y, _radius, _bright, _type, _cr, _cg, _cb) {
    var _light = {
        x           : _x,
        y           : _y,
        radius      : _radius,
        brightness  : _bright,
        type        : _type,
        cr          : _cr,
        cg          : _cg,
        cb          : _cb,
        seed        : random(1000),
        world_space : true   // true = coordenadas del room, false = sigue camara
    };
    with (obj_shader_controller) {
        ds_list_add(light_list, _light);
    }
    return _light;
}

/// light_remove(light_ref)
function light_remove(_light) {
    with (obj_shader_controller) {
        var _idx = ds_list_find_index(light_list, _light);
        if (_idx != -1) ds_list_delete(light_list, _idx);
    }
}

/// light_move(light_ref, x, y)
function light_move(_light, _x, _y) {
    _light.x = _x;
    _light.y = _y;
}

/// light_set_ambient(r, g, b)  -- valores 0.0 a 1.0
function light_set_ambient(_r, _g, _b, _instant = false) {
    with (obj_shader_controller) {
        target_ambient_r = _r;
        target_ambient_g = _g;
        target_ambient_b = _b;
        if (_instant) {
            ambient_r = _r;
            ambient_g = _g;
            ambient_b = _b;
        }
    }
}


function light_on(_item, _x, _y) {
    if (is_undefined(_item)) return false;
    if (_item.durability <= 0) return false;
    _item.lit = true;
    if (_item.light_ref == -1) {
        _item.light_ref = light_add(_x, _y, _item.radius, _item.strength,
                                    _item.type, _item.cr, _item.cg, _item.cb);
    }
    return true;
}
function light_off(_item) {
    if (is_undefined(_item)) return;
    _item.lit = false;
    if (_item.light_ref != -1) {
        light_remove(_item.light_ref);
        _item.light_ref = -1;
    }
}

function scr_get_darkness() {
    with (obj_shader_controller) {
        // Promedio del ambient RGB — 0.0 = negro total, 1.0 = día
        return (ambient_r + ambient_g + ambient_b) / 3;
    }
    return 1.0;
}