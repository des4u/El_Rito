if (!armed) exit;
if (other.id != global.controlled || par_Character.no_collision || transition_blocks_input()) exit;
if (global.sofievent == 15) global.sofievent = 17;
event_inherited();