if (instance_number(obj_CameraManager) > 1) {
    instance_destroy();
    exit;
}

global.cam_locked    = false;
global.cam_target_x  = 0;
global.cam_target_y  = 0;