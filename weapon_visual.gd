extends Node2D

var weapon_type := "pistol"
var weapon_color := Color(1.0, 0.35, 0.72)


func configure(new_weapon_type: String, new_weapon_color: Color) -> void:
	weapon_type = new_weapon_type
	weapon_color = new_weapon_color
	queue_redraw()


func _draw() -> void:
	if weapon_type != "bow":
		return

	var bow_curve := PackedVector2Array([
		Vector2(0, -25),
		Vector2(10, -20),
		Vector2(15, -10),
		Vector2(17, 0),
		Vector2(15, 10),
		Vector2(10, 20),
		Vector2(0, 25),
	])
	draw_polyline(bow_curve, Color(0.48, 0.08, 0.25), 8.0, true)
	draw_polyline(bow_curve, weapon_color, 5.0, true)
	draw_line(Vector2(0, -25), Vector2(0, 25), Color(1.0, 0.88, 0.96), 1.5, true)
