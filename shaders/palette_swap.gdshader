// https://godotshaders.com/shader/color-swap-with-hue-variation-preservation
shader_type canvas_item;

// How to use:
// 1) Store the initial color in `from`
// 2) Store the target color in `to`
// 3) Adjust tolerance to grab a range of hues or set to 0 for exact match
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_nearest;
//uniform vec4 from : source_color;
//uniform vec4 to : source_color;
uniform float tolerance: hint_range(0.0, 1.0);

uniform vec4 from_color1 : source_color = vec4(0.318, 0.671, 0.886,1);
uniform vec4 from_color2 : source_color = vec4(1,1,1,1);
uniform vec4 from_color3 : source_color = vec4(0.80, 0.51, 0.37, 1.0);
uniform vec4 from_color4 : source_color = vec4(0.714, 0.835, 0.235, 1.0);
uniform vec4 from_color5 : source_color = vec4(0.443, 0.667, 0.204, 1.0);
uniform vec4 from_color6 : source_color = vec4(0.71, 0.84, 0.24, 1.0);
uniform vec4 from_color7 : source_color = vec4(0.67, 0.38, 0.35, 1.0);

// Define los colores para la primera paleta
//uniform vec4 to_color1 : source_color = vec4(0.021, 0.071, 0.074,1); //Night
//uniform vec4 to_color2 : source_color = vec4(0.721, 0.931, 1,1); // Night
//uniform vec4 to_color3 : source_color = vec4(0.292, 0.208, 0.294,1); // Night
//uniform vec4 to_color4 : source_color = vec4(0.777, 0.693, 0.995,1); // Night
//uniform vec4 to_color5 : source_color = vec4(0.071, 0.032, 0.101, 1.0); // Night
uniform vec4 to_color1 : source_color = vec4(0.318, 0.671, 0.886,1);
uniform vec4 to_color2 : source_color = vec4(1,1,1,1);
uniform vec4 to_color3 : source_color = vec4(0.80, 0.51, 0.37, 1.0);
uniform vec4 to_color4 : source_color = vec4(0.714, 0.835, 0.235, 1.0);
uniform vec4 to_color5 : source_color = vec4(0.443, 0.667, 0.204, 1.0);
uniform vec4 to_color6 : source_color = vec4(0.79, 0.24, 0.84, 1.0);
uniform vec4 to_color7 : source_color = vec4(0.43, 0.62, 0.49, 1);



// Color space conversion from https://godotshaders.com/shader/color-range-swap/
vec3 rgb2hsv(vec3 c)
{
    vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
    vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
    vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));

    float d = q.x - min(q.w, q.y);
    float e = 1.0e-10;
    return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}

// All components are in the range [0…1], including hue.
vec3 hsv2rgb(vec3 c)
{
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}


void fragment() {
    vec4 tex = vec4(texture(SCREEN_TEXTURE, SCREEN_UV));
    vec3 source_hsv = rgb2hsv(tex.rgb);

    float _tol = tolerance * tolerance;

    vec4 from_colors[7] = vec4[](from_color1, from_color2, from_color3, from_color4, from_color5, from_color6, from_color7);
    vec4 to_colors[7] = vec4[](to_color1, to_color2, to_color3, to_color4, to_color5, to_color6, to_color7);

    for (int i = 0; i < 7; ++i) {
        vec3 initial_hsv = rgb2hsv(from_colors[i].rgb);
        vec3 hsv_shift = rgb2hsv(to_colors[i].rgb) - initial_hsv;
        float hue = initial_hsv.r;

        if (hue - source_hsv.r >= -_tol && hue - source_hsv.r <= +_tol) {
            vec3 final_hsv = source_hsv + hsv_shift;
            tex.rgb = hsv2rgb(final_hsv);
            break; // Stop checking if a match is found
        }
    }

    COLOR = tex;
}