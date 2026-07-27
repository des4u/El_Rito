if (!dialog_active) exit;

var _sw = display_get_gui_width();
var _sh = display_get_gui_height();

if (cur_is_tooltip) {
    var _a = tt_alpha;

    draw_set_font(tooltip_font);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);

    var _tw  = string_width(tw_text) * name_scale;
    var _th  = string_height(tw_text) * name_scale;
    var _cx  = _sw / 2;
    var _cy  = _sh - 90;
    var _pad = 14;

    draw_set_color(c_black);
    draw_set_alpha(_a * 0.85);
    draw_rectangle(_cx - _tw/2 - _pad, _cy - _th/2 - 8, _cx + _tw/2 + _pad, _cy + _th/2 + 8, false);

    draw_set_color(make_color_rgb(150, 150, 160));
    draw_set_alpha(_a * 0.3);
    draw_rectangle(_cx - _tw/2 - _pad, _cy - _th/2 - 8, _cx + _tw/2 + _pad, _cy - _th/2 - 7, false);

    draw_set_color(c_black);
    draw_set_alpha(_a * 0.8);
    draw_text_transformed(_cx + 2, _cy + 2, tw_text, name_scale, name_scale, 0);
    draw_set_color(make_color_rgb(220, 220, 214));
    draw_set_alpha(_a);
    draw_text_transformed(_cx, _cy, tw_text, name_scale, name_scale, 0);

    draw_set_alpha(1);
    draw_set_color(c_white);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    exit;
}

draw_set_halign(fa_left);
draw_set_valign(fa_top);

var _bw_full = _sw - box_margin_x * 2;
var _bw = cur_is_double ? (_bw_full / 2 - 8) : _bw_full;
var _bh = box_h;
var _by = _sh - box_margin_y - _bh;
var _panels = cur_is_double ? 2 : 1;

var _tx0 = 0;
var _ty0 = 0;
var _tww0 = 0;
var _bx0 = 0;

for (var p = 0; p < _panels; p++) {
    var _bx   = box_margin_x + p * (_bw + 16);
    var _name = (p == 0) ? cur_name : cur_name2;
    var _por  = (p == 0) ? cur_portrait : cur_portrait2;
    var _pfr  = (p == 0) ? cur_portrait_fr : cur_portrait_fr2;
    var _txt  = (p == 0) ? tw_displayed : tw_displayed2;

    draw_set_color(c_black);
    draw_set_alpha(0.5);
    draw_rectangle(_bx - 3, _by - 3, _bx + _bw + 3, _by + _bh + 3, false);

    draw_set_color(make_color_rgb(8, 7, 10));
    draw_set_alpha(0.94);
    draw_rectangle(_bx, _by, _bx + _bw, _by + _bh, false);

    draw_set_color(make_color_rgb(150, 150, 160));
    draw_set_alpha(0.35);
    draw_rectangle(_bx, _by, _bx + _bw, _by + 1, false);
    draw_set_alpha(0.14);
    draw_rectangle(_bx, _by + _bh - 1, _bx + _bw, _by + _bh, false);

    draw_set_color(make_color_rgb(175, 175, 185));
    draw_set_alpha(0.55);
    var _t = 10;
    draw_rectangle(_bx, _by, _bx + _t, _by + 2, false);
    draw_rectangle(_bx, _by, _bx + 2, _by + _t, false);
    draw_rectangle(_bx + _bw - _t, _by, _bx + _bw, _by + 2, false);
    draw_rectangle(_bx + _bw - 2, _by, _bx + _bw, _by + _t, false);
    draw_rectangle(_bx, _by + _bh - 2, _bx + _t, _by + _bh, false);
    draw_rectangle(_bx, _by + _bh - _t, _bx + 2, _by + _bh, false);
    draw_rectangle(_bx + _bw - _t, _by + _bh - 2, _bx + _bw, _by + _bh, false);
    draw_rectangle(_bx + _bw - 2, _by + _bh - _t, _bx + _bw, _by + _bh, false);
    draw_set_alpha(1);

    var _text_x = _bx + box_padding;
    var _avail  = _bw - box_padding * 2;

    if (_por != -1) {
        var _px = (p == 0) ? (_bx + box_padding) : (_bx + _bw - box_padding - portrait_size);
        var _py = _by + (_bh - portrait_size) / 2;

        draw_set_color(c_black);
        draw_set_alpha(0.6);
        draw_rectangle(_px + 2, _py + 2, _px + portrait_size + 2, _py + portrait_size + 2, false);

        draw_set_color(c_white);
        draw_set_alpha(1);
        draw_sprite_stretched(_por, _pfr, _px, _py, portrait_size, portrait_size);

        draw_set_color(make_color_rgb(150, 150, 160));
        draw_set_alpha(0.4);
        draw_rectangle(_px, _py, _px + portrait_size, _py + portrait_size, true);
        draw_set_alpha(1);

        if (p == 0) _text_x = _px + portrait_size + box_padding;
        _avail -= (portrait_size + box_padding);
    }

    if (_name != "") {
        draw_set_font(name_font);
        var _nw = string_width(_name) * name_scale;
        var _nh = string_height(_name) * name_scale;
        var _nx = (p == 0) ? (_bx + 14) : (_bx + _bw - 14 - _nw);
        var _ny = _by - _nh - 10;

        draw_set_color(make_color_rgb(8, 7, 10));
        draw_set_alpha(0.92);
        draw_rectangle(_nx - 10, _ny - 5, _nx + _nw + 10, _by, false);

        draw_set_color(make_color_rgb(200, 190, 160));
        draw_set_alpha(0.55);
        draw_rectangle(_nx - 10, _ny - 5, _nx + _nw + 10, _ny - 4, false);

        draw_set_color(c_black);
        draw_set_alpha(0.8);
        draw_text_transformed(_nx + 1, _ny + 1, _name, name_scale, name_scale, 0);
        draw_set_color(make_color_rgb(212, 200, 162));
        draw_set_alpha(1);
        draw_text_transformed(_nx, _ny, _name, name_scale, name_scale, 0);
    }

    var _text_y = _by + box_padding - 2;
    var _text_w = _avail / text_scale;

    draw_set_font(dialog_font);
    draw_set_color(c_black);
    draw_set_alpha(0.85);
    draw_text_ext_transformed(_text_x + 2, _text_y + 2, _txt, -1, _text_w, text_scale, text_scale, 0);

    draw_set_color(make_color_rgb(238, 238, 232));
    draw_set_alpha(1);
    draw_text_ext_transformed(_text_x, _text_y, _txt, -1, _text_w, text_scale, text_scale, 0);

    if (p == 0) {
        _tx0  = _text_x;
        _ty0  = _text_y;
        _tww0 = _text_w;
        _bx0  = _bx;
    }
}

if (tw_finished && array_length(cur_choices) > 0) {
    draw_set_font(dialog_font);
    var _cy = _ty0 + string_height_ext(tw_text, -1, _tww0) * text_scale + 10;
    for (var i = 0; i < array_length(cur_choices); i++) {
        var _ch = string_height(cur_choices[i]) * text_scale;
        if (i == choice_index) {
            draw_set_color(c_white);
            draw_set_alpha(0.07);
            draw_rectangle(_tx0 - 6, _cy - 2, _tx0 + 26 + string_width(cur_choices[i]) * text_scale, _cy + _ch + 2, false);

            draw_set_color(c_black);
            draw_set_alpha(0.8);
            draw_text_transformed(_tx0 + 22, _cy + 2, cur_choices[i], text_scale, text_scale, 0);
            draw_set_color(make_color_rgb(230, 210, 120));
            draw_set_alpha(1);
            draw_text_transformed(_tx0 + 20, _cy, cur_choices[i], text_scale, text_scale, 0);

            if ((current_time mod 700) < 450) {
                draw_text_transformed(_tx0, _cy, ">", text_scale, text_scale, 0);
            }
        } else {
            draw_set_color(make_color_rgb(150, 150, 150));
            draw_set_alpha(0.7);
            draw_text_transformed(_tx0 + 20, _cy, cur_choices[i], text_scale, text_scale, 0);
        }
        draw_set_alpha(1);
        _cy += _ch + 6;
    }
}

if (tw_finished && array_length(cur_choices) == 0 && cur_timer < 0) {
    if ((current_time mod 900) < 450) {
        var _ix = _bx0 + _bw - box_padding - 4;
        var _iy = _by + _bh - box_padding + 2;
        draw_set_color(c_white);
        draw_set_alpha(0.75);
        draw_triangle(_ix - 6, _iy - 6, _ix + 6, _iy - 6, _ix, _iy, false);
        draw_set_alpha(1);
    }
}

draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);
draw_set_alpha(1);