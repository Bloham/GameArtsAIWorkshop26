shader_type canvas_item;

uniform vec4 tint_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);

void fragment() {
	vec4 source = texture(TEXTURE, UV) * COLOR;
	float brightness = max(source.r, max(source.g, source.b));
	COLOR = vec4(tint_color.rgb * brightness, source.a * tint_color.a);
}
