shader_type canvas_item;

uniform float percent: hint_range(0.0, 1.0, 0.1);

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	// Called for every pixel the material is visible on.
	vec4 sprite_color = texture(TEXTURE, UV);
	//mix - что-то по типу lerp(добалвляет плавность перехода от белого к начальным цветам)
	vec4 flash_color = mix(sprite_color, vec4(1.0, 1.0, 1.0, sprite_color.a), percent);	//.a - alpha(канал прозрачности). 
	COLOR = flash_color;
	
	
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
