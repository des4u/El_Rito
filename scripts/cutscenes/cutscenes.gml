function scr_cutscene_stage() {
    switch (room) {

        case rm_sofi_outside_down:
            if (global.sofievent == 9.5) {
                scr_cutscene_lock(-1);
                var _s = party_get_instance("santi");
                if (_s != noone) { _s.x = 320; _s.y = 110; cs_face(_s, "up"); }
                var _d = party_get_instance("diana");
                if (_d != noone) { _d.x = 268; _d.y = 148; cs_face(_d, "right"); }
                var _a = party_get_instance("alberto");
                if (_a != noone) { _a.x = 372; _a.y = 152; cs_face(_a, "left"); }
            }
        break;
		case rm_plaza_kiosco:
            if (global.kioscoevent == 5.5) {
                party_ensure_controlled();
                scr_cutscene_lock(-1);
                var _d = party_get_instance("diana");
                if (_d != noone) { _d.x = 238; _d.y = 338; cs_face(_d, "down"); }
                scr_cam_snap();
            }
        break;
    }
}
function party_set(_keys) {
    global.party = [];
    global.controlled_key = "";
    for (var i = 0; i < array_length(_keys); i++) {
        party_add(_keys[i]);
    }
}

function party_boot() {
    if (variable_global_exists("party_booted") && global.party_booted) return;
    global.party_booted = true;
    party_set(["sofi"]);
}
function scr_cam_snap() {
    global.cam_locked = false;
    if (!instance_exists(global.controlled)) return;
    var _cam = view_camera[0];
    var _w = camera_get_view_width(_cam);
    var _h = camera_get_view_height(_cam);
    camera_set_view_pos(_cam, global.controlled.x - _w * 0.5, global.controlled.y - _h * 0.5);
}


function scr_cutscene_lock(target) {
    if (target == -1) {
        with (par_Character) { cutscene_locked = true; }
    } else {
        if (!instance_exists(target)) return;
        target.cutscene_locked = true;
    }
}

function scr_cutscene_unlock(target) {
    if (target == -1) {
        with (par_Character) {
            cutscene_locked = false;
            cs_target = undefined;
        }
    } else {
        if (!instance_exists(target)) return;
        target.cutscene_locked = false;
        target.cs_target = undefined;
    }
}

function scr_cutscene_walk(target, dest_x, dest_y, spd, y_first = false) {
    var _char = target.char_name;
    var _dx = dest_x - target.x;
    var _dy = dest_y - target.y;

    var _mx = 0;
    var _my = 0;
    var _arrived = false;

    if (y_first) {
        if (abs(_dy) > spd)      { _my = sign(_dy) * spd; target.y += _my; }
        else if (abs(_dx) > spd) { _mx = sign(_dx) * spd; target.x += _mx; }
        else _arrived = true;
    } else {
        if (abs(_dx) > spd)      { _mx = sign(_dx) * spd; target.x += _mx; }
        else if (abs(_dy) > spd) { _my = sign(_dy) * spd; target.y += _my; }
        else _arrived = true;
    }

    if (_arrived) {
        target.x = dest_x;
        target.y = dest_y;
        var _idle = (target.last_dir == "up")
            ? asset_get_index("spr_" + _char + "_up_idle")
            : asset_get_index("spr_" + _char + "_idle");
        if (_idle == -1) _idle = asset_get_index("spr_sofi_idle");
        target.sprite_index = _idle;
        return true;
    }

    var _suf;
    if (_mx != 0) {
        target.image_xscale = sign(_mx);
        target.last_dir = "side";
        _suf = "_side_w";
    } else if (_my < 0) {
        target.last_dir = "up";
        _suf = "_up_w";
    } else {
        target.last_dir = "down";
        _suf = "_down_w";
    }

    var _spr = asset_get_index("spr_" + _char + _suf);
    if (_spr == -1) _spr = asset_get_index("spr_sofi" + _suf);
    target.sprite_index = _spr;
    return false;
}
function delay(_seconds, _id = 0) {
    static _timers = {};
    
    var _key = string(_id);
    
    if (!struct_exists(_timers, _key)) {
        _timers[$ _key] = _seconds * game_get_speed(gamespeed_fps);
    }
    
    _timers[$ _key]--;
    
    if (_timers[$ _key] <= 0) {
        struct_remove(_timers, _key);
        return true;
    }
    
    return false;
}

function scr_cam_free() {
    var _cam = view_camera[0];
    global.cam_locked   = true;
    global.cam_target_x = camera_get_view_x(_cam) + camera_get_view_width(_cam)  / 2;
    global.cam_target_y = camera_get_view_y(_cam) + camera_get_view_height(_cam) / 2;
}

function scr_cam_move(tx, ty) {
    global.cam_locked   = true;
    global.cam_target_x = tx;
    global.cam_target_y = ty;

    var _cam  = view_camera[0];
    var _cur_x = camera_get_view_x(_cam) + camera_get_view_width(_cam)  / 2;
    var _cur_y = camera_get_view_y(_cam) + camera_get_view_height(_cam) / 2;

    return (abs(_cur_x - tx) < 2 && abs(_cur_y - ty) < 2);
}

function scr_cam_follow() {
    global.cam_locked = false;
}

function scr_ramp(start_val, end_val, duration_seconds) {
    static _timer    = -1;
    static _start    = 0;
    static _end      = 0;
    static _duration = 0;

    if (_timer == -1) {
        _timer    = 0;
        _start    = start_val;
        _end      = end_val;
        _duration = duration_seconds * game_get_speed(gamespeed_fps);
    }

    _timer++;

    var _t = clamp(_timer / _duration, 0, 1);
    var _val = lerp(_start, _end, _t);

    if (_timer >= _duration) _timer = -1;

    return _val;
}

function cs_walk(_inst, _dx, _dy, _spd = 1.2, _y_first = false) {
    if (!instance_exists(_inst)) return;
    _inst.cutscene_locked = true;
    _inst.cs_target = { x: _dx, y: _dy, spd: _spd, yf: _y_first, done: false };
}

function cs_walk_update() {
    with (par_Character) {
        if (!variable_instance_exists(id, "cs_target")) continue;
        if (!is_struct(cs_target)) continue;
        if (cs_target.done) continue;
        if (scr_cutscene_walk(id, cs_target.x, cs_target.y, cs_target.spd, cs_target.yf)) {
            cs_target.done = true;
        }
    }
}

function cs_walk_done(_inst) {
    if (!instance_exists(_inst)) return true;
    if (!variable_instance_exists(_inst, "cs_target")) return true;
    if (!is_struct(_inst.cs_target)) return true;
    return _inst.cs_target.done;
}

function cs_face(_inst, _dir) {
    if (!instance_exists(_inst)) return;
    var _char = _inst.char_name;
    var _spr = (_dir == "up")
        ? asset_get_index("spr_" + _char + "_up_idle")
        : asset_get_index("spr_" + _char + "_idle");
    if (_spr == -1) _spr = asset_get_index("spr_sofi_idle");
    _inst.sprite_index = _spr;
    if (_dir == "left")  _inst.image_xscale = -1;
    if (_dir == "right") _inst.image_xscale =  1;
    _inst.last_dir = (_dir == "up") ? "up" : "side";
}

function party_add_instance(_key, _px, _py) {
    party_add(_key);
    var _inst = party_get_instance(_key);
    if (_inst != noone) return _inst;
    var _obj = key_to_obj(_key);
    if (_obj == -1) return noone;
    _inst = instance_create_layer(_px, _py, "characters", _obj);
    _inst.ai_stance = key_to_stance(_key);
    _inst.cutscene_locked = true;
    global.party_instances[$ _key] = _inst;
    return _inst;
}

function party_is_stationed(_key) {
    var _rooms = variable_struct_get_names(global.party_stationed);
    for (var i = 0; i < array_length(_rooms); i++) {
        if (variable_struct_exists(global.party_stationed[$ _rooms[i]], _key)) return true;
    }
    return false;
}

function party_station_here(_key) {
    var _inst = party_get_instance(_key);
    if (!instance_exists(_inst)) return;
    var _rk = string(room);
    if (!variable_struct_exists(global.party_stationed, _rk)) {
        global.party_stationed[$ _rk] = {};
    }
    global.party_stationed[$ _rk][$ _key] = { x: _inst.x, y: _inst.y, locked: true };
}

function party_unstation_room() {
    var _rk = string(room);
    if (variable_struct_exists(global.party_stationed, _rk)) {
        variable_struct_remove(global.party_stationed, _rk);
    }
}

function party_solo(_key) {
    global.controlled_key = _key;
    global.solo_mode = true;

    for (var i = 0; i < array_length(global.party); i++) {
        var _k = global.party[i];
        if (_k == _key) continue;
        party_station_here(_k);
        var _o = party_get_instance(_k);
        if (instance_exists(_o)) {
            _o.cutscene_locked = true;
            _o.cs_target = undefined;
        }
    }

    var _inst = party_get_instance(_key);
    if (_inst != noone) {
        _inst.cutscene_locked = false;
        _inst.cs_target = undefined;
        scr_party_set_active(_inst);
    }
}

function party_solo_end() {
    global.solo_mode = false;
    party_unstation_room();
}


function party_ensure_controlled() {
    if (instance_exists(global.controlled)) return;
    for (var i = 0; i < array_length(global.party); i++) {
        var _inst = party_get_instance(global.party[i]);
        if (_inst != noone) {
            global.controlled_key = global.party[i];
            scr_party_set_active(_inst);
            return;
        }
    }
    global.controlled = noone;
}