// Solo guardar si no se guardó ya desde door_goto
if (!global.inventory_saved) {
    scr_inventory_save();
}
global.inventory_saved = false; // resetear para el siguiente room