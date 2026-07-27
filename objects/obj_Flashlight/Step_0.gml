// Heredar durabilidad y parpadeo del parent
event_inherited();

// Solo mover hacia el mouse si es del personaje controlado
if (instance_exists(owner) && owner == global.controlled) {
    // Convertir mouse a coordenadas del mundo
    aim_x = mouse_x;
    aim_y = mouse_y;
} else if (instance_exists(owner)) {
    // Los companions apuntan en su dirección de movimiento
    aim_x = owner.x + owner.input_x * 50;
    aim_y = owner.y + owner.input_y * 50;
}

// Mover la luz al punto de aim
if (my_light_id != -1 && instance_exists(owner)) {
    light_move(my_light_id, aim_x, aim_y);
}


if (instance_exists(owner) && owner == global.controlled) {
    aim_x = mouse_x;
    aim_y = mouse_y;
} else if (instance_exists(owner)) {
    // Suavizar el movimiento de la linterna — no teleporta
    aim_x = lerp(aim_x, owner.ai_look_x, 0.05);
    aim_y = lerp(aim_y, owner.ai_look_y, 0.05);
}