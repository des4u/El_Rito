if (place_meeting(x, y, par_Character)) {
    target_alpha = 0.4; 
} else {

    target_alpha = 1.0; 
}

image_alpha = lerp(image_alpha, target_alpha, fade_speed);