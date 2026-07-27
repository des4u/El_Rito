if global.sofievent < 1 {
	global.sofievent = 1;
}

if global.sofievent > 17 {
		dialog_start([
			dialog_line("Intentas encender la luz, pero no ocurre nada","",-1,0)
			])	
}