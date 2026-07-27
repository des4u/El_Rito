is_active    = false;
move_speed   = 5.5;
input_x      = 0;
input_y      = 0;


party_index  = -1;

player_vision_enabled = true;   
player_vision_radius  = 220;    



visibility_light_id = light_add(x, y, 40, 0.3, "body", 0.8, 0.8, 0.9);

ai_stance        = "curious";  // "timid", "brave", "curious"
ai_speed         = move_speed * 0.8;
ai_state         = "idle";     // "idle", "follow", "wander", "scared"


ai_follow_dist   = 180;  
ai_comfort_dist  = 80;    


ai_wander_timer  = 0;
ai_wander_x      = 0;
ai_wander_y      = 0;
ai_wander_pause  = 0;     


ai_look_x        = x;
ai_look_y        = y;
ai_look_timer    = 0;     

ai_step_pause  = 0;   
ai_speed_var   = 0;   
ai_move_axis = 0;
ai_look_target_x = 0;
ai_look_target_y = 0;

cutscene_locked = false;   
no_collision   = false; 

char_name = "";
last_dir = "down"; 
sprite_initialized = false;

