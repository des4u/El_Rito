if (global.switch_cd > 0) {
    global.switch_cd--;
    if (global.switch_cd == 0) global.switching = false;
}

if (!global.switching && array_length(global.party) > 1) {
    if (keyboard_check_pressed(ord("E"))) scr_switch_character(1);
    if (keyboard_check_pressed(ord("Q"))) scr_switch_character(-1);
}