shader_type canvas_item;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_nearest;
uniform vec4 lightest : source_color = vec4(0.784313725, 0.788235294, 0.262745098,1);
uniform vec4 light : source_color = vec4(0.490196078, 0.521568627, 0.152941176, 1);
uniform vec4 dark : source_color = vec4(0, 0.415686275, 0, 1);
uniform vec4 darkest : source_color = vec4(0.015686275, 0.243137255, 0, 1);


// Color offset - changes threshold for color adjustments
uniform float offset = 0.5;

vec4 to_grayscale(vec4 pixel_color) {
	float avg_grayscale = dot(pixel_color.rgb, vec3(0.299, 0.587, 0.114));
	return vec4(avg_grayscale,avg_grayscale,avg_grayscale, 1.0);
}

vec4 to_gameboy(vec4 grayscale) {
    // Color greater than (default) 0.75 in value
    // Set brightest color 1
    if(grayscale.r > offset * 1.5)
        return vec4(lightest);
    // Color greater than (default) 0.50 in value
    // Set bright color 2
    if(grayscale.r > offset)
        return vec4(light);

    // Color greater than (default) 0.25 in value
    // Set dark color 3
    if(grayscale.r > offset * 0.5)
        return vec4(dark);

    // Color greater than 0 in value
    // Set darkest color 4
    return vec4(darkest);
}


void fragment() {
//	vec4 pixelColor =  texture(TEXTURE,UV);
	vec4 pixelColor =  vec4(texture(SCREEN_TEXTURE, SCREEN_UV));
	vec4 grayscale = to_grayscale(pixelColor);
	vec4 gameboy = to_gameboy(grayscale);
	COLOR = gameboy;
}