shader_type canvas_item;
render_mode unshaded, skip_vertex_transform;

uniform sampler2D screen_texture: hint_screen_texture;
uniform float curve;

void fragment() {
	// Called for every pixel the material is visible on.
	vec2 cuv = SCREEN_UV * 2.0 - 1.0;
	vec2 uvo = cuv.yx / curve;
	vec2 wuv =  cuv + cuv * uvo * uvo;
	
	COLOR = texture(screen_texture, (wuv+1.0)/2.0);
	

}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
