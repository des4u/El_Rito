var _cam   = view_camera[0];
var _cur_x = camera_get_view_x(_cam);
var _cur_y = camera_get_view_y(_cam);
var _w     = camera_get_view_width(_cam);
var _h     = camera_get_view_height(_cam);

var _max_x = max(0, room_width  - _w);
var _max_y = max(0, room_height - _h);

if (!global.cam_locked) {
    var _active = global.controlled;
    if (!instance_exists(_active)) {
        party_ensure_controlled();
        _active = global.controlled;
    }
    if (instance_exists(_active)) {
        var _cx = clamp(_active.x - _w / 2, 0, _max_x);
        var _cy = clamp(_active.y - _h / 2, 0, _max_y);
        if (global.cam_needs_snap) {
            camera_set_view_pos(_cam, _cx, _cy);
            global.cam_needs_snap = false;
        } else {
            var _speed = global.switching ? 0.08 : 0.15;
            camera_set_view_pos(_cam, lerp(_cur_x, _cx, _speed), lerp(_cur_y, _cy, _speed));
        }
    }
} else {
    var _tx = clamp(global.cam_target_x - _w / 2, 0, _max_x);
    var _ty = clamp(global.cam_target_y - _h / 2, 0, _max_y);
    camera_set_view_pos(_cam, lerp(_cur_x, _tx, 0.08), lerp(_cur_y, _ty, 0.08));
}