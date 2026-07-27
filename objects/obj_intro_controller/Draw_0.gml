var _cam = view_camera[0];
var _cx  = camera_get_view_x(_cam);
var _cy  = camera_get_view_y(_cam);
var _cw  = camera_get_view_width(_cam);
var _ch  = camera_get_view_height(_cam);
var _mx  = _cx + _cw / 2;
var _my  = _cy + _ch / 2;

if (fase == 4) {
    draw_sprite(spr_moon, floor(frame_luna), 502, 155);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_set_font(fnt_vhs_sub);
    for (var _i = 0; _i < array_length(menu_opciones); _i++) {
        var _y   = _my + _i * 40;
        var _sel = (_i == menu_seleccion);
        draw_set_color(_sel ? c_white : c_gray);
        draw_text(_mx, _y, menu_opciones[_i]);
        if (_sel && (current_time div 400) mod 2 == 0) {
            var _w = string_width(menu_opciones[_i]);
            draw_text(_mx - _w / 2 - 24, _y, ">");
        }
    }
    if (hold_espacio > 0) {
        var _bw = 200;
        var _bp = hold_espacio / hold_max;
        draw_set_color(c_dkgray);
        draw_rectangle(_mx - _bw/2, _my + 60, _mx + _bw/2, _my + 68, false);
        draw_set_color(c_white);
        draw_rectangle(_mx - _bw/2, _my + 60, _mx - _bw/2 + _bw*_bp, _my + 68, false);
    }
    draw_set_color(c_gray);
    draw_text(_mx, _cy + _ch - 20, "WASD para moverte   -   Manten ESPACIO para seleccionar");
}

if (fase < 4) {
    draw_set_color(c_black);
    draw_set_alpha(1);
    draw_rectangle(_cx, _cy, _cx + _cw, _cy + _ch, false);
}

if (fase == 3) {
    var _card = cards[card_actual];
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_set_color(c_white);
    draw_set_font(fnt_vhs_title);
    draw_text(_mx, _my, _card.titulo);
    if (_card.sub != "") {
        draw_set_font(fnt_vhs_sub);
        draw_text(_mx, _my + 48, _card.sub);
    }
}

draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);