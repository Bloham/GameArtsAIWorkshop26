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
	var enemies_in_range = get_overlapping_bodies()
	if enemies_in_range.size() > 0:
		var target_enemy = enemies_in_range.front()
		look_at(target_enemy.global_position)


func shoot():
	const BULLET = preload("res://bullet_2d.tscn")
	var new_bullet = BULLET.instantiate()
	new_bullet.global_transform = %ShootingPoint.global_transform
	%ShootingPoint.add_child(new_bullet)


func _on_timer_timeout() -> void:
	shoot()
