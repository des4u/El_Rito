// Solo si no tiene dueño y el clic cayó sobre este objeto
if (owner == noone && position_meeting(mouse_x, mouse_y, id)) {
    var _char = global.controlled;
    if (!instance_exists(_char)) exit;

    owner = _char;
    ds_list_add(_char.inventory, id);
    visible = false; // desaparece del mundo

    // Auto equipar si no tiene luz
    if (!_char.has_light) {
        scr_light_equip(_char, id);
    }
}