if (!active) exit;

var _cam = view_camera[view_current];
var _vx, _vy, _vw, _vh;
if (view_enabled && _cam >= 0) {
    _vx = camera_get_view_x(_cam);
    _vy = camera_get_view_y(_cam);
    _vw = camera_get_view_width(_cam);
    _vh = camera_get_view_height(_cam);
} else {
    _vx = 0; _vy = 0; _vw = room_width; _vh = room_height;
}

draw_set_font(dev_font);
var _fh = string_height("M");
var _cwd = string_width("M");

var _pw = floor(_vw * 0.92);
var _phmax = _vh * 0.92;

var _s = _phmax / (ui_lines * _fh * 1.2);
if (_s >= 1) _s = floor(_s);

var _rh   = ceil(_fh * _s * 1.2);
var _pad  = _rh * 0.6;
var _head = _rh * 3.4;
var _foot = _rh * 2.2;

rows = max(1, floor((_phmax - _head - _foot) / _rh));

var _ph = floor(_head + rows * _rh + _foot);
var _px = floor(_vx + (_vw - _pw) * 0.5);
var _py = floor(_vy + (_vh - _ph) * 0.5);

var _l = list_of();
var _n = array_length(_l);
var _deep = array_length(stack) > 0;
var _bar = _rh * 0.5;
var _maxc = max(4, floor((_pw - _pad * 2 - _bar) / (_cwd * _s)));

draw_set_alpha(1);
draw_set_color(col_bg);
draw_rectangle(_px, _py, _px + _pw, _py + _ph, false);

draw_set_color(col_accent);
draw_rectangle(_px, _py, _px + _pw, _py + _rh * 1.4, false);
draw_rectangle(_px, _py, _px + _pw, _py + _ph, true);

draw_set_halign(fa_left);
draw_set_valign(fa_top);

var _title = "DEVTOOLS " + string_upper(room_get_name(room));
if (_deep) {
    _title = "";
    for (var i = 0; i < array_length(stack); i++) {
        if (i > 0) _title += " > ";
        _title += string(stack[i].name);
    }
}

draw_set_color(col_bg);
dtext(_px + _pad, _py + _rh * 0.15, string_copy(_title, 1, _maxc - 8), _s);
draw_set_halign(fa_right);
dtext(_px + _pw - _pad, _py + _rh * 0.15, string(_n > 0 ? sel + 1 : 0) + "/" + string(_n), _s);
draw_set_halign(fa_left);

var _tx = _px + _pad;
var _ty = _py + _rh * 1.8;
for (var i = 0; i < 4; i++) {
    var _tw = string_width(tab_names[i]) * _s;
    if (i == tab && !_deep) {
        draw_set_color(col_accent);
        draw_rectangle(_tx - _pad * 0.4, _ty - _rh * 0.12, _tx + _tw + _pad * 0.4, _ty + _rh * 0.95, false);
        draw_set_color(col_bg);
    } else draw_set_color(i == tab ? col_fg : col_dim);
    dtext(_tx, _ty, tab_names[i], _s);
    _tx += _tw + _pad * 1.6;
}

var _y = _py + _head;
for (var i = top; i < min(_n, top + rows); i++) {
    if (i == sel) {
        draw_set_color(col_accent);
        draw_rectangle(_px + 1, _y, _px + _pw - 1, _y + _rh - 1, false);
        draw_set_color(col_bg);
    } else {
        if ((i - top) mod 2 == 1) {
            draw_set_color(col_bg2);
            draw_rectangle(_px + 1, _y, _px + _pw - 1, _y + _rh - 1, false);
        }
        draw_set_color(col_fg);
    }
    dtext(_px + _pad, _y + _rh * 0.1, string_copy(row_label(_l[i]), 1, _maxc), _s);
    _y += _rh;
}

if (_n == 0) {
    draw_set_color(col_dim);
    dtext(_px + _pad, _py + _head + _rh * 0.1, "-- vacio --", _s);
} else if (_n > rows) {
    var _ty0 = _py + _head;
    var _th = rows * _rh;
    draw_set_color(col_bg2);
    draw_rectangle(_px + _pw - _bar, _ty0, _px + _pw - 2, _ty0 + _th, false);
    var _hh = max(_rh, _th * (rows / _n));
    var _hy = _ty0 + (_th - _hh) * (top / max(_n - rows, 1));
    draw_set_color(col_accent);
    draw_rectangle(_px + _pw - _bar, _hy, _px + _pw - 2, _hy + _hh, false);
}

var _fy = _py + _ph - _foot;
draw_set_color(col_bg2);
draw_rectangle(_px + 1, _fy, _px + _pw - 1, _py + _ph - 1, false);

if (editing) {
    draw_set_color(col_edit);
    dtext(_px + _pad, _fy + _rh * 0.5, "> " + keyboard_string + "_", _s);
} else if (filtering) {
    draw_set_color(col_edit);
    dtext(_px + _pad, _fy + _rh * 0.5, "filtro: " + keyboard_string + "_", _s);
} else if (msg_t > 0) {
    draw_set_color(col_accent);
    dtext(_px + _pad, _fy + _rh * 0.5, string_copy(msg, 1, _maxc), _s);
} else {
    draw_set_color(col_dim);
    var _hint = _deep ? "BACKSP atras   ENTER editar/entrar" : "TAB filtro   ENTER accion   SUPR borrar";
    if (filter != "") _hint = "[" + filter + "]   " + _hint;
    dtext(_px + _pad, _fy + _rh * 0.5, string_copy(_hint, 1, _maxc), _s);
}

draw_set_font(-1);
draw_set_color(c_white);
draw_set_alpha(1);