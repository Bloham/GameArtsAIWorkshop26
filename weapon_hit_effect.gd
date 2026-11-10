extends Node2D

const EFFECT_DURATION := 0.55

var effect_style := ""
var _elapsed := 0.0


func configure(new_effect_style: String) -> void:
	effect_style = new_effect_style


func _process(delta: float) -> void:
	_elapsed += delta
	rotation += delta * 1.8
	queue_redraw()
	if _elapsed >= EFFECT_DURATION:
		queue_free()


func _draw() -> void:
	var progress := clampf(_elapsed / EFFECT_DURATION, 0.0, 1.0)
	var alpha := 1.0 - progress
	var radius := lerpf(8.0, 42.0, progress)
	if effect_style == "ice_spike":
		_draw_ice_burst(progress, alpha, radius)
	elif effect_style == "heart_arrow":
		_draw_heart_burst(progress, alpha, radius)


func _draw_ice_burst(progress: float, alpha: float, radius: float) -> void:
	draw_arc(Vector2.ZERO, radius, 0.0, TAU, 28, Color(0.58, 0.9, 1.0, alpha), 3.0, true)
	for shard_index in range(6):
		var angle := TAU * float(shard_index) / 6.0 + _elapsed * 2.0
		var direction := Vector2.RIGHT.rotated(angle)
		var center := direction * radius * 0.72
		var length := lerpf(10.0, 2.0, progress)
		var tangent := direction.rotated(PI * 0.5)
		var points := PackedVector2Array([
			center + direction * length,
			center + tangent * 3.0,
			center - direction * length,
			center - tangent * 3.0,
		])
		draw_colored_polygon(points, Color(0.48, 0.82, 1.0, alpha))
		draw_line(center - tangent * 4.0, center + tangent * 4.0, Color(0.95, 1.0, 1.0, alpha), 1.5, true)


func _draw_heart_burst(progress: float, alpha: float, radius: float) -> void:
	draw_arc(Vector2.ZERO, radius, 0.0, TAU, 32, Color(1.0, 0.35, 0.74, alpha), 3.5, true)
	for heart_index in range(4):
		var angle := TAU * float(heart_index) / 4.0 + _elapsed * 2.5
		var center := Vector2.RIGHT.rotated(angle) * radius * 0.72
		var size := lerpf(1.0, 0.45, progress)
		_draw_heart(center, size, angle, alpha)
	var sparkle_color := Color(1.0, 0.9, 0.98, alpha)
	for sparkle_index in range(4):
		var sparkle_angle := TAU * float(sparkle_index) / 4.0 - _elapsed * 2.0
		var sparkle_center := Vector2.RIGHT.rotated(sparkle_angle) * radius * 0.45
		draw_line(sparkle_center + Vector2(-3.0, 0.0), sparkle_center + Vector2(3.0, 0.0), sparkle_color, 1.6, true)
		draw_line(sparkle_center + Vector2(0.0, -3.0), sparkle_center + Vector2(0.0, 3.0), sparkle_color, 1.6, true)


func _draw_heart(center: Vector2, size: float, angle: float, alpha: float) -> void:
	var heart := PackedVector2Array([
		Vector2(0.0, 8.0), Vector2(-9.0, 0.0), Vector2(-9.0, -5.0),
		Vector2(-5.0, -9.0), Vector2(0.0, -5.0), Vector2(5.0, -9.0),
		Vector2(9.0, -5.0), Vector2(9.0, 0.0),
	])
	var transformed := PackedVector2Array()
	for point in heart:
		transformed.append(center + point.rotated(angle) * size)
	draw_colored_polygon(transformed, Color(1.0, 0.38, 0.76, alpha))
	var outline := transformed.duplicate()
	outline.append(transformed[0])
	draw_polyline(outline, Color(1.0, 0.92, 0.98, alpha), 1.4, true)
