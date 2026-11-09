extends Area2D

enum Weapon { PISTOL, HEART_MODE }

const BULLET := preload("res://bullet_2d.tscn")
const HEART_BULLET_TEXTURE := preload("res://pistol/heart_bullet.png")

var current_weapon: Weapon = Weapon.PISTOL
var first_wand_shot := true


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


func _ready() -> void:
	set_process_unhandled_key_input(true)
	_set_weapon(Weapon.PISTOL)


func _unhandled_key_input(event: InputEvent) -> void:
	if not event is InputEventKey or not event.pressed or event.echo:
		return

	if event.physical_keycode == KEY_1:
		_set_weapon(Weapon.PISTOL)
	elif event.physical_keycode == KEY_2:
		_set_weapon(Weapon.HEART_MODE)


func _set_weapon(weapon: Weapon) -> void:
	current_weapon = weapon
	if weapon == Weapon.HEART_MODE:
		first_wand_shot = true
	%Pistol.visible = weapon == Weapon.PISTOL
	%HeartWand.visible = weapon == Weapon.HEART_MODE
	%ShootingPoint.position = Vector2(51, -11) if weapon == Weapon.PISTOL else Vector2(50, 0)
	%Timer.wait_time = 0.353 if weapon == Weapon.PISTOL else 0.55
	%Timer.start()
	_sync_music_to_weapon()


func _sync_music_to_weapon() -> void:
	var current_scene := get_tree().current_scene
	if current_scene == null:
		return
	if current_scene.has_method("set_heart_mode"):
		current_scene.call("set_heart_mode", current_weapon == Weapon.HEART_MODE)
	var music := current_scene.get_node_or_null("BackgroundMusic") as AudioStreamPlayer
	if music == null:
		return
	if current_weapon == Weapon.HEART_MODE:
		if not music.playing:
			music.play()
	else:
		music.stop()


func shoot():
	var new_bullet = BULLET.instantiate()
	if current_weapon == Weapon.HEART_MODE:
		new_bullet.configure_projectile(HEART_BULLET_TEXTURE, 900.0, 1000.0, -PI / 2.0, true)
	new_bullet.global_transform = %ShootingPoint.global_transform
	if current_weapon == Weapon.HEART_MODE and first_wand_shot:
		new_bullet.global_rotation = -PI / 2.0
		first_wand_shot = false
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
