if (!dialog_active) exit;
var _dt = delta_time / 1000000;
if (cur_is_tooltip) {
    tw_displayed = tw_text;
    tw_finished  = true;
    tt_life     += _dt;

    if (cur_timer > 0) {
        tt_alpha = clamp(min(tt_life / tooltip_fade, (cur_timer - tt_life) / tooltip_fade), 0, 1);
        if (tt_life >= cur_timer) { dialog_next(); exit; }
    } else {
        tt_alpha = clamp(tt_life / tooltip_fade, 0, 1);
        if (keyboard_check_pressed(vk_space) || keyboard_check_pressed(vk_enter)) {
            dialog_next();
            exit;
        }
    }
    exit;
}
var _max_len = cur_is_double ? max(string_length(tw_text), string_length(tw_text2)) : string_length(tw_text);

if (!tw_finished) {
    tw_timer += _dt;
    while (tw_timer >= tw_speed && !tw_finished) {
        tw_timer -= tw_speed;
        tw_index++;
        tw_displayed = string_copy(tw_text, 1, tw_index);
        if (cur_is_double) tw_displayed2 = string_copy(tw_text2, 1, tw_index);

        if (tw_index >= _max_len) {
            tw_finished = true;
            tw_displayed = tw_text;
            if (cur_is_double) tw_displayed2 = tw_text2;
        } else {
            var _c = string_char_at(tw_text, tw_index);
            if (cur_is_double && tw_index <= string_length(tw_text2)) {
                var _c2 = string_char_at(tw_text2, tw_index);
                if ((_c != " " && _c != "," && _c != ".") || (_c2 != " " && _c2 != "," && _c2 != ".")) {
                    audio_play_sound(snd_dialog, 10, false);
                }
            } else if (_c != " " && _c != "," && _c != ".") {
                audio_play_sound(snd_dialog, 10, false);
            }
        }
    }
}

if (tw_finished && cur_timer > 0 && array_length(cur_choices) == 0) {
    auto_timer += _dt;
    if (auto_timer >= cur_timer) {
        dialog_next();
        exit;
    }
}

var _confirm = keyboard_check_pressed(vk_space) || keyboard_check_pressed(vk_enter);

if (_confirm && !cur_obligatory) {
    if (!tw_finished) {
        tw_index = _max_len;
        tw_displayed = tw_text;
        if (cur_is_double) tw_displayed2 = tw_text2;
        tw_finished = true;
    } else if (cur_timer < 0) {
        if (array_length(cur_choices) > 0) choice_result = choice_index;
        dialog_next();
        exit;
    }
}

if (tw_finished && array_length(cur_choices) > 0) {
    if (keyboard_check_pressed(vk_up))   choice_index = max(0, choice_index - 1);
    if (keyboard_check_pressed(vk_down)) choice_index = min(array_length(cur_choices) - 1, choice_index + 1);
}