if (!position_meeting(mouse_x, mouse_y, id)) exit;
if (global.inv_open) exit;

if (stash_add_type(item_type)) {
    instance_destroy();
} else {
    tooltip("La mochila esta llena", 2);
}