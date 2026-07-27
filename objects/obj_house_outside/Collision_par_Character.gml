if (other.id != global.controlled || par_Character.no_collision || global.sofievent < 18) exit;
door_goto(rm_sofi_outside_down, "insides_out");

if global.sofievent < 18
 {
		dialog_start([
			dialog_line("No tienes nada que hacer afuera","",-1,0)
			])	
}

if global.sofievent == 18
{
	global.sofievent = 19;
}