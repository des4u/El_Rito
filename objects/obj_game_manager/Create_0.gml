if (instance_number(obj_game_manager) > 1) {
    instance_destroy();
    exit;
}

global.party_traveling  = [];
global.party_stationed  = {};

global.party = [];

global.solo_mode = false;
global.from_door = false;
global.controlled_key = "";

global.controlled = noone;

if (variable_global_exists("__gm_initialized")) {
    instance_destroy();
    exit;
}
global.__gm_initialized = true;

global.stash        = [];
global.char_item    = {};
global.inv_open     = false;
global.inv_unlocked = false;

persistent = true;


global.party_instances = {};


global.prev_door_id = "";


global.spawn_points = {};


global.events = {};


global.switching = false;
global.player_idle_timer = 0;


scr_register_spawns();
party_boot();
