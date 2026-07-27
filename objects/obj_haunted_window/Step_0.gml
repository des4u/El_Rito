if (global.sofievent > 10) instance_destroy(self);

if (global.sofievent > 10) exit;
var _dist = point_distance(x, y, par_Character.x, par_Character.y);
var _max_dist = 210; 
var _min_dist = 50;  
var _vol_min = 1; 
var _vol_max = 15; 

var _t = 1.0 - clamp((_dist - _min_dist) / (_max_dist - _min_dist), 0.0, 1.0);


var _target = lerp(0.0, 4.0, _t); 
obj_shader_controller.vhs_intensity = lerp(obj_shader_controller.vhs_intensity, _target, 0.08);

obj_shader_controller.vhs_intensity = max(
    obj_shader_controller.vhs_intensity * 0.92, 
    _target
);

audio_sound_gain(snd_vhs, lerp(_vol_min, _vol_max, _t), 0);


