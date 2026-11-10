extends Node2D

var _elapsed := 0.0


func _process(delta: float) -> void:
	_elapsed += delta
	rotation = sin(_elapsed * 4.0) * 0.035
	queue_redraw()


func _draw() -> void:
	var center := Vector2(0, -28)
	var pulse := sin(_elapsed * 8.0) * 3.0
	var ring_color := Color(0.55, 0.9, 1.0, 0.78)
	draw_arc(center, 76.0 + pulse, 0.0, TAU, 40, ring_color, 3.5, true)
	draw_arc(center, 65.0 - pulse * 0.4, 0.0, TAU, 40, Color(0.88, 0.98, 1.0, 0.7), 1.5, true)

	for shard_index in range(6):
		var angle := TAU * float(shard_index) / 6.0 - _elapsed * 0.65
		var direction := Vector2.RIGHT.rotated(angle)
		var shard_center := center + direction * 67.0
		var tangent := direction.rotated(PI * 0.5)
		var shard := PackedVector2Array([
			shard_center + direction * 11.0,
			shard_center + tangent * 5.0,
			shard_center - direction * 10.0,
			shard_center - tangent * 5.0,
		])
		draw_colored_polygon(shard, Color(0.48, 0.82, 1.0, 0.85))
		var outline := shard.duplicate()
		outline.append(shard[0])
		draw_polyline(outline, Color(0.94, 1.0, 1.0, 0.95), 1.8, true)
		draw_line(shard_center - tangent * 3.0, shard_center + tangent * 3.0, Color.WHITE, 1.2, true)
