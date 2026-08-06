if (!surface_exists(surf)) {
    surf = surface_create(display_get_gui_width(), display_get_gui_height());
}

if (trans_active) {
    trans_timer    += delta_time / 1000000;
    trans_progress  = clamp(trans_timer / trans_duration, 0.0, 1.0);

    if (!trans_changed && trans_progress >= ((trans_type == 3) ? 0.999 : 0.88)) {
        trans_changed = true;
        fadein_type   = trans_type;
        if (trans_target != -1) {
            room_goto(trans_target);
        }
    }
	if (trans_type == 4) {
		if (!trans_black_waiting) {
			trans_progress = 1.0;
			if (!trans_changed) {
				trans_changed = true;
				fadein_type   = 4;
				if (trans_target != -1) room_goto(trans_target);
			}
			trans_black_waiting = true;
			trans_black_timer   = 0.0;
		} else {
			// espera en negro
			trans_black_timer += delta_time / 1000000;
			if (trans_black_timer >= trans_black_duration) {
				trans_active        = false;
				trans_progress      = 0.0;
				trans_timer         = 0.0;
				trans_changed       = false;
				trans_target        = -1;
				trans_black_waiting = false;
				trans_black_timer   = 0.0;
				fadein_active       = true;
				fadein_progress     = 0.0;
				fadein_timer        = 0.0;
			}
		}
		exit; // que no lo procese el código normal de abajo
	}
    if (trans_progress >= 1.0) {
        trans_active   = false;
        trans_progress = 0.0;
        trans_timer    = 0.0;
        trans_changed  = false;
        trans_target   = -1;
        fadein_active   = true;
        fadein_progress = 0.0;
        fadein_timer    = 0.0;
    }
}


if (fadein_active) {
    fadein_timer    += delta_time / 1000000;
    fadein_progress  = clamp(fadein_timer / fadein_duration, 0.0, 1.0);

    if (fadein_progress >= 1.0) {
        fadein_active   = false;
        fadein_progress = 0.0;
        fadein_timer    = 0.0;
    }
}

if (effect_active) {
    effect_timer    += delta_time / 1000000;
    effect_progress  = clamp(effect_timer * effect_speed, 0.0, 1.0);
}