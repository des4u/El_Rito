if (global.sofievent == 4 || global.sofievent == 5) {
    var _cam = view_camera[0];
    var _cx  = camera_get_view_x(_cam);
    var _cy  = camera_get_view_y(_cam);
    draw_sprite(spr_outside, 0, _cx, _cy);
}