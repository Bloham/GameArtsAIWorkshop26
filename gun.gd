extends Area2D

enum Weapon { PISTOL, HEART_WAND }

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
		_set_weapon(Weapon.HEART_WAND)


func _set_weapon(weapon: Weapon) -> void:
	current_weapon = weapon
	if weapon == Weapon.HEART_WAND:
		first_wand_shot = true
	%Pistol.visible = weapon == Weapon.PISTOL
	%HeartWand.visible = weapon == Weapon.HEART_WAND
	%ShootingPoint.position = Vector2(51, -11) if weapon == Weapon.PISTOL else Vector2(50, 0)
	%Timer.wait_time = 0.353 if weapon == Weapon.PISTOL else 0.55
	%Timer.start()


func shoot():
	var new_bullet = BULLET.instantiate()
	if current_weapon == Weapon.HEART_WAND:
		new_bullet.configure_projectile(HEART_BULLET_TEXTURE, 900.0, 1000.0, -PI / 2.0)
	new_bullet.global_transform = %ShootingPoint.global_transform
	if current_weapon == Weapon.HEART_WAND and first_wand_shot:
		new_bullet.global_rotation = -PI / 2.0
		first_wand_shot = false
	%ShootingPoint.add_child(new_bullet)


func _on_timer_timeout() -> void:
	shoot()
