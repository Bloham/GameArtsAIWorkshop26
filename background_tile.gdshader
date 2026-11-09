shader_type canvas_item;

uniform sampler2D background_texture : source_color;
uniform vec2 tile_count = vec2(7.5, 4.21875);

void fragment() {
	vec2 tiled_uv = fract(SCREEN_UV * tile_count);
	COLOR = texture(background_texture, tiled_uv);
}
