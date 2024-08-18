shader_type canvas_item;


uniform sampler2D palette_texture; // Texture containing all palettes
uniform int source_palette;        // Index of the source palette
uniform int target_palette;        // Index of the target palette          // Index of the active swap palette
uniform float tolerance: hint_range(0.0, 1.0) = 0.1;
uniform float interp_factor: hint_range(0.0, 1.0); // Interpolation factor between 0 and 1


vec3 rgb2hsv(vec3 c) {
    vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
    vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
    vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));

    float d = q.x - min(q.w, q.y);
    float e = 1.0e-10;
    return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}

vec3 hsv2rgb(vec3 c) {
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

//void fragment() {
//    vec4 original_tex = texture(SCREEN_TEXTURE, SCREEN_UV);
//    vec3 source_hsv = rgb2hsv(original_tex.rgb);
//
//    float source_row_center = (float(source_palette) * 16.0 + 8.0) / 48.0;
//    float target_row_center = (float(target_palette) * 16.0 + 8.0) / 48.0;
//
//    vec4 final_color = original_tex; // Start with the original texture color
//
//    for (int i = 0; i < 7; ++i) {
//        float color_column_center = (float(i) * 16.0 + 8.0) / 112.0;
//        vec2 source_uv = vec2(color_column_center, source_row_center);
//        vec2 target_uv = vec2(color_column_center, target_row_center);
//
//        vec4 source_palette_color = texture(palette_texture, source_uv);
//        vec4 target_palette_color = texture(palette_texture, target_uv);
//
//        vec3 source_palette_color_hsv = rgb2hsv(source_palette_color.rgb);
//
//        // Check if the current pixel color is close to the palette color
//        if (abs(source_hsv.r - source_palette_color_hsv.r) <= tolerance && abs(source_hsv.g - source_palette_color_hsv.g) <= tolerance) {
//            vec3 target_palette_color_hsv = rgb2hsv(target_palette_color.rgb);
//            vec3 interpolated_hsv = mix(source_palette_color_hsv, target_palette_color_hsv, interp_factor);
//            final_color.rgb = hsv2rgb(interpolated_hsv);
//            break; // Color matched, no need to check further
//        }
//    }
//
//    COLOR = final_color;
//}

void fragment() {
    vec4 tex = texture(SCREEN_TEXTURE, SCREEN_UV);
    vec3 source_hsv = rgb2hsv(tex.rgb);

    // Compute the centers of the source and target palettes
    float source_row_center = (float(source_palette) * 16.0 + 8.0) / 48.0;
    float target_row_center = (float(target_palette) * 16.0 + 8.0) / 48.0;

    vec4 final_color = tex; // Start with the original texture color

    for (int i = 0; i < 7; ++i) {
        float color_column_center = (float(i) * 16.0 + 8.0) / 112.0;
        vec2 source_uv = vec2(color_column_center, source_row_center);
        vec2 target_uv = vec2(color_column_center, target_row_center);

        vec4 source_palette_color = texture(palette_texture, source_uv);
        vec4 target_palette_color = texture(palette_texture, target_uv);

        vec3 source_palette_color_hsv = rgb2hsv(source_palette_color.rgb);
        vec3 target_palette_color_hsv = rgb2hsv(target_palette_color.rgb);

        // Match based on both hue and saturation
        if (abs(source_hsv.r - source_palette_color_hsv.r) <= tolerance && abs(source_hsv.g - source_palette_color_hsv.g) <= tolerance) {
            vec3 interpolated_hsv = mix(source_palette_color_hsv, target_palette_color_hsv, interp_factor);
            final_color.rgb = hsv2rgb(interpolated_hsv);
            break; // Found a matching color, no need to check further
        }
    }

    COLOR = final_color;
}
