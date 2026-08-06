function _dialog_load_line(_index) {
    with (obj_dialogue_controller) {
        var _line       = dialog_lines[_index];
		cur_side = _line.side ?? "left";
        cur_is_double   = _line.is_double ?? false;
        tw_text         = _line.text;
        tw_text2        = cur_is_double ? (_line.text2 ?? "") : "";
        tw_displayed    = "";
        tw_displayed2   = "";
        tw_index        = 0;
        tw_timer        = 0;
        tw_finished     = false;
        cur_name        = _line.name        ?? "";
        cur_portrait    = _line.portrait    ?? -1;
        cur_portrait_fr = _line.portrait_fr ?? 0;
        cur_is_tooltip = _line.is_tooltip ?? false;
		tt_life        = 0;
		tt_alpha       = 0;
        if (cur_is_double) {
            cur_name2        = _line.name2        ?? "";
            cur_portrait2    = _line.portrait2    ?? -1;
            cur_portrait_fr2 = _line.portrait_fr2 ?? 0;
        }
        
        cur_choices     = _line.choices     ?? [];
        cur_timer       = _line.timer       ?? -1;
        cur_obligatory  = _line.obligatory  ?? false;
        choice_index    = 0;
        choice_result   = -1;
        auto_timer      = 0;
    }
}

// ─────────────────────────────────────────
// Avanza al siguiente dialogo
// ─────────────────────────────────────────
function dialog_next() {
    with (obj_dialogue_controller) {
        dialog_index++;
        if (dialog_index >= array_length(dialog_lines)) {
            dialog_active = false;
            dialog_done   = true;
        } else {
            _dialog_load_line(dialog_index);
        }
    }
}


function dialog_start(_lines) {
    with (obj_dialogue_controller) {
        dialog_lines  = _lines;
        dialog_index  = 0;
        dialog_active = true;
        dialog_done   = false;
        dialog_free   = false;
        _dialog_load_line(0);
    }
}

function dialog_start_free(_lines) {
    dialog_start(_lines);
    with (obj_dialogue_controller) { dialog_free = true; }
}

// ─────────────────────────────────────────
// Crear una linea de dialogo
// ─────────────────────────────────────────
function dialog_line(_text, _name, _portrait, _portrait_fr) {
    return {
        is_double  : false,
        is_tooltip : false,
        text       : _text,
        name       : _name,
        portrait   : _portrait,
        portrait_fr: _portrait_fr,
        choices    : [],
        timer      : -1,
        obligatory : false,
        side       : "left"
    };
}
function dialog_line_right(_text, _name, _portrait, _portrait_fr) {
    var _l  = dialog_line(_text, _name, _portrait, _portrait_fr);
    _l.side = "right";
    return _l;
}
// Linea con timer automatico
function dialog_line_timed(_text, _name, _portrait, _portrait_fr, _seconds) {
    var _l         = dialog_line(_text, _name, _portrait, _portrait_fr);
    _l.timer       = _seconds;
    _l.obligatory  = true;
    return _l;
}

// Linea con elecciones
function dialog_line_choices(_text, _name, _portrait, _portrait_fr, _choices) {
    var _l     = dialog_line(_text, _name, _portrait, _portrait_fr);
    _l.choices = _choices;
    return _l;
}

// ─────────────────────────────────────────
// Saber si termino el dialogo
// ─────────────────────────────────────────
function dialog_is_done() {
    return obj_dialogue_controller.dialog_done;
}

// Resultado de la eleccion (0, 1, 2...)
function dialog_choice_result() {
    return obj_dialogue_controller.choice_result;
}

// ─────────────────────────────────────────
// Dobles dialogos
// ─────────────────────────────────────────
function double_dialogue(_text1, _name1, _portrait1, _portrait_fr1, _text2, _name2, _portrait2, _portrait_fr2) {
    return {
        is_double  : true,
        is_tooltip : false,
        text       : _text1,
        name       : _name1,
        portrait   : _portrait1,
        portrait_fr: _portrait_fr1,
        text2      : _text2,
        name2      : _name2,
        portrait2  : _portrait2,
        portrait_fr2: _portrait_fr2,
        choices    : [],
        timer      : -1,
        obligatory : false,
        side       : "both"
    };
}
function double_dialogue_timed(_text1, _name1, _portrait1, _portrait_fr1, _text2, _name2, _portrait2, _portrait_fr2, _seconds) {
    var _l = double_dialogue(_text1, _name1, _portrait1, _portrait_fr1, _text2, _name2, _portrait2, _portrait_fr2);
    _l.timer = _seconds;
    _l.obligatory = true;
    return _l;
}

function dialog_tooltip(_text, _seconds = 3) {
    return {
        is_double  : false,
        is_tooltip : true,
        text       : _text,
        name       : "",
        portrait   : -1,
        portrait_fr: 0,
        choices    : [],
        timer      : _seconds,
        obligatory : true,
        side       : "left"
    };
}

function dialog_tooltip_wait(_text) {
    var _l = dialog_tooltip(_text, -1);
    _l.obligatory = false;
    return _l;
}

function tooltip(_text, _seconds = 3) {
    dialog_start([ dialog_tooltip(_text, _seconds) ]);
}

function dialog_blocks_input() {
    if (!obj_dialogue_controller.dialog_active) return false;
    if (obj_dialogue_controller.dialog_free) return false;
    return !obj_dialogue_controller.cur_is_tooltip;
}

