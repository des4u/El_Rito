tiempo += delta_time / 1000000; 


switch (phase){
	
	case 0: 
		if (tiempo >= 0) {
			vhs_fx_play(2);
			phase = 1;
		}
		break;
	case 1: 
		if (tiempo >= 4.8) {
			light_set_ambient(0.08, 0.1, 0.15);
			vhs_fx_stop()
			phase = 2;
		}
		break;		
	case 2: 
		if (tiempo >= 12) {
			phase = 3;
		}
		break;
	case 3: 
		if (tiempo >= 22) {
			phase = 4;
		}
		break;
	case 4: 
		if (tiempo >= 26) {
		dialog_start([
		dialog_line_timed("Que horas son?", "", -1, 0, 4.0)
		]);
			phase = 5;
		}
		break;
	case 5: 

		if (tiempo >= 32) {
			phase = 6;
		}
		break;
	case 6: 
		light_set_ambient(0.02, 0.02, 0.06);
		obj_shader_controller.flicker_intensity = 2.0;
		obj_shader_controller.vhs_target_intensity = 1.2;
		transition(rm_sofi,3);
		break;
}