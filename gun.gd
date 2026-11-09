extends Area2D


func set_weapon_texture(texture_path: String) -> void:
	var weapon: Sprite2D = get_node("WeaponPivot/Pistol")
	weapon.texture = load(texture_path)
	weapon.region_enabled = texture_path == "res://heavy_weapon.png"
	if weapon.region_enabled:
		weapon.region_rect = Rect2(30, 116, 452, 300)
		weapon.scale = Vector2(0.45, 0.45)
		weapon.offset = Vector2(16, 0)
	else:
		weapon.scale = Vector2.ONE
		weapon.offset = Vector2(16, 0)


func _process(_delta):
	look_at(get_global_mouse_position())


func shoot():
	const BULLET = preload("res://bullet_2d.tscn")
	var new_bullet = BULLET.instantiate()
	new_bullet.global_transform = %ShootingPoint.global_transform
	%ShootingPoint.add_child(new_bullet)

	# At point-blank range, the muzzle can sit beyond an enemy that overlaps
	# the player. Start the shot inside that aimed-at enemy so it registers.
	var mouse_position := get_global_mouse_position()
	var point_blank_target: Node2D = null
	var closest_mouse_distance := 100.0
	for body in get_overlapping_bodies():
		if not body.has_method("take_damage"):
			continue
		if global_position.distance_to(body.global_position) > 160.0:
			continue
		var mouse_distance := mouse_position.distance_to(body.global_position)
		if mouse_distance < closest_mouse_distance:
			point_blank_target = body
			closest_mouse_distance = mouse_distance
	if point_blank_target != null:
		new_bullet.global_position = point_blank_target.global_position


func _on_timer_timeout() -> void:
	shoot()
