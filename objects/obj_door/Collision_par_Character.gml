if (!armed) exit;
if (other.id != global.controlled || par_Character.no_collision || transition_blocks_input()) exit;
if (target_room == -1 || target_door == "") exit;
door_goto(target_room, target_door);