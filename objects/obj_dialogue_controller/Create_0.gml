persistent = true;
depth      = -10001;


dialog_active   = false;
dialog_lines    = [];       
dialog_index    = 0;        
dialog_done     = false;   
dialog_free     = false;

tw_text         = "";       
tw_text2        = "";       
tw_displayed    = "";       
tw_displayed2   = "";       
tw_index        = 0;       
tw_speed        = 0.04;     
tw_timer        = 0;
tw_finished     = false;
surf = -1;

cur_is_double   = false;
cur_name        = "";
cur_portrait    = -1;     
cur_portrait_fr = 0;       
cur_name2       = "";
cur_portrait2   = -1;
cur_portrait_fr2= 0;
cur_choices     = [];       
cur_timer       = -1;       
cur_obligatory  = false;    


choice_index    = 0;
choice_result   = -1;      

auto_timer      = 0;

dialog_font     = fnt_dialog;
name_font       = fnt_dialog_name;

cur_is_tooltip  = false;
tt_life         = 0;
tt_alpha        = 0;
tooltip_font    = fnt_vhs_sub;
tooltip_margin  = 56;
tooltip_fade    = 0.35;

box_h         = 104;
box_margin_x  = 40;
box_margin_y  = 28;
box_padding   = 18;
portrait_size = 72;
text_scale    = 2;
name_scale    = 1.5;