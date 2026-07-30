function transition(_room, _type) {
    with (obj_transition_controller) {
        if (trans_active) exit;
        trans_active   = true;
        trans_type     = _type;
        trans_target   = _room;
        trans_progress = 0.0;
        trans_timer    = 0.0;
        trans_changed  = false;
    }
}

function transition_finish() {
    with (obj_transition_controller) {
        trans_active    = false;
        trans_progress  = 0.0;
        trans_timer     = 0.0;
        trans_changed   = false;
        trans_target    = -1;
        fadein_type     = trans_type;
        fadein_active   = true;
        fadein_progress = 0.0;
        fadein_timer    = 0.0;
    }
}

function vhs_fx_play(_type) {
    with (obj_fx_controller) {
        fx_type   = _type;
        fx_active = true;
    }
}

function vhs_fx_stop() {
    with (obj_fx_controller) {
        fx_active = false;
    }
}

function transition_blocks_input() {
    if (!instance_exists(obj_transition_controller)) return false;
    return (obj_transition_controller.trans_active || obj_transition_controller.fadein_active);
}