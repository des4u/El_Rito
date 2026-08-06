
function event_set(_name) {
    global.events[$ _name] = true;
}


function event_happened(_name) {
    return variable_struct_exists(global.events, _name)
        && global.events[$ _name];
}


function event_clear(_name) {
    if (variable_struct_exists(global.events, _name)) {
        variable_struct_remove(global.events, _name);
    }
}



//purgar definitivamente xd
function party_purge(_key) {
    party_remove(_key);
    var _rooms = variable_struct_get_names(global.party_stationed);
    for (var i = 0; i < array_length(_rooms); i++) {
        var _r = global.party_stationed[$ _rooms[i]];
        if (variable_struct_exists(_r, _key)) variable_struct_remove(_r, _key);
    }
    var _obj = key_to_obj(_key);
    if (_obj != -1) with (_obj) instance_destroy();
}


function party_setup_for_story() {
    if (global.story_party_set) return;
    global.story_party_set = true;

    global.party = [];
    global.controlled_key = "";

    if (!event_happened("intro_complete")) {
        party_add("sofi");
    }
    else if (!event_happened("sofi_disappeared")) {
        party_add("alberto");
        party_add("santi");
        party_add("diana");
    }
    else if (!event_happened("The_gang")) {
        party_add("carlos");
        party_add("alberto");
        party_add("santi");
        party_add("diana");
    }
    else if (!event_happened("disengage")) {
        party_add("santi");
        party_add("diana");
    }
    else {
        party_add("carlos");
    }
}





function party_add(_key) {
    if (party_has(_key)) return;
    array_push(global.party, _key);


    if (global.controlled_key == "") {
        global.controlled_key = _key;
    }
}

function party_remove(_key) {
    var _new = [];
    for (var i = 0; i < array_length(global.party); i++) {
        if (global.party[i] != _key) {
            array_push(_new, global.party[i]);
        }
    }
    global.party = _new;

    if (global.controlled_key == _key) {
        global.controlled_key = (array_length(global.party) > 0)
            ? global.party[0] : "";
    }

    if (variable_struct_exists(global.party_instances, _key)) {
        var _inst = global.party_instances[$ _key];
        if (instance_exists(_inst)) instance_destroy(_inst);
        variable_struct_remove(global.party_instances, _key);
    }
}

function party_has(_key) {
    for (var i = 0; i < array_length(global.party); i++) {
        if (global.party[i] == _key) return true;
    }
    return false;
}

function party_get_instance(_key) {
    if (variable_struct_exists(global.party_instances, _key)) {
        var _inst = global.party_instances[$ _key];
        if (instance_exists(_inst)) return _inst;
    }
    return noone;
}





function spawn_register(_room_id, _door_id, _sx, _sy) {
    var _k = string(_room_id) + ":" + _door_id;
    global.spawn_points[$ _k] = { x: _sx, y: _sy };
}

function spawn_register_default(_room_id, _sx, _sy) {
    spawn_register(_room_id, "__default__", _sx, _sy);
}


function spawn_get(_room_id, _door_id) {
    var _k = string(_room_id) + ":" + _door_id;
    if (variable_struct_exists(global.spawn_points, _k)) {
        return global.spawn_points[$ _k];
    }
    var _def = string(_room_id) + ":__default__";
    if (variable_struct_exists(global.spawn_points, _def)) {
        return global.spawn_points[$ _def];
    }
    return { x: 64, y: 64 };
}

function spawn_resolve(_door_id) {
    var _m = 40;
    with (obj_door) {
        if (door_id != _door_id) continue;
        var _cx = (bbox_left + bbox_right) * 0.5;
        var _cy = (bbox_top + bbox_bottom) * 0.5;
        switch (exit_dir) {
            case "up":    return { x: _cx, y: bbox_top - _m, dir: "up" };
            case "down":  return { x: _cx, y: bbox_bottom + _m, dir: "down" };
            case "left":  return { x: bbox_left - _m, y: _cy, dir: "left" };
            case "right": return { x: bbox_right + _m, y: _cy, dir: "right" };
        }
        return { x: _cx, y: _cy, dir: "down" };
    }
    var _p = spawn_get(room, _door_id);
    return { x: _p.x, y: _p.y, dir: "down" };
}

function party_spawn() {
    global.party_instances = {};
    global.controlled = noone;

    if (room == game_1_presentation || room == game_1_realhistory || room == game_1_thebus) { //si, se que es un poco... raro, pero pondre todos los rooms de transición o escenas aquí para evitar bugs
        global.party_traveling = [];
        exit;
    }

    var _pos = spawn_resolve(global.prev_door_id);
    var _px  = _pos.x;
    var _py  = _pos.y;
    var _odx = 0, _ody = 0;
    switch (_pos.dir) {
        case "up":    _ody = -20; break;
        case "down":  _ody =  20; break;
        case "left":  _odx = -20; break;
        default:      _odx =  20; break;
    }
    var _rk = string(room);
    var _stationed_here = variable_struct_exists(global.party_stationed, _rk)
        ? global.party_stationed[$ _rk]
        : {};


    var _to_spawn = [];

    for (var i = 0; i < array_length(global.party_traveling); i++) {
        array_push(_to_spawn, { key: global.party_traveling[i], stationed: false });
    }

    var _stationed_keys = variable_struct_get_names(_stationed_here);
    for (var i = 0; i < array_length(_stationed_keys); i++) {
        var _key = _stationed_keys[i];
        var _dup = false;
        for (var j = 0; j < array_length(_to_spawn); j++) {
            if (_to_spawn[j].key == _key) { _dup = true; break; }
        }
        if (!_dup) array_push(_to_spawn, { key: _key, stationed: true });
    }

	if (array_length(_to_spawn) == 0) {
        for (var i = 0; i < array_length(global.party); i++) {
            array_push(_to_spawn, { key: global.party[i], stationed: false });
        }
    }

    var _offset = 0;
    for (var i = 0; i < array_length(_to_spawn); i++) {
        var _entry     = _to_spawn[i];
        var _key       = _entry.key;
        var _stationed = _entry.stationed;
        if (!party_has(_key)) continue;

        var _obj = key_to_obj(_key);
        if (_obj == -1) continue;

        var _sx, _sy;
        if (_stationed) {
            var _data = _stationed_here[$ _key];
            _sx = _data.x;
            _sy = _data.y;
        } else {
            _sx = _px + _odx * _offset;
            _sy = _py + _ody * _offset;
            _offset += 1;
        }

        var _inst = instance_create_layer(_sx, _sy, "characters", _obj);
        _inst.party_index = i;
        _inst.ai_stance   = key_to_stance(_key);


        if (_stationed) {
            _inst.cutscene_locked = true;
        }
        if (!_stationed) cs_face(_inst, _pos.dir);
        global.party_instances[$ _key] = _inst;

        if (_key == global.controlled_key) {
            scr_party_set_active(_inst);
        }
    }

    if (!instance_exists(global.controlled) && array_length(_to_spawn) > 0) {
        var _first = party_get_instance(_to_spawn[0].key);
        if (_first != noone) {
            global.controlled_key = _to_spawn[0].key;
            scr_party_set_active(_first);
        }
    }
}



function npc_spawn(_obj, _px, _py, _stance) {
    var _inst = instance_create_layer(_px, _py, "characters", _obj);
    _inst.ai_stance = _stance;
    return _inst;
}


function door_goto(_target_room, _door_id) {
    global.prev_door_id = _door_id;
    global.from_door = true;
    global.party_traveling = [];

    for (var i = 0; i < array_length(global.party); i++) {
        var _key = global.party[i];
        if (party_is_stationed(_key)) continue;

        if (global.solo_mode && _key != global.controlled_key) {
            party_station_here(_key);
            continue;
        }

        array_push(global.party_traveling, _key);
    }

    transition(_target_room, 3);
}



function scr_switch_character(_direction) {
    if (global.solo_mode) exit;
    if (global.switch_cd > 0) exit;

    var _size = array_length(global.party);
    if (_size <= 1) exit;

    var _cur = 0;
    for (var i = 0; i < _size; i++) {
        if (global.party[i] == global.controlled_key) { _cur = i; break; }
    }

    for (var s = 1; s <= _size; s++) {
        var _next = ((_cur + _direction * s) mod _size + _size) mod _size;
        var _key  = global.party[_next];
        var _inst = party_get_instance(_key);
        if (_inst == noone) continue;
        if (_inst.cutscene_locked) continue;

        global.controlled_key = _key;
        scr_party_set_active(_inst);
        global.switch_cd = 12;
        global.switching  = true;
        exit;
    }
}



function scr_register_spawns() {

    spawn_register_default(rm_test_1, 313, 224);
    spawn_register_default(rm_test_2, 313, 224);
    spawn_register_default(rm_sofi, 388, 193);
    spawn_register_default(rm_sofi_hall, 313, 224);	
    spawn_register_default(rm_sofi_kitchen, 313, 224);
    spawn_register_default(rm_sofi_tv_LEGACY, 313, 224);
    spawn_register_default(rm_sofi_outside_down, 315, 251);
    spawn_register_default(rm_sofi_outside_right, 338, 340);
    spawn_register_default(rm_sofi_outside_up, 541, 220);	
	spawn_register_default(rm_plaza_kiosco, 238, 338);
	
	
}




function key_to_obj(_key) {
    switch (_key) {
        case "sofi":     return obj_Sofi;
        case "alberto":  return obj_Alberto;
        case "santi": return obj_Santiago;
        case "diana":    return obj_Diana;
        case "carlos":   return obj_Carlos;
    }
    return -1;
}

function key_to_stance(_key) {
    switch (_key) {
        case "sofi":     return "brave";
        case "alberto":  return "timid";
        case "santi": return "brave";
        case "diana":    return "curious";
        case "carlos":   return "curious";
    }
    return "curious";
}


function scr_room_setup() {
    switch (room) {
        case rm_test_1:

            light_set_ambient(0.09, 0.09, 0.22);
        break;

        case rm_test_2:
            light_set_ambient(0.05, 0.02, 0.02);
        break;
        case rm_sofi:
			global.room_exterior = false;
			sun_off();
			if global.day = false {
			light_set_ambient(0.02, 0.02, 0.06);
			obj_shader_controller.flicker_intensity = 2.0;
			obj_shader_controller.vhs_target_intensity = 1.2;
			} else {
			light_set_ambient(0.6, 0.4, 0.2);
			obj_shader_controller.flicker_intensity = 0.4;
			obj_shader_controller.vhs_target_intensity = 0.1;				
			}
        break;
        case rm_sofi_hall:
			global.room_exterior = false;
			sun_off();
			if global.day = false {
			light_set_ambient(0.02, 0.02, 0.06);
			obj_shader_controller.flicker_intensity = 2.0;
			obj_shader_controller.vhs_target_intensity = 1.2;
			} else {
			light_set_ambient(0.6, 0.4, 0.2);
			obj_shader_controller.flicker_intensity = 0.4;
			obj_shader_controller.vhs_target_intensity = 0.1;				
			}
			break;
		case rm_sofi_outside_down:
			global.room_exterior = true;
			scr_daylight_apply(true);
			if global.day = true {
			light_set_ambient(0.8, 0.5, 0.3);
			} else if global.day = "transitioning" {
			light_set_ambient(0.001,0.001,0.001, true);	
			}
		break;
		case rm_sofi_outside_right:
			global.room_exterior = true;
			scr_daylight_apply(true);		
			if global.day = true {
			light_set_ambient(0.8, 0.5, 0.3, true);
			}
		break;	
		case rm_sofi_outside_up:
			global.room_exterior = true;
			scr_daylight_apply(true);		
			if global.day = true {
			light_set_ambient(0.8, 0.5, 0.3, true);
			}
		break;	
		case rm_plaza_kiosco:
			global.room_exterior = true;
			scr_daylight_apply(true);		
			if (global.day == "6pm") light_set_ambient(0.45, 0.32, 0.22);
			else                     light_set_ambient(0.50, 0.50, 0.60);
			break;

		case rm_sofi_kitchen:
			global.room_exterior = false;
			sun_off();		
			break;

		case rm_plaza_arcs:
			global.room_exterior = true;
			scr_daylight_apply(true);		
			break;
		case rm_plaza_garden:
			global.room_exterior = true;
			scr_daylight_apply(true);		
			break;

		default:
			light_set_ambient(0.35, 0.35, 0.40);
			break;
		}
}