
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


function party_spawn() {
    global.party_instances = {};
    global.controlled = noone;

    var _pos = spawn_get(room, global.prev_door_id);
    var _px  = _pos.x;
    var _py  = _pos.y;

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
            _sx = _px + _offset;
            _sy = _py;
            _offset += 20;
        }

        var _inst = instance_create_layer(_sx, _sy, "characters", _obj);
        _inst.party_index = i;
        _inst.ai_stance   = key_to_stance(_key);


        if (_stationed) {
            _inst.cutscene_locked = true;
        }

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
    global.party_traveling = [];


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
    spawn_register(rm_test_1, "door_test2_down", 132, 169);
    spawn_register(rm_test_1, "door_test2_up",   379, 322);

    spawn_register_default(rm_test_2, 313, 224);
    spawn_register(rm_test_2, "door_test1_down", 132, 169);
    spawn_register(rm_test_2, "door_test1_up",   379, 322);
	
    spawn_register_default(rm_sofi, 388, 193);
    spawn_register(rm_sofi, "door_hall-sofi", 314, 192);

    spawn_register_default(rm_sofi_hall, 313, 224);
    spawn_register(rm_sofi_hall, "door_sofi-hall", 192, 188);
    spawn_register(rm_sofi_hall, "door_kitchen-hall", 400, 212);	
	
    spawn_register_default(rm_sofi_kitchen, 313, 224);
    spawn_register(rm_sofi_kitchen, "door_hall-kitchen", 277, 196);
    spawn_register(rm_sofi_kitchen, "door_tv-kitchen", 455, 355);	
	spawn_register(rm_sofi_kitchen, "out-inside", 277, 196);
	
    spawn_register_default(rm_sofi_tv_LEGACY, 313, 224);
    spawn_register(rm_sofi_tv_LEGACY, "door_kitchen-tv", 450, 140);

    spawn_register_default(rm_sofi_outside_down, 315, 251);
    spawn_register(rm_sofi_outside_down, "out_right-down", 444,221);
    spawn_register(rm_sofi_outside_down, "out_town-down", 331, 316);
	spawn_register(rm_sofi_outside_down, "insides-out", 314, 156);
	
	
    spawn_register_default(rm_sofi_outside_right, 338, 340);
    spawn_register(rm_sofi_outside_right, "out_down-right", 316, 320);
    spawn_register(rm_sofi_outside_right, "out_up-right", 321, 73);

    spawn_register_default(rm_sofi_outside_up, 541, 220);
    spawn_register(rm_sofi_outside_up, "out_right-up", 507, 220);
	
	spawn_register_default(rm_plaza_kiosco, 238, 338);
	spawn_register(rm_plaza_kiosco,"right-kiosco",522,356);
	
	
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
			light_set_ambient(0.01, 0.01, 0.05);
			break;
		case rm_sofi_outside_down:
			if global.day = true {
			light_set_ambient(0.8, 0.5, 0.3);
			} else if global.day = "transitioning" {
			light_set_ambient(0,0,0, true);	
			}
		break;
		case rm_sofi_outside_right:
			if global.day = true {
			light_set_ambient(0.8, 0.5, 0.3, true);
			}
		break;	
		case rm_sofi_outside_up:
			if global.day = true {
			light_set_ambient(0.8, 0.5, 0.3, true);
			}
		break;	
		case rm_plaza_kiosco:
			if global.day = "6pm" {
			light_set_ambient(0.45, 0.32, 0.22);
			}
			break;
		}
}