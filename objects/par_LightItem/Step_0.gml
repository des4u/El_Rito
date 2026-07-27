// Gastar durabilidad
if (is_equipped) {
    durability -= drain_rate;
} else if (owner != noone) {
    durability -= drain_pickup;
}
durability = max(durability, 0);

// Parpadeo cuando esta por agotarse
if (durability < 0.15 && durability > 0) {
    is_flickering = true;
    // Parpadeo aleatorio
    if (my_light_id != -1) {
        var _flicker = choose(0.3, 0.6, 0.9, 0.5, 0.8);
        light_update(my_light_id, owner.x, owner.y,
            light_radius * _flicker,
            light_strength * _flicker,
            light_type,
            light_r, light_g, light_b);
    }
} else if (durability <= 0) {
    scr_light_extinguish(id);
}

// Mover la luz con el owner
if (is_equipped && my_light_id != -1 && instance_exists(owner)) {
    light_move(my_light_id, owner.x, owner.y);
}