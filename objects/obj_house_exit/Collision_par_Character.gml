if (!armed) exit;
if (other.id != global.controlled || par_Character.no_collision || transition_blocks_input()) exit;
if (global.sofievent < 18) exit;
if (global.sofievent == 18) global.sofievent = 19;
event_inherited();