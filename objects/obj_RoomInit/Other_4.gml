party_setup_for_story();
show_debug_message("=== ANTES DE SPAWN ===");
show_debug_message("char_inventory existe: " + string(variable_struct_exists(global.char_inventory, "sofi")));
show_debug_message("char_light existe: " + string(variable_struct_exists(global.char_light, "sofi")));
party_spawn();
scr_cutscene_stage();
scr_room_setup()