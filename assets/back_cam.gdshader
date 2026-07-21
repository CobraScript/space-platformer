shader_type canvas_item;

void fragment() {
	vec4 color = texture(TEXTURE, UV);
	color.g += 0.3;
	COLOR = color;
}
