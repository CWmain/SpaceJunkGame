shader_type canvas_item;
render_mode unshaded, skip_vertex_transform;

uniform sampler2D screen_texture: hint_screen_texture;
uniform float curve;
uniform float force: hint_range(0.0, 1.0, 0.01) = 0.01;
uniform vec2 rocket_position;

void fragment() {
	// Called for every pixel the material is visible on.
	/*
	vec2 cuv = SCREEN_UV * 2.0 - 1.0;
	vec2 uvo = cuv.yx / curve;
	vec2 wuv =  cuv + cuv * uvo * uvo;
	COLOR = texture(screen_texture, (wuv+1.0)/2.0);
	*/
	
	float ratio = SCREEN_PIXEL_SIZE.x / SCREEN_PIXEL_SIZE.y;
	vec2 scaledUV = (SCREEN_UV - vec2(0.5,0.0)) / vec2(ratio, 1.0) + vec2(0.5,0.0);
	
	vec2 disp = normalize(scaledUV - rocket_position)*force;
	float mask = (1.0 - smoothstep(0.4, 0.5, length(scaledUV - rocket_position))) * smoothstep(0.2, 0.3, length(scaledUV - rocket_position));

	COLOR = texture(screen_texture, SCREEN_UV-disp*mask);
	
	

}