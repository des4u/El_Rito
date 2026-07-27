if (instance_number(obj_inventory) > 1) {
    instance_destroy();
    exit;
}

persistent = true;
depth      = -10000.5;

drag_item = undefined;
drag_from = "";
drag_key  = "";

font_title = fnt_vhs_sub;
font_body  = fnt_dialog;