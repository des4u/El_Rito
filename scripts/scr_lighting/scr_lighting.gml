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


function scr_light_equip(char, item) {
    if (instance_exists(char.light_item)) {
        scr_light_unequip(char);
    }

    char.light_item  = item;
    char.has_light   = true;
    item.owner       = char;
    item.is_equipped = true;

    // Linterna: luz sale desde el punto de aim
    var _lx = (item.light_type == "flashlight") ? item.aim_x : char.x;
    var _ly = (item.light_type == "flashlight") ? item.aim_y : char.y;

    item.my_light_id = light_add(
        _lx, _ly,
        item.light_radius,
        item.light_strength,
        item.light_type,
        item.light_r, item.light_g, item.light_b
    );
}



function scr_light_unequip(char) {
    var _item = char.light_item;
    if (!instance_exists(_item)) exit;

    _item.is_equipped = false;
    if (_item.my_light_id != -1) {
        light_remove(_item.my_light_id);
        _item.my_light_id = -1;
    }

    char.light_item = noone;
    char.has_light  = false;
}

function scr_light_extinguish(item) {
    if (item.my_light_id != -1) {
        light_remove(item.my_light_id);
        item.my_light_id = -1;
    }
    item.is_equipped  = false;
    item.is_flickering = false;

    if (instance_exists(item.owner)) {
        item.owner.light_item = noone;
        item.owner.has_light  = false;
    }
}

function scr_get_darkness() {
    with (obj_shader_controller) {
        // Promedio del ambient RGB — 0.0 = negro total, 1.0 = día
        return (ambient_r + ambient_g + ambient_b) / 3;
    }
    return 1.0;
}