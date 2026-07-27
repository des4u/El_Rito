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
		dialog_start([
			dialog_tooltip_wait("Presiona R para abrir el inventario"),
			dialog_tooltip_wait("Arrastra los objetos con el mouse para asignarlos a cada personaje"),
			dialog_tooltip_wait("Usa F para encender la luz de un personaje con luz equipada")
		]);
		global.kioscoevent = 12.5;
		break;

	case 12.5:
		if (dialog_is_done()) global.kioscoevent = 13;
		break;

	case 13:
		break;
		
		
}