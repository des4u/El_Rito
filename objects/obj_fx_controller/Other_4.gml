if (surface_exists(surf)) {
    surface_free(surf);
}
surf = surface_create(display_get_gui_width(), display_get_gui_height());