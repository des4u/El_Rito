// Tipo: "candle", "lantern", "flashlight"
light_type    = "candle";
durability    = 1.0;      // 1.0 = 100%, 0.0 = apagado
drain_rate    = 0.0002;   // cuanto se gasta por step encendido
drain_pickup  = 0.00005;  // cuanto se gasta por step aunque este guardado
is_equipped   = false;
is_flickering = false;

// Parametros de luz (cada hijo los sobreescribe)
light_radius  = 80;
light_strength = 0.9;
light_r = 0.9; light_g = 0.75; light_b = 0.4;

owner = noone; // el par_Character que lo lleva
my_light_id = -1; //alch el my_light es un meme JAJAJA