cs_walk_update();

switch (global.sofievent) {
	case 0:
		light_set_ambient(0.04, 0.04, 0.12, true);
		obj_shader_controller.flicker_intensity = 2.0;
		obj_shader_controller.vhs_target_intensity = 1.2;
		dialog_start([
			dialog_line_timed("No veo nada", "", -1, 0, 2.0)
		]);
		global.sofievent = -1;
		break;

	case 1:
		tiempo += delta_time / 1000000;
		light_set_ambient(0.6, 0.5, 0.3, true);
		if (tiempo >= 5) {
			audio_sound_gain(snd_vhs, 1, 0);
			light_set_ambient(0.02, 0.02, 0.06, true);
			if (tiempo >= 7) global.sofievent = 2;
		}
		else if (tiempo >= 4) {
			audio_play_sound(snd_broken, -1, 0);
			audio_sound_gain(snd_vhs, 10, 0);
			obj_shader_controller.vhs_intensity = 20;
		}
		break;

	case 2:
		dialog_start([
			dialog_line_timed("Ah... otra vez", "", -1, 0, 2.0)
		]);
		global.sofievent = 3;
		break;

	case 3:
		break;

	case 4:
		if (delay(1.0, 900)) global.sofievent = 5;
		break;

	case 5:
		scr_cam_free();
		scr_cutscene_lock(-1);
		obj_Sofi.no_collision = true;
		obj_shader_controller.vhs_intensity = scr_ramp(10.0, 32.0, 6.0);
		if (obj_shader_controller.vhs_intensity >= 31.99) global.sofievent = 6;
		break;

	case 6:
		if (instance_exists(obj_haunted_window)) {
			obj_shader_controller.vhs_intensity = 0.7;
			instance_destroy(obj_haunted_window);
			audio_sound_gain(snd_vhs, 1);
			if (instance_exists(obj_door)) instance_destroy(obj_door);
			dialog_start([
				dialog_line_timed("...", "", -1, 0, 2.0)
			]);
			global.sofievent = 6.5;
		}
		break;

	case 6.5:
		if (delay(3.0, 901)) {
			cs_walk(obj_Sofi, 329, 209, 4.5);
			global.sofievent = 7;
		}
		break;

	case 7:
		if (cs_walk_done(obj_Sofi)) {
			obj_Sofi.player_vision_enabled = true;
			cs_walk(obj_Sofi, -57, 209, 4.5);
			global.sofievent = 8;
		}
		break;

	case 8:
		if (cs_walk_done(obj_Sofi)) global.sofievent = 9;
		break;

	case 9:
		event_set("intro_complete");
		audio_play_sound(snd_knock, 1, 0);
		global.day = "transitioning";
		party_purge("sofi");
		party_set(["alberto", "santi", "diana"]);
		door_goto(rm_sofi_outside_down, "-1");
		global.sofievent = 9.5;
		break;

	case 9.5:
		if (room == rm_sofi_outside_down && delay(1.2, 902)) global.sofievent = 10;
		break;

	case 10:
		scr_cam_follow();
		dialog_start([
			dialog_line_timed("Chingao' creo que la pinche Sofi se quedo dormida", "??", -1, 0, 4.0),
			dialog_line_timed("Tocale mas fuerte Santiago, a ver si se despierta.", "??", -1, 0, 1.0)
		]);
		global.sofievent = 10.5;
		break;

	case 10.5:
		if (dialog_is_done()) global.sofievent = 11;
		break;

	case 11:
		if (delay(1.0, 903)) {
			audio_play_sound(snd_knock, 1, 0);
			audio_sound_gain(snd_knock, 5, 0);
			global.day = true;
			light_set_ambient(0.8, 0.5, 0.3);
			global.sofievent = 11.5;
		}
		break;

	case 11.5:
		if (delay(2.0, 904)) global.sofievent = 12;
		break;

	case 12:
		dialog_start([
			dialog_line("Claro Santiago, tumbale la puerta, porque no.", "??", -1, 0),
			dialog_line("Pues que se apure, se nos va a hacer tarde", "Santiago", -1, 0),
			dialog_line_timed("...", "???", -1, 0, 1.0),
			dialog_line("¿Alberto podrias entrar a buscar a Sofia?", "Santiago", -1, 0),
			dialog_line("ah no mames", "Alberto", -1, 0),
			dialog_line("¿por que yo?", "Alberto", -1, 0),
			dialog_line("Wey, eres negro", "Santiago", -1, 0),
			dialog_line("Metete por la ventana como si fueras a robar la casa", "Santiago", -1, 0),
			dialog_line_timed(" Hijo de...", "Alberto", -1, 0, 1.0),
			dialog_line_timed("mhm", "Alberto", -1, 0, 2.0),
			dialog_line_timed("Bueno pero, Diana dile a tu novio que le baje no?", "Alberto", -1, 0, 2.0),
			double_dialogue_timed("QUE NO ES MI NOVIO", "Diana", -1, 0, "Que ya se esta pasando", "Alberto", -1, 0, 5.0)
		]);
		global.sofievent = 12.5;
		break;

	case 12.5:
		if (dialog_is_done()) global.sofievent = 13;
		break;

	case 13:
		party_solo("alberto");
		scr_cam_follow();
		tooltip("Busca una entrada a la casa", 3);
		global.sofievent = 13.1;
		break;

	case 13.2:
		scr_cutscene_lock(-1);
		global.sofievent = 13.4;
		break;

	case 13.4:
		if (delay(1.5, 905)) global.sofievent = 13.5;
		break;

	case 13.5:
		door_goto(rm_sofi_kitchen, "out-inside");
		global.sofievent = 14;
		break;

	case 14:
		if (room == rm_sofi_kitchen) {
			obj_shader_controller.vhs_intensity = 0.2;
			audio_sound_gain(snd_vhs, 0.3, 0);
			light_set_ambient(0.10, 0.09, 0.14, true);
			scr_cutscene_unlock(obj_Alberto);
			global.sofievent = 14.1;
		}
		break;

	case 14.1:
		if (room == rm_sofi) global.sofievent = 17;
		break;

	case 17:
		scr_cutscene_lock(-1);
		dialog_start([
			dialog_line("Agh que asco", "Alberto", -1, 0),
			dialog_line("Huele de la chingada", "Alberto", -1, 0)
		]);
		global.sofievent = 17.5;
		break;

	case 17.5:
		if (dialog_is_done()) global.sofievent = 18;
		break;

	case 18:
		tooltip("Regresa con los demás", 3);
		global.sofievent = 18.1;
		scr_cutscene_unlock(obj_Alberto);
		break;

	case 18.1:
		if (room == rm_sofi_outside_down) global.sofievent = 19;
		break;

	case 19:
		party_solo_end();
		scr_cutscene_lock(-1);
		obj_Alberto.no_collision = true;
		obj_Santiago.no_collision = true;
		obj_Diana.no_collision = true;
		dialog_start([
			dialog_line("¿y bien?", "Santiago", -1, 0),
			dialog_line("¿No estas viendo?", "Alberto", -1, 0),
			dialog_line("No esta wey", "Alberto", -1, 0),
			dialog_line("Seguro ni es nada, a de haber salido ya, o fue a algun lado con sus padres", "Santiago", -1, 0),
			dialog_line_timed("Mejor ya vamonos porque se nos va a hacer tarde", "Santiago", -1, 0, 1),
			dialog_line("No manches no, seguro que no esta Alberto?", "Diana", -1, 0),
			dialog_line("Pues si no está ni en su cuarto", "Alberto", -1, 0),
			dialog_line("Eso está raro", "Diana", -1, 0),
			dialog_line("Mira ya te dije, seguro no es nada", "Santiago", -1, 0),
			dialog_line("Además si llegamos tarde no nos van a dejar pasar, y Carlos ya nos está esperando", "Santiago", -1, 0),
			dialog_line("No pues está bien, ya vamonos", "Diana", -1, 0)
		]);
		global.sofievent = 19.5;
		break;

	case 19.5:
		if (dialog_is_done()) {
			event_set("sofi_disappeared");
			party_purge("sofi");
			scr_cutscene_unlock(-1);
			global.sofievent = 20;
		}
		break;

	case 20:
		transition(game_1_realhistory, 3);
		instance_destroy(self);
		break;
}