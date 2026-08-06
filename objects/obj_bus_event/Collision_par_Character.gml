if (!armed) exit;
if (other.id != global.controlled) exit;
if (global.kioscoevent == 14.5) { armed = false; global.kioscoevent = 15.5; exit; }
if (global.kioscoevent == 15)   { armed = false; global.kioscoevent = 16; }