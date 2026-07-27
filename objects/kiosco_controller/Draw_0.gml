var _cam = view_camera[0];
var _cx = camera_get_view_x(_cam);
var _cy = camera_get_view_y(_cam);
var _cw = camera_get_view_width(_cam);
var _ch = camera_get_view_height(_cam);

if (global.kioscoevent == 3) {
    var _card = cards[card_actual];
    var _fade = clamp(min(tiempo / 25, (duracion_card - tiempo) / 25), 0, 1);

    draw_set_alpha(1);
    draw_set_color(c_black);
    draw_rectangle(_cx, _cy, _cx + _cw, _cy + _ch, false);

    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_set_color(c_white);
    draw_set_alpha(_fade);
    draw_set_font(fnt_vhs_title);
    draw_text(floor(_cx + _cw / 2), floor(_cy + _ch / 2), _card.titulo);

    if (_card.sub != "") {
        draw_set_font(fnt_vhs_sub);
        draw_text(floor(_cx + _cw / 2), floor(_cy + _ch / 2 + 24), _card.sub);
    }
    draw_set_alpha(1);
}

draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);