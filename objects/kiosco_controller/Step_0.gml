 cs_walk_update();
tiempo += 1;
//ok, que es cs_walk?
//es para varios personajes caminando a la vez, xd

switch (global.kioscoevent) {
    case 0:
        if (delay(4.0, 100)) global.kioscoevent = 1;
        break;

    case 1:
        dialog_start([
            dialog_line("Sofia no aparecio durante los siguientes dias", "", -1, 0),
            dialog_line("Pasaron 3 dias, sin señales de ella en la escuela, o con sus amigos", "", -1, 0),
            dialog_line("Diana, por su parte, se ponia cada vez mas preocupada", "", -1, 0),
            dialog_line("Así que: el viernes propuso a su amigos volver a buscarla en su casa ese mismo domingo", "", -1, 0),
            dialog_line("Esta es la historia de una caceria de Brujas.", "", -1, 0)
        ]);
        global.kioscoevent = 1.5;
        break;

    case 1.5:
        if (dialog_is_done()) global.kioscoevent = 2;
        break;

    case 2:
        if (delay(1.0, 101)) {
            tiempo = 0;
            card_actual = 0;
            global.kioscoevent = 3;
        }
        break;

    case 3:
        if (tiempo >= duracion_card) {
            tiempo = 0;
            card_actual += 1;
            if (card_actual >= array_length(cards)) {
                global.kioscoevent = 4;
                tiempo = 0;
            }
        }
        break;

    case 4:
        if (delay(3.0, 102)) global.kioscoevent = 5;
        break;

	case 5:
        event_set("Transitiontogame");
        global.day = "6pm";
		hora_set(18);
        global.solo_mode = false;
        global.party_stationed = {};
        global.party_instances = {};
        party_set(["diana"]);
        door_goto(rm_plaza_kiosco, "-1");
        global.kioscoevent = 5.5;
        break;
    case 5.5:
        if (room == rm_plaza_kiosco) global.kioscoevent = 6;
        break;

    case 6:
        if (delay(4.0, 103)) global.kioscoevent = 7;
        break;

    case 7:
        santi_inst = party_add_instance("santi", 343, 430);
        cs_walk(santi_inst, 253, 353, 1.2);
        global.kioscoevent = 7.5;
        break;

    case 7.5:
        if (cs_walk_done(santi_inst)) {
            cs_face(party_get_instance("diana"), "right");
            if (delay(0.8, 104)) global.kioscoevent = 8;
        }
        break; 

    case 8:
        dialog_start([
            dialog_line_timed("...", "", -1, 0, 2),
            dialog_line("Hola", "Santiago", -1, 0),
            dialog_line("Hola", "", -1, 0),
            dialog_line_timed(".", "", -1, 0, 1),
            dialog_line_timed(".", "", -1, 0, 1),
            dialog_line_timed(".", "", -1, 0, 1),
            dialog_line("Entonces, ¿qué vamos a hacer?", "Santiago", -1, 0),
            dialog_line("Esperar a los demas", "Diana", -1, 0),
            dialog_line_timed("Ah, claro", "Santiago", -1, 0, 4),
            dialog_line("¿Y, si crees que Carlos vaya a venir?", "Santiago", -1, 0),
            dialog_line("Claro, pues, ¿por qué no vendria?", "Diana", -1, 0),
            dialog_line("Es que es domingo...", "Santiago", -1, 0),
            dialog_line("Y pués ya sabes como es él", "Santiago", -1, 0),
            dialog_line("¿Qué?, ¿qué parece santito por ir a misa todos los domingos?", "Diana", -1, 0),
            dialog_line("Jaja...", "Santiago", -1, 0),
            dialog_line("Si, eso", "Santiago", -1, 0),
            dialog_line_timed("No si, me dijo que sí iba a venir", "Diana", -1, 0, 2)
        ]);
        global.kioscoevent = 8.5;
        break;

    case 8.5:
        if (dialog_is_done()) global.kioscoevent = 9;
        break;

    case 9:
        carlos_inst = party_add_instance("carlos", 560, 430);
        cs_walk(carlos_inst, 316, 371, 1.5);
        global.kioscoevent = 9.2;
        break;

    case 9.2:
        if (delay(0.7, 105)) {
            alberto_inst = party_add_instance("alberto", 580, 442);
            cs_walk(alberto_inst, 292, 378, 3.5);
            global.kioscoevent = 9.5;
        }
        break;

    case 9.5:
        dialog_start([
            dialog_line_timed("De hecho, creo que ahí vienen", "Diana", -1, 0, 0.2),
			dialog_line_timed("¿PERO ESTABA EXAGERANDO NO?", "Alberto", -1, 0, 2),
			dialog_line_timed("Ay, no puede ser", "Santiago", -1, 0, 1),
        ]);
        global.kioscoevent = 9.6;
        break;

    case 9.6:
        if (dialog_is_done()) {
            global.kioscoevent = 10;
        }
        break;

    case 10:
		dialog_start([
			dialog_line("ya ya, ya me dí cuenta que esto si es serio", "Santiago",-1,0),
			dialog_line("¿Por qué Alberto estaria exagerando?", "Carlos",-1,0),
			dialog_line("Porque pensé que Sofi ya habia salido, o que estaba afuera con sus papás o algo asi", "Santiago",-1,0),
			dialog_line("Yo que sé", "Santiago",-1,0),
			dialog_line("(Alberto suspira)", "",-1,0),
			dialog_line("Bueno no importa, solo hagamos lo que dijimos el viernes", "Alberto",-1,0),
			dialog_line("Santiago, ¿trajiste las cosas?", "Alberto",-1,0),
			dialog_line("Solo un par de linternas con batería vieja", "Santiago",-1,0),
			dialog_line("...¿Carlos traes tu cirio?", "Santiago",-1,0),
			dialog_line("No voy a usar un cirio para alumbrar", "Carlos",-1,0),
			dialog_line("Pero lo traes", "Santiago",-1,0),
			dialog_line_timed("", "",-1,0,3),
			dialog_line("si", "Carlos",-1,0),
			dialog_line("Entonces vamonos ya", "Santiago",-1,0)
		]);
		global.kioscoevent = 10.5
		break;
	case 10.5:
		if (dialog_is_done()) {
			global.kioscoevent = 10.6;
		}
		break;
	case 10.6:
		scr_cutscene_unlock(-1);
		tooltip("Presiona Q o E para intercambiar personajes", 3);
		global.kioscoevent = 11;
		break;
	case 11:
		stash_add_type("flashlight");
		stash_add_type("flashlight");
		stash_add_type("candle");
		global.inv_unlocked = true;
		global.kioscoevent = 11.5;
		break;

	case 11.5:
		if (dialog_is_done()) global.kioscoevent = 12;
		break;

	case 12:
		dialog_start([ dialog_tooltip_wait("Presiona R para abrir el inventario") ]);
		global.kioscoevent = 12.2;
		break;

	case 12.2:
		if (global.inv_open) {
			global.kioscoevent = 12.3;
		} else if (dialog_is_done()) {
			dialog_start([ dialog_tooltip_wait("Presiona R para abrir el inventario") ]);
		}
		break;

	case 12.3:
		dialog_start([ dialog_tooltip("Arrastra los objetos con el mouse para asignarlos a cada personaje", 6) ]);
		global.kioscoevent = 12.4;
		break;

	case 12.4:
		if (dialog_is_done()) global.kioscoevent = 12.5;
		break;

	case 12.5:
		dialog_start([ dialog_tooltip("Usa F para encender la luz de un personaje con luz equipada", 6) ]);
		global.kioscoevent = 12.6;
		break;

	case 12.6:
		if (dialog_is_done()) global.kioscoevent = 13;
		break;

	case 13:
		if (room == rm_plaza_arcs) global.kioscoevent = 14;
		break;

	case 14:
		dialog_start_free([
			dialog_line("Wey, Carlos", "Alberto",-1,0),
			dialog_line("Mandé", "Carlos",-1,0),
			dialog_line("¿Por qué no estás en la iglesía?", "Alberto",-1,0),
			dialog_line("Fuí en la mañana we", "Carlos",-1,0),
			dialog_line("Ah claro", "Alberto",-1,0),
			dialog_line("Como convenciste a tus padres de venir aca", "Carlos",-1,0),
			dialog_line("No ps", "Alberto",-1,0),
			dialog_line("Les dije que me íba a quedar en tu casa", "Alberto",-1,0),
			dialog_line("No mames Alberto, te dije que dijeras que a casa de Santiago", "Carlos",-1,0),
			dialog_line("Mi Mamá se va a poner histerica si se entera", "Carlos",-1,0),
			double_dialogue("Con eso de que ya no me deja salir desde que desapareció Carlota", "Carlos",-1,0,"Chingadamadre' no, me dijiste que tu casa", "Alberto",-1,0),
			dialog_line("...", "",-1,0),
			dialog_line("Pero si te vas a meter al cerro de noche o vas a estar de miedoso Alberto", "Santiago",-1,0),
			dialog_line("Tú callate Santiago", "Alberto",-1,0)
		]);
		global.kioscoevent = 14.5;
		break;

	case 14.5:
		if (dialog_is_done()) global.kioscoevent = 15;
		break;

	case 15:
		break;

	case 15.5:
		scr_cutscene_lock(-1);
		dialog_start([
			dialog_line("¿De qué tanto hablan?", "Diana",-1,0)
		]);
		global.kioscoevent = 15.7;
		break;

	case 15.7:
		if (dialog_is_done()) global.kioscoevent = 16;
		break;

	case 16:
		scr_cutscene_lock(-1);
		dialog_start([
			dialog_line_choices("¿Se van a San Jacinto?", "",-1,0, ["Sí, vámonos ya", "No, seguir explorando la ciudad"])
		]);
		global.kioscoevent = 16.5;
		break;

	case 16.5:
		if (dialog_is_done()) {
			if (dialog_choice_result() == 0) {
				global.kioscoevent = 17;
			} else {
				scr_cutscene_unlock(-1);
				global.kioscoevent = 15;
			}
		}
		break;

	case 17:
		event_set("bus_to_sanjacinto");
		global.cam_locked = false;
		global.party_traveling = [];
		global.party_stationed = {};
		global.party_instances = {};
		transition(game_1_thebus, 3);
		global.kioscoevent = 17.5;
		break;

	case 17.5:
		if (room == game_1_thebus) {
			light_set_ambient(0.5, 0.5, 0.6, true);
			obj_shader_controller.flicker_intensity = 0.5;
			global.kioscoevent = 18;
		}
		break;

	case 18:
		if (delay(2.0, 106)) global.kioscoevent = 19;
		break;

	case 19:
		dialog_start([
			dialog_line("Comentario de el creador: En esta demo narraremos todo lo que ocurre, esperamos tener dibujos listos para la salida final", "", -1, 0),
			dialog_line("Por su comprensión, gracias", "", -1, 0),
			dialog_line_timed("", "", -1, 0, 4),
			dialog_line("El grupo se subio al autobus", "", -1, 0),
			dialog_line("Al frente, se sentaron Carlos y Alberto juntos", "", -1, 0),
			dialog_line("Atras, Diana y Santiago", "", -1, 0),
			dialog_line_timed("", "", -1, 0,2),
			dialog_line("¿Oye y si viste a Vero hoy en la escuela?", "Alberto", -1, 0),
			dialog_line("En tu grupo, pues", "Alberto", -1, 0),
			dialog_line("¿Qué?", "Carlos", -1, 0),
			dialog_line("--Carlos miraba por la ventana, estaba distraido--", "", -1, 0),
			dialog_line("--Voltea a ver a Alberto--", "", -1, 0),
			dialog_line("Perdoname, estaba distraido", "Carlos", -1, 0),
			dialog_line("Que si viste a Veronica en la escuela", "Alberto", -1, 0),
			dialog_line_timed("Ahh", "Carlos", -1, 0,0.5),
			dialog_line("Si, ¿por qué la pregunta?", "Carlos", -1, 0),
			dialog_line("Ah, no por nada", "Alberto", -1, 0),
			double_dialogue_timed("Es que queria que le preguntaras si podriamos ir este martes a la heladeria", "Alberto", -1, 0, "De hecho: fuimos a la heladeria antes de venir aca", "Carlos", -1, 0, 0.3),
			double_dialogue_timed("¿Qué?", "Alberto", -1, 0, "¿Qué?","Carlos", -1, 0, 0.7),
			double_dialogue_timed("Ah no, nada", "Alberto", -1, 0, "Ah no, nada","Carlos", -1, 0, 0.7),
			double_dialogue_timed("...", "Alberto", -1, 0, "...","Carlos", -1, 0, 1.5),
			double_dialogue_timed("JAJAJAJA", "Alberto", -1, 0, "JAJAJAJA","Carlos", -1, 0, 1),
			dialog_line("¿Oye y si te conte lo que hizo Matias?...", "Alberto", -1, 0),
			dialog_line_timed("", "Carlos", -1, 0,2),
			dialog_line("Diana y Santiago se quedaron callados", "", -1, 0),
			dialog_line("Ocasionalmente, interrumpido por miradas", "", -1, 0),
			dialog_line("Diana Sonreía", "", -1, 0),
			dialog_line("Era una sonrisa amable", "", -1, 0),
			dialog_line("Santiago regresaba el gesto", "", -1, 0),
			dialog_line("Era una sonrisa de afecto", "", -1, 0),
			dialog_line("Ninguno de los dos sabía lo que la sonrisa del otro significaba", "", -1, 0),
			dialog_line("Y, para cuando llegaron, ya se habia hecho de noche", "", -1, 0),
			dialog_line("Domingo, 13 de Octubre de 1996, 7:30pm", "", -1, 0)
			
		]);
		global.kioscoevent = 19.5;
		break;

	case 19.5:
		if (dialog_is_done()) global.kioscoevent = 20;
		break;

	case 20:
		if (delay(3.0, 107)) global.kioscoevent = 21;
		break;

	case 21:
		break;
}
		