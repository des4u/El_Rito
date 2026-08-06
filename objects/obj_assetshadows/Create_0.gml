if (instance_number(obj_assetshadows) > 1) {
    instance_destroy();
    exit;
}
depth = 150;
casters = asset_shadows_scan();