function scr_party_set_active(char_instance) {
    // Desactivar al anterior
    if (instance_exists(global.controlled)) {
        global.controlled.is_active = false;
    }
    // Activar el nuevo
    global.controlled = char_instance;
    if (instance_exists(global.controlled)) {
        global.controlled.is_active = true;
    }
}


function scr_ai_update(char) {
    if (!instance_exists(global.controlled)) exit;
    var _leader   = global.controlled;
    var _dist     = point_distance(char.x, char.y, _leader.x, _leader.y);
    var _darkness = scr_get_darkness();
    var _is_dark  = _darkness < 0.25;
    var _it = char_item_get(char.char_name);
	var _has_light = !is_undefined(_it) && _it.lit;

    // ── INIT VARS DE IA (si no existen) ────────────
    if (!variable_instance_exists(char, "ai_move_axis"))     char.ai_move_axis = 0;
    if (!variable_instance_exists(char, "ai_look_target_x")) char.ai_look_target_x = char.x;
    if (!variable_instance_exists(char, "ai_look_target_y")) char.ai_look_target_y = char.y;
    if (!variable_instance_exists(char, "ai_react_delay"))   char.ai_react_delay = 0;
    if (!variable_instance_exists(char, "ai_follow_tx"))     char.ai_follow_tx = char.x;
    if (!variable_instance_exists(char, "ai_follow_ty"))     char.ai_follow_ty = char.y;
    if (!variable_instance_exists(char, "ai_follow_set"))    char.ai_follow_set = false;

    // ── LIMITE DE CAMARA ───────────────────────────
    // Si se está saliendo, forzar follow sin importar stance
    if (!scr_in_camera(char)) {
        scr_ai_move_toward(char, _leader.x, _leader.y, char.ai_speed * 1.2);
        scr_ai_update_look(char);
        exit;
    }

    // ── DISTANCIA SEGUN STANCE ──────────────────────
    // timid: pegado al líder/NPC, brave: lejos, curious: medio
    var _stance_dist = 28;
    switch (char.ai_stance) {
        case "timid":   _stance_dist = 40;  break;
        case "curious": _stance_dist = 60;  break;
        case "brave":   _stance_dist = 100;  break;
    }

    // ── OSCURIDAD + STANCE ─────────────────────────
    var _can_wander = true;
    if (_is_dark && !_has_light) {
        switch (char.ai_stance) {
            case "timid":  _can_wander = false; break; // se paraliza sin luz
            case "curious": _can_wander = irandom(1) == 0; break; // duda
            case "brave":  _can_wander = true;  break; // se arriesga
        }
    }
    // Si tiene luz, siempre puede wandear (incluso timid)
    if (_has_light) _can_wander = true;

    // ── TIMER DE QUIETUD DEL JUGADOR ──────────────
    // Detectar si el jugador lleva 2 seg quieto (50 steps a 25fps)
    if (!variable_global_exists("player_idle_timer")) global.player_idle_timer = 0;
    if (abs(_leader.input_x) + abs(_leader.input_y) == 0) {
        global.player_idle_timer++;
    } else {
        global.player_idle_timer = 0;
    }
    var _player_idle = global.player_idle_timer > 50;

    // ── SEPARACION DE OTROS PERSONAJES ─────────────
    scr_ai_separate(char);

    // ── DECIDIR ESTADO ─────────────────────────────
    // Delay de reacción: no siguen al jugador al instante
    if (char.ai_react_delay > 0) {
        char.ai_react_delay--;
    }

    switch (char.ai_stance) {

        case "timid":
            if (_dist > char.ai_follow_dist && char.ai_state != "follow") {
                // Iniciar delay de reacción (1-2 seg para timid, reacciona rápido por miedo)
                if (char.ai_react_delay <= 0) {
                    char.ai_react_delay = irandom_range(25, 50);
                }
                if (char.ai_react_delay <= 1) {
                    char.ai_state = "follow";
                    char.ai_follow_set = false;
                }
            } else if (_dist > char.ai_follow_dist && char.ai_state == "follow") {
                // Ya está siguiendo, mantener
            } else if (_dist < _stance_dist && char.ai_state == "follow") {
                char.ai_state = "idle";
            } else if (_is_dark && !_has_light) {
                char.ai_state = "idle";
            } else if (_player_idle && _can_wander && char.ai_wander_pause <= 0 && char.ai_wander_timer <= 0) {
                if (irandom(40) < 2) char.ai_state = "wander";
            } else if (char.ai_state != "follow" && char.ai_state != "wander") {
                char.ai_state = "idle";
            }
        break;

        case "brave":
            if (_dist > char.ai_follow_dist && char.ai_state != "follow") {
                // Delay largo — al brave no le urge (2-3 seg)
                if (char.ai_react_delay <= 0) {
                    char.ai_react_delay = irandom_range(50, 75);
                }
                if (char.ai_react_delay <= 1) {
                    char.ai_state = "follow";
                    char.ai_follow_set = false;
                }
            } else if (_dist > char.ai_follow_dist && char.ai_state == "follow") {
                // Ya está siguiendo
            } else if (_dist < _stance_dist && char.ai_state == "follow") {
                char.ai_state = "idle";
            } else if (_player_idle && _can_wander && char.ai_wander_pause <= 0 && char.ai_wander_timer <= 0) {
                char.ai_state = "wander";
            }
        break;

        case "curious":
            if (_dist > char.ai_follow_dist && char.ai_state != "follow") {
                // Delay medio (1.5-2.5 seg)
                if (char.ai_react_delay <= 0) {
                    char.ai_react_delay = irandom_range(35, 62);
                }
                if (char.ai_react_delay <= 1) {
                    char.ai_state = "follow";
                    char.ai_follow_set = false;
                }
            } else if (_dist > char.ai_follow_dist && char.ai_state == "follow") {
                // Ya está siguiendo
            } else if (_dist < _stance_dist && char.ai_state == "follow") {
                char.ai_state = "idle";
            } else if (_player_idle && _can_wander && char.ai_wander_pause <= 0 && char.ai_wander_timer <= 0) {
                if (irandom(40) < 3) {
                    char.ai_state = "wander";
                }
            }
        break;
    }

    // ── EJECUTAR ESTADO ────────────────────────────
    switch (char.ai_state) {

        case "follow":
            // Generar destino random cerca del líder (solo una vez por follow)
            if (!char.ai_follow_set) {
                var _cam2 = view_camera[0];
                var _fcx  = camera_get_view_x(_cam2);
                var _fcy  = camera_get_view_y(_cam2);
                var _fcw  = camera_get_view_width(_cam2);
                var _fch  = camera_get_view_height(_cam2);

                // Posición random a _stance_dist del líder, en dirección aleatoria
                var _fangle = random(360);
                var _fdist  = _stance_dist * (0.5 + random(0.8));
                char.ai_follow_tx = _leader.x + lengthdir_x(_fdist, _fangle);
                char.ai_follow_ty = _leader.y + lengthdir_y(_fdist, _fangle);

                // Clamp dentro de la cámara
                char.ai_follow_tx = clamp(char.ai_follow_tx, _fcx + 24, _fcx + _fcw - 24);
                char.ai_follow_ty = clamp(char.ai_follow_ty, _fcy + 24, _fcy + _fch - 24);
                char.ai_follow_set = true;
            }

            var _fd = point_distance(char.x, char.y, char.ai_follow_tx, char.ai_follow_ty);
            if (_fd > 8) {
                scr_ai_move_toward(char, char.ai_follow_tx, char.ai_follow_ty, char.ai_speed);
            } else {
                char.ai_state = "idle";
                char.ai_follow_set = false;
                char.input_x = 0;
                char.input_y = 0;
            }
        break;

        case "wander":
            if (char.ai_wander_timer <= 0) {
                // Destino dentro de la cámara, snap a grilla de 24px
                var _cam = view_camera[0];
                var _cx  = camera_get_view_x(_cam);
                var _cy  = camera_get_view_y(_cam);
                var _cw  = camera_get_view_width(_cam);
                var _ch  = camera_get_view_height(_cam);
                var _margin = 48;
                var _grid   = 24;

                // Punto random en toda la cámara (usa todo el espacio)
                var _wander_sep = 20; // solo evitar solapamiento directo
                var _best_x = 0, _best_y = 0;
                for (var _try = 0; _try < 5; _try++) {
                    var _rx = _cx + _margin + irandom(_cw - _margin * 2);
                    var _ry = _cy + _margin + irandom(_ch - _margin * 2);
                    _best_x = round(_rx / _grid) * _grid;
                    _best_y = round(_ry / _grid) * _grid;

                    // Solo evitar que el destino caiga ENCIMA de otro personaje
                    var _too_close = false;
                    with (par_Character) {
                        if (id != char.id && point_distance(x, y, _best_x, _best_y) < _wander_sep) {
                            _too_close = true;
                            break;
                        }
                    }
                    if (!_too_close) break;
                }
                char.ai_wander_x     = _best_x;
                char.ai_wander_y     = _best_y;
                char.ai_wander_timer = irandom_range(50, 120);
            }
            char.ai_wander_timer--;

            var _wd = point_distance(char.x, char.y, char.ai_wander_x, char.ai_wander_y);
            if (_wd > 8) {
                scr_ai_move_toward(char, char.ai_wander_x, char.ai_wander_y, char.ai_speed * 0.7);
            } else {
                char.ai_state        = "idle";
                char.ai_wander_pause = irandom_range(25, 75);
                char.ai_wander_timer = 0;
            }
        break;

        case "idle":
            char.input_x = 0;
            char.input_y = 0;
            if (char.ai_wander_pause > 0) {
                char.ai_wander_pause--;
            }
            // Cuando termina la pausa, quedar listo para otro stroll
            // El trigger lo maneja el switch de stance arriba
        break;
    }

    scr_ai_update_look(char);
}

/// @desc Empuja al NPC lejos de otros par_Character según su stance
function scr_ai_separate(char) {
    // Distancia de separación según stance
    var _sep_dist = 24;
    switch (char.ai_stance) {
        case "timid":   _sep_dist = 26; break; // se pega pero no se solapa
        case "curious": _sep_dist = 40; break;
        case "brave":   _sep_dist = 56; break;
    }

    var _push_x = 0;
    var _push_y = 0;

    with (par_Character) {
        if (id != char.id) {
            var _d = point_distance(x, y, char.x, char.y);
            if (_d < _sep_dist && _d > 1) {
                var _str = (_sep_dist - _d) / _sep_dist;
                var _dir = point_direction(x, y, char.x, char.y);
                _push_x += lengthdir_x(_str * 2, _dir);
                _push_y += lengthdir_y(_str * 2, _dir);
            }
        }
    }

    // Aplicar empuje solo en el eje dominante (sin diagonal)
    if (abs(_push_x) > 0.5 || abs(_push_y) > 0.5) {
        if (abs(_push_x) >= abs(_push_y)) {
            var _nx = char.x + sign(_push_x);
            if (!place_meeting(_nx, char.y, obj_Collision)) {
                char.x = _nx;
            }
        } else {
            var _ny = char.y + sign(_push_y);
            if (!place_meeting(char.x, _ny, obj_Collision)) {
                char.y = _ny;
            }
        }
    }
}

function scr_ai_move_toward(char, tx, ty, spd) {
    // Micro pausa natural entre pasos
    if (char.ai_step_pause > 0) {
        char.ai_step_pause--;
        char.input_x = 0;
        char.input_y = 0;
        exit;
    }

    // Variación de velocidad — actualiza cada cierto tiempo
    if (char.ai_speed_var == 0 || irandom(30) == 0) {
        char.ai_speed_var = spd * (0.85 + random(0.3)); // 85% a 115% de la velocidad
    }

    var _dx = tx - char.x;
    var _dy = ty - char.y;
    var _threshold = char.ai_speed_var + 1;

    // ── MOVIMIENTO EN UN SOLO EJE (sin diagonal) ──
    // Se compromete a un eje hasta completarlo para evitar zigzag
    if (char.ai_move_axis == 0) {
        // Eje X primero
        if (abs(_dx) > _threshold) {
            char.input_x = sign(_dx);
            char.input_y = 0;
        } else {
            // X satisfecho → cambiar a Y
            char.ai_move_axis = 1;
            char.input_x = 0;
            char.input_y = (abs(_dy) > _threshold) ? sign(_dy) : 0;
        }
    } else {
        // Eje Y primero
        if (abs(_dy) > _threshold) {
            char.input_x = 0;
            char.input_y = sign(_dy);
        } else {
            // Y satisfecho → cambiar a X
            char.ai_move_axis = 0;
            char.input_y = 0;
            char.input_x = (abs(_dx) > _threshold) ? sign(_dx) : 0;
        }
    }

    // ── COLISION CON PAREDES ───────────────────────
    var _mx = char.input_x * char.ai_speed_var;
    var _my = char.input_y * char.ai_speed_var;

    if (place_meeting(char.x + _mx, char.y + _my, obj_Collision)) {
        // Pared adelante: intentar el otro eje
        if (char.input_x != 0 && abs(_dy) > 2) {
            char.ai_move_axis = 1;
            char.input_x = 0;
            char.input_y = sign(_dy);
            _mx = 0;
            _my = char.input_y * char.ai_speed_var;
            if (place_meeting(char.x, char.y + _my, obj_Collision)) {
                char.input_y = 0;
                _mx = 0; _my = 0;
            }
        } else if (char.input_y != 0 && abs(_dx) > 2) {
            char.ai_move_axis = 0;
            char.input_y = 0;
            char.input_x = sign(_dx);
            _mx = char.input_x * char.ai_speed_var;
            _my = 0;
            if (place_meeting(char.x + _mx, char.y, obj_Collision)) {
                char.input_x = 0;
                _mx = 0; _my = 0;
            }
        } else {
            char.input_x = 0;
            char.input_y = 0;
            _mx = 0; _my = 0;
        }
    }

    // ── COLISION CON OTROS PERSONAJES (par_Character) ──
    if (_mx != 0 || _my != 0) {
        var _fx = char.x + _mx;
        var _fy = char.y + _my;
        var _hit_char = false;

        with (par_Character) {
            if (id != char.id && point_distance(_fx, _fy, x, y) < 20) {
                _hit_char = true;
                break;
            }
        }

        if (_hit_char) {
            var _alt_blocked = true;
            // Intentar el otro eje
            if (_mx != 0 && abs(_dy) > 2) {
                char.ai_move_axis = 1;
                char.input_x = 0;
                char.input_y = sign(_dy);
                var _test_my = char.input_y * char.ai_speed_var;
                var _test_fy = char.y + _test_my;
                var _test_ok = !place_meeting(char.x, _test_fy, obj_Collision);
                if (_test_ok) {
                    with (par_Character) {
                        if (id != char.id && point_distance(char.x, _test_fy, x, y) < 20) {
                            _test_ok = false;
                            break;
                        }
                    }
                }
                if (_test_ok) {
                    _mx = 0;
                    _my = _test_my;
                    _alt_blocked = false;
                }
            } else if (_my != 0 && abs(_dx) > 2) {
                char.ai_move_axis = 0;
                char.input_y = 0;
                char.input_x = sign(_dx);
                var _test_mx = char.input_x * char.ai_speed_var;
                var _test_fx = char.x + _test_mx;
                var _test_ok2 = !place_meeting(_test_fx, char.y, obj_Collision);
                if (_test_ok2) {
                    with (par_Character) {
                        if (id != char.id && point_distance(_test_fx, char.y, x, y) < 20) {
                            _test_ok2 = false;
                            break;
                        }
                    }
                }
                if (_test_ok2) {
                    _mx = _test_mx;
                    _my = 0;
                    _alt_blocked = false;
                }
            }

            if (_alt_blocked) {
                char.input_x = 0;
                char.input_y = 0;
                _mx = 0; _my = 0;
            }
        }
    }

    // ── APLICAR MOVIMIENTO ─────────────────────────
    char.x += _mx;
    char.y += _my;

    // Micro pausa aleatoria — se siente como que "titubea"
    if (irandom(60) == 0) {
        char.ai_step_pause = irandom_range(4, 12);
    }
}

function scr_in_camera(char) {
    var _cam  = view_camera[0];
    var _cx   = camera_get_view_x(_cam);
    var _cy   = camera_get_view_y(_cam);
    var _cw   = camera_get_view_width(_cam);
    var _ch   = camera_get_view_height(_cam);
    var _margin = 32; // margen de tolerancia

    return (char.x > _cx - _margin && char.x < _cx + _cw + _margin
         && char.y > _cy - _margin && char.y < _cy + _ch + _margin);
}

function scr_ai_update_look(char) {
    char.ai_look_timer--;

    if (char.ai_look_timer <= 0) {
        // ── ELEGIR NUEVO DESTINO DE MIRADA ─────────
        var _cam = view_camera[0];
        var _cx  = camera_get_view_x(_cam);
        var _cy  = camera_get_view_y(_cam);
        var _cw  = camera_get_view_width(_cam);
        var _ch  = camera_get_view_height(_cam);

        switch (char.ai_state) {
            case "follow":
                // Mira hacia la dirección de movimiento, más lejos
                var _look_dist = 160;
                char.ai_look_target_x = char.x + char.input_x * _look_dist + irandom_range(-30, 30);
                char.ai_look_target_y = char.y + char.input_y * _look_dist + irandom_range(-30, 30);
            break;
            case "wander":
                // Mira hacia el destino del wander con variación
                char.ai_look_target_x = char.ai_wander_x + irandom_range(-40, 40);
                char.ai_look_target_y = char.ai_wander_y + irandom_range(-40, 40);
            break;
            case "idle":
                // Barrido amplio dentro de la cámara, como explorar con linterna
                var _roll = irandom(10);
                if (_roll < 3) {
                    // Mirar al jugador
                    char.ai_look_target_x = global.controlled.x + irandom_range(-20, 20);
                    char.ai_look_target_y = global.controlled.y + irandom_range(-20, 20);
                } else if (_roll < 7) {
                    // Mirar a un punto lejano dentro de la cámara
                    char.ai_look_target_x = _cx + 40 + irandom(_cw - 80);
                    char.ai_look_target_y = _cy + 40 + irandom(_ch - 80);
                } else {
                    // Mirar a algo cercano pero no pegado
                    var _angle = random(360);
                    var _r = 60 + irandom(120);
                    char.ai_look_target_x = char.x + lengthdir_x(_r, _angle);
                    char.ai_look_target_y = char.y + lengthdir_y(_r, _angle);
                }
            break;
        }

        // Clamp dentro de la cámara
        char.ai_look_target_x = clamp(char.ai_look_target_x, _cx + 16, _cx + _cw - 16);
        char.ai_look_target_y = clamp(char.ai_look_target_y, _cy + 16, _cy + _ch - 16);

        // Actualizar cada cierto tiempo random — se siente natural
        char.ai_look_timer = irandom_range(15, 50);
    }

    var _lerp_spd = 0.08;
    char.ai_look_x = lerp(char.ai_look_x, char.ai_look_target_x, _lerp_spd);
    char.ai_look_y = lerp(char.ai_look_y, char.ai_look_target_y, _lerp_spd);
}


