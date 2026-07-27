frame_luna     = 0;
velocidad      = 0.2;
boton_iniciar  = noone;
menu_opciones  = ["INICIAR"];
menu_seleccion = 0;
cards = [
    { titulo: "Una producción de", sub: "WARBART studios" },
    { titulo: "EL RITO",           sub: "la carroñera" },
];
card_actual   = 0;
duracion_card = 180;
fase          = 0;
tiempo        = 0;
duracion_cine = 120;
hold_espacio = 0;
hold_max     = 45;

vhs_perspective_apply();
light_set_ambient(0.5, 0.5, 0.6, true);
obj_shader_controller.flicker_intensity = 0.5;