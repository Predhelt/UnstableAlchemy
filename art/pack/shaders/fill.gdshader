shader_type canvas_item;

uniform vec4 src_color : source_color;
uniform vec4 src_replace_color : source_color;
uniform float src_color_threshold : hint_range(0.0, 1.0, 0.001);

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec4 tex_color = texture(TEXTURE, UV);
	
	float src_distance = length(tex_color.rgb - src_color.rgb);
	
	if(src_distance < src_color_threshold){
		tex_color = src_replace_color;
	}
	COLOR = tex_color;
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
