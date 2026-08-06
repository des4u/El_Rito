if (instance_number(kiosco_controller) > 1) {
    instance_destroy();
    exit;
}
cards = [
    { titulo: "El Rito", sub: "" },
	{ titulo: "Capítulo 1", sub: "Cacería de Brujas" },
	{ titulo: "Escrito y Dirigido por:", sub: "Desau" },
];
card_actual   = 0;
duracion_card = 120;
global.kioscoevent = 0;
tiempo        = 0;

light_set_ambient(0.5, 0.5, 0.6);
obj_shader_controller.flicker_intensity = 0.5;
