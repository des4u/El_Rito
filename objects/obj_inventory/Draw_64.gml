if (!global.inv_open) exit;

var _L  = inv_layout();
var _mx = device_mouse_x_to_gui(0);
var _my = device_mouse_y_to_gui(0);
var _gw = display_get_gui_width();
var _gh = display_get_gui_height();

draw_set_halign(fa_left);
draw_set_valign(fa_top);

draw_set_color(c_black);
draw_set_alpha(0.55);
draw_rectangle(0, 0, _gw, _gh, false);

draw_set_alpha(0.5);
draw_rectangle(_L.px - 3, _L.py - 3, _L.px + _L.pw + 3, _L.py + _L.ph + 3, false);

draw_set_color(make_color_rgb(8, 7, 10));
draw_set_alpha(0.96);
draw_rectangle(_L.px, _L.py, _L.px + _L.pw, _L.py + _L.ph, false);

draw_set_color(make_color_rgb(175, 175, 185));
draw_set_alpha(0.55);
var _t = 14;
draw_rectangle(_L.px, _L.py, _L.px + _t, _L.py + 2, false);
draw_rectangle(_L.px, _L.py, _L.px + 2, _L.py + _t, false);
draw_rectangle(_L.px + _L.pw - _t, _L.py, _L.px + _L.pw, _L.py + 2, false);
draw_rectangle(_L.px + _L.pw - 2, _L.py, _L.px + _L.pw, _L.py + _t, false);
draw_rectangle(_L.px, _L.py + _L.ph - 2, _L.px + _t, _L.py + _L.ph, false);
draw_rectangle(_L.px, _L.py + _L.ph - _t, _L.px + 2, _L.py + _L.ph, false);
draw_rectangle(_L.px + _L.pw - _t, _L.py + _L.ph - 2, _L.px + _L.pw, _L.py + _L.ph, false);
draw_rectangle(_L.px + _L.pw - 2, _L.py + _L.ph - _t, _L.px + _L.pw, _L.py + _L.ph, false);
draw_set_alpha(1);

draw_set_font(font_title);
draw_set_color(make_color_rgb(212, 200, 162));
draw_text_transformed(_L.px + 20, _L.py + 14, "INVENTARIO", 1.1, 1.1, 0);

draw_set_font(font_body);
draw_set_color(make_color_rgb(150, 150, 160));
draw_text_transformed(_L.px + 20, _L.py + 46, "PERSONAJES", 0.9, 0.9, 0);
draw_text_transformed(_L.px + 20, _L.py + 170, "MOCHILA", 0.9, 0.9, 0);
draw_text_transformed(_L.px + 20, _L.py + 268, "CONTROLES", 0.9, 0.9, 0);

for (var i = 0; i < array_length(_L.chars); i++) {
    var _c    = _L.chars[i];
    var _it   = char_item_get(_c.key);
    var _hov  = point_in_rectangle(_mx, _my, _c.x, _c.y, _c.x + _L.s, _c.y + _L.s);
    inv_draw_slot(_c.x, _c.y, _L.s, _it, _hov);

    draw_set_font(font_body);
    draw_set_halign(fa_center);
    draw_set_color(_c.key == global.controlled_key
        ? make_color_rgb(230, 210, 120)
        : make_color_rgb(190, 190, 184));
    draw_text_transformed(_c.x + _L.s * 0.5, _c.y + _L.s + 6, key_to_display(_c.key), 0.85, 0.85, 0);

    draw_set_color(make_color_rgb(130, 130, 138));
    var _lbl = is_undefined(_it) ? "-" : _it.name;
    draw_text_transformed(_c.x + _L.s * 0.5, _c.y + _L.s + 26, _lbl, 0.75, 0.75, 0);
    draw_set_halign(fa_left);
}

for (var i = 0; i < STASH_MAX; i++) {
    var _s   = _L.stash[i];
    var _it  = (i < array_length(global.stash)) ? global.stash[i] : undefined;
    var _hov = point_in_rectangle(_mx, _my, _s.x, _s.y, _s.x + _L.s, _s.y + _L.s);
    inv_draw_slot(_s.x, _s.y, _L.s, _it, _hov);
}

draw_set_font(font_body);
draw_set_color(make_color_rgb(160, 160, 154));
draw_text_transformed(_L.px + 20, _L.py + 292, "Arrastra con el MOUSE para asignar objetos", 0.8, 0.8, 0);
draw_text_transformed(_L.px + 20, _L.py + 312, "F - encender / apagar la luz del personaje activo", 0.8, 0.8, 0);
draw_text_transformed(_L.px + 20, _L.py + 332, "Q / E - cambiar personaje       R o ESC - cerrar", 0.8, 0.8, 0);

if (!is_undefined(drag_item)) {
    draw_set_color(c_white);
    draw_set_alpha(0.9);
    if (drag_item.icon != -1) {
        draw_sprite_stretched(drag_item.icon, 0, _mx - 22, _my - 22, 44, 44);
    }
    draw_set_alpha(1);
}

draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);
draw_set_alpha(1);