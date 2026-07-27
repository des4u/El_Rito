if (!sprite_initialized) {
    var _char_spr = char_name;
    if (asset_get_index("spr_" + _char_spr + "_idle") == -1) _char_spr = "sofi";
    
    var _idle = asset_get_index("spr_" + _char_spr + "_idle");
    if (_idle != -1) {
        sprite_index = _idle;
    }
    sprite_initialized = true;
}

if (id == global.controlled && !global.switching && !cutscene_locked && !global.inv_open) {
	
    input_x = (keyboard_check(ord("D")) - keyboard_check(ord("A")));
    input_y = (keyboard_check(ord("S")) - keyboard_check(ord("W")));
    if (input_x != 0 && input_y != 0) input_y = 0;

    var _door_hit = noone;

    if (!no_collision) {
        var _block_x = false;
        if (place_meeting(x + input_x * move_speed, y, obj_Collision)) _block_x = true;
        var _dr = instance_place(x + input_x * move_speed, y, obj_doorParent);
        if (_dr != noone) { _block_x = true; _door_hit = _dr; }
        var _ev = instance_place(x + input_x * move_speed, y, obj_Collision_event);
        if (_ev != noone && _ev.active) _block_x = true;
        if (_block_x) {
            while (!place_meeting(x + sign(input_x), y, obj_Collision) &&
                   !place_meeting(x + sign(input_x), y, obj_doorParent) &&
                   (instance_place(x + sign(input_x), y, obj_Collision_event) == noone ||
                    instance_place(x + sign(input_x), y, obj_Collision_event).active == false)) {
                x += sign(input_x);
            }
            input_x = 0;
        }
    }
    x += input_x * move_speed;

    if (!no_collision) {
        var _block_y = false;
        if (place_meeting(x, y + input_y * move_speed, obj_Collision)) _block_y = true;
        var _dr2 = instance_place(x, y + input_y * move_speed, obj_doorParent);
        if (_dr2 != noone) { _block_y = true; _door_hit = _dr2; }
        var _ev = instance_place(x, y + input_y * move_speed, obj_Collision_event);
        if (_ev != noone && _ev.active) _block_y = true;
        if (_block_y) {
            while (!place_meeting(x, y + sign(input_y), obj_Collision) &&
                   !place_meeting(x, y + sign(input_y), obj_doorParent) &&
                   (instance_place(x, y + sign(input_y), obj_Collision_event) == noone ||
                    instance_place(x, y + sign(input_y), obj_Collision_event).active == false)) {
                y += sign(input_y);
            }
            input_y = 0;
        }
    }
    y += input_y * move_speed;

    if (_door_hit != noone && !global.switching) {
        with (_door_hit) event_perform(ev_collision, par_Character);
    }
}

if (!cutscene_locked) {
    var _dx = x - xprevious;
    var _dy = y - yprevious;
    var _moving = (_dx != 0 || _dy != 0);

    var _char = char_name;
    var _spr_idx = -1;

    if (_moving) {
        if (_dx != 0) image_xscale = sign(_dx);

        if (abs(_dy) >= abs(_dx)) {
            if (_dy < 0) {
                _spr_idx = asset_get_index("spr_" + _char + "_up_w");
                if (_spr_idx == -1) _spr_idx = asset_get_index("spr_sofi_up_w");
                last_dir = "up";
            } else {
                _spr_idx = asset_get_index("spr_" + _char + "_down_w");
                if (_spr_idx == -1) _spr_idx = asset_get_index("spr_sofi_down_w");
                last_dir = "down";
            }
        } else {
            _spr_idx = asset_get_index("spr_" + _char + "_side_w");
            if (_spr_idx == -1) _spr_idx = asset_get_index("spr_sofi_side_w");
            last_dir = "side";
        }
    } else {
        if (last_dir == "up") {
            _spr_idx = asset_get_index("spr_" + _char + "_up_idle");
            if (_spr_idx == -1) _spr_idx = asset_get_index("spr_sofi_up_idle");
        } else {
            _spr_idx = asset_get_index("spr_" + _char + "_idle");
            if (_spr_idx == -1) _spr_idx = asset_get_index("spr_sofi_idle");
        }
    }
    
    if (_spr_idx != -1) {
        sprite_index = _spr_idx;
    }
}

if (id == global.controlled && !global.inv_open && !cutscene_locked && !dialog_blocks_input()
    && keyboard_check_pressed(ord("F"))) {
    char_light_toggle(char_name);
}

if (id != global.controlled && !global.switching && !cutscene_locked && !global.inv_open) {
    scr_ai_update(id);
}

light_move(visibility_light_id, x, y);

depth = -bbox_bottom;