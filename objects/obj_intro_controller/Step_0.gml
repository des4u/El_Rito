tiempo += 1;

switch (fase) {
	case 0:
        if (tiempo >= duracion_cine) {
            fase = 2; tiempo = 0;
            audio_play_sound(snd_insert, 0, false);
        }
        break;
    case 2:
        if (!audio_is_playing(snd_insert)) { fase = 3; tiempo = 0; }
        break;
    case 3:
        if (!audio_is_playing(snd_ambiance)) audio_play_sound(snd_ambiance, 0, true);
        if (tiempo >= duracion_card) {
            tiempo = 0;
            card_actual += 1;
            if (card_actual >= array_length(cards)) {
                fase = 4; tiempo = 0;
                boton_iniciar = instance_create_layer(77, 168, "buttons", obj_play);
            }
        }
        break;

	case 4:
		frame_luna += velocidad;
		if (frame_luna >= sprite_get_number(spr_moon)) frame_luna = 0;
		if (instance_exists(boton_iniciar) && !boton_iniciar.presionado) {
			if (keyboard_check_pressed(ord("W")) || keyboard_check_pressed(ord("A"))) menu_seleccion -= 1;
			if (keyboard_check_pressed(ord("S")) || keyboard_check_pressed(ord("D"))) menu_seleccion += 1;
			menu_seleccion = clamp(menu_seleccion, 0, array_length(menu_opciones) - 1);
			if (keyboard_check(vk_space) && menu_opciones[menu_seleccion] == "INICIAR") {
				hold_espacio += 1;
				if (hold_espacio >= hold_max) boton_iniciar.presionado = true;
			} else {
				hold_espacio = 0;
			}
		}
		break;
}