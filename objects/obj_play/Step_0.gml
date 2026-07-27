if (presionado) {
    tiempo_presionado += 1;
    escala = escala_base - (tiempo_presionado / 40);
	
    if (tiempo_presionado >= 30) {
       transition(game_1_presentation, 2);
	   if (!audio_is_playing(snd_static)){
	   audio_play_sound(snd_static,1,false);
	   }
		audio_stop_sound(snd_ambiance);
    }
} else {
    escala = escala_base + (sin(current_time / 250) * 0.05);
}