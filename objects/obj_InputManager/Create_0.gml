if (instance_number(obj_InputManager) > 1) {
    instance_destroy();
    exit;
}
global.switch_cd = 0;
global.switching = false;

