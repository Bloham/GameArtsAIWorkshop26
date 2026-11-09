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
	# At point-blank range the muzzle can be past the target, so start the
	# bullet inside the player's position where an overlapping enemy can be hit.
	const POINT_BLANK_DISTANCE := 160.0
	if global_position.distance_to(get_global_mouse_position()) <= POINT_BLANK_DISTANCE:
		new_bullet.global_position = global_position


func _on_timer_timeout() -> void:
	shoot()
