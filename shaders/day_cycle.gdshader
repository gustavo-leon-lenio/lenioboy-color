shader_type canvas_item;

// Tolerancia para la comparación de colores
uniform float COLOR_TOLERANCE: hint_range(0.05, 0.20, 0.01) = 0.05;  // Ajusta este valor según sea necesario
// Factor de mezcla entre las paletas
uniform float blend_factor : hint_range(0, 3) = 0.0;
// Define los colores originales de la paleta
uniform vec4 original_color1 : source_color = vec4(0.32, 0.67, 0.89,1);
uniform vec4 original_color2 : source_color = vec4(1,1,1,1);
uniform vec4 original_color3 : source_color = vec4(0.80, 0.51, 0.37, 1.0);
uniform vec4 original_color4 : source_color = vec4(0.58, 0.77, 0.39, 1.0);
uniform vec4 original_color5 : source_color = vec4(0.44, 0.67, 0.2, 1.0);
uniform vec4 original_color6 : source_color = vec4(0.71, 0.84, 0.24, 1.0);
uniform vec4 original_color7 : source_color = vec4(0.67, 0.38, 0.35, 1.0);

// Define los colores para la primera paleta
uniform vec4 palette1_color1 : source_color = vec4(0.93, 0.38, 0.34,1);
uniform vec4 palette1_color2 : source_color = vec4(0.90, 0.56, 0.02,1);
uniform vec4 palette1_color3 : source_color = vec4(0.77, 0.25, 0.53,1);
uniform vec4 palette1_color4 : source_color = vec4(0.21, 0.03, 0.41,1);
uniform vec4 palette1_color5 : source_color = vec4(0.47, 0.32, 0.59, 1.0);
uniform vec4 palette1_color6 : source_color = vec4(0.79, 0.24, 0.84, 1.0);
uniform vec4 palette1_color7 : source_color = vec4(0.43, 0.62, 0.49, 1);


// Define los colores para la segunda paleta
uniform vec4 palette2_color1 : source_color = vec4(0.0157, 0.0627, 0.1255,1);
uniform vec4 palette2_color2 : source_color = vec4(0.0745, 0.2863, 0.5922,1);
uniform vec4 palette2_color3 : source_color = vec4(0.0314, 0.0745, 0.1569,1);
uniform vec4 palette2_color4 : source_color = vec4(0, 0, 0,1);
uniform vec4 palette2_color5 : source_color = vec4(0.2, 0.53, 0.67, 1.0);
uniform vec4 palette2_color6 : source_color = vec4(0.51, 0.82, 0.81, 1.0);
uniform vec4 palette2_color7 : source_color = vec4(1, 1, 1, 1);


// Function to convert color to grayscale based on luminance
float color_to_grayscale(vec4 color) {
    return 0.299 * color.r + 0.587 * color.g + 0.114 * color.b;
}

// Function to check if colors are similar in terms of luminance
bool is_luminance_similar(vec4 color1, vec4 color2) {
    float gray1 = color_to_grayscale(color1);
    float gray2 = color_to_grayscale(color2);
    return abs(gray1 - gray2) < COLOR_TOLERANCE;
}

bool is_color_similar(vec4 color1, vec4 color2) {
   vec4 diff = abs(color1 - color2);
    return (diff.r < COLOR_TOLERANCE) && (diff.g < COLOR_TOLERANCE) && (diff.b < COLOR_TOLERANCE);
}

vec4 determine_palette_color(vec4 pixel_color, vec4 color1, vec4 color2, vec4 color3, vec4 color4, vec4 color5, vec4 color6, vec4 color7) {
    if (is_color_similar(pixel_color, color1)) {
        return color1;
    } else if (is_color_similar(pixel_color, color2)) {
        return color2;
    } else if (is_color_similar(pixel_color, color3)) {
        return color3;
    } else if (is_color_similar(pixel_color, color4)) {
        return color4;
    } else if (is_color_similar(pixel_color, color5)) {
        return color5;
    } else if (is_color_similar(pixel_color, color6)) {
        return color6;
    } else if (is_color_similar(pixel_color, color7)) {
        return color7;
    }
    return pixel_color;
}


void fragment() {
    vec4 pixel_color = vec4(texture(SCREEN_TEXTURE, SCREEN_UV));
    vec4 start_color = pixel_color;
    vec4 end_color = pixel_color;
    // Utiliza mod para hacer que blend_factor sea cíclico
    float cyclic_blend_factor = mod(blend_factor, 3.0);
    float local_blend = fract(cyclic_blend_factor);

    // Determinar si estamos en el límite entre dos paletas
	
    if (cyclic_blend_factor < 1.0) {
        // Transición de la Paleta Original a la Paleta 1
        start_color = determine_palette_color(pixel_color, original_color1, original_color2, original_color3, original_color4, original_color5, original_color6, original_color7);
        end_color = determine_palette_color(pixel_color, palette1_color1, palette1_color2, palette1_color3, palette1_color4, palette1_color5, palette1_color6, palette1_color7);
    } else if (cyclic_blend_factor < 2.0) {
        // Transición de la Paleta 1 a la Paleta 2
        start_color = determine_palette_color(pixel_color, palette1_color1, palette1_color2, palette1_color3, palette1_color4, palette1_color5, palette1_color6, palette1_color7);
        end_color = determine_palette_color(pixel_color, palette2_color1, palette2_color2, palette2_color3, palette2_color4, palette2_color5, palette2_color6, palette2_color7);
    } else {
        // Transición de la Paleta 2 de vuelta a la Paleta Original
        start_color = determine_palette_color(pixel_color, palette2_color1, palette2_color2, palette2_color3, palette2_color4, palette2_color5, palette2_color6, palette2_color7);
        end_color = determine_palette_color(pixel_color, original_color1, original_color2, original_color3, original_color4, original_color5, original_color6, original_color7);
    }

    COLOR = mix(start_color, end_color, local_blend);

    // Interpola entre las paletas seleccionadas
}
