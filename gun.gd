extends Area2D

enum Weapon { PISTOL, HEART_MODE }

const BULLET := preload("res://bullet_2d.tscn")
const HEART_MODE_BULLET_TEXTURE := preload("res://pistol/heart_mode_bullet.png")
const DEFAULT_PISTOL_TEXTURE := preload("res://pistol/pistol.png")
const HEAVY_WEAPON_DAMAGE := 3
const TINT_SHADER = preload("res://weapon_tint.gdshader")
const WEAPON_CATALOG = preload("res://weapon_catalog.gd")

var current_weapon: Weapon = Weapon.PISTOL
var is_heavy_weapon := false
var first_wand_shot := true
var equipped_weapon: Dictionary = {}

@onready var _pistol_sprite := get_node("WeaponPivot/Pistol") as Sprite2D
@onready var _weapon_visual := get_node("WeaponPivot/WeaponVisual") as Node2D
@onready var _fire_timer := get_node("Timer") as Timer


func set_weapon_texture(texture_path: String) -> void:
	_pistol_sprite.texture = load(texture_path)
	_pistol_sprite.region_enabled = texture_path == "res://heavy_weapon.png"
	is_heavy_weapon = _pistol_sprite.region_enabled
	if is_heavy_weapon:
		_pistol_sprite.region_rect = Rect2(30, 116, 452, 300)
		_pistol_sprite.scale = Vector2(0.24, 0.24)
		_pistol_sprite.offset = Vector2(16, 0)
		_apply_tint(_pistol_sprite, Color.WHITE)
	else:
		_pistol_sprite.scale = Vector2.ONE
		_pistol_sprite.offset = Vector2(16, 0)
		var weapon_color: Color = equipped_weapon.get("weapon_color", Color.WHITE)
		_apply_tint(_pistol_sprite, weapon_color)
	_refresh_weapon_sprites()


func _process(_delta):
	look_at(get_global_mouse_position())


func _ready() -> void:
	set_process_unhandled_key_input(true)
	equip_weapon(WEAPON_CATALOG.get_weapon("blue_pistol"))
	_set_weapon(Weapon.PISTOL)


func _unhandled_key_input(event: InputEvent) -> void:
	if not event is InputEventKey or not event.pressed or event.echo:
		return

	if event.physical_keycode == KEY_1:
		_set_weapon(Weapon.PISTOL)


func _set_weapon(weapon: Weapon) -> void:
	current_weapon = weapon
	if weapon == Weapon.HEART_MODE:
		first_wand_shot = true
	_refresh_weapon_sprites()
	%ShootingPoint.position = Vector2(51, -11) if weapon == Weapon.PISTOL else Vector2(50, 0)
	_update_fire_rate()
	_sync_music_to_weapon()


func _refresh_weapon_sprites() -> void:
	var is_bow := str(equipped_weapon.get("weapon_type", "pistol")) == "bow"
	%Pistol.visible = current_weapon == Weapon.PISTOL and not is_bow
	%WeaponVisual.visible = current_weapon == Weapon.PISTOL and is_bow
	%HeartWand.visible = current_weapon == Weapon.HEART_MODE


func activate_heart_mode_from_item() -> void:
	_set_weapon(Weapon.HEART_MODE)


func deactivate_heart_mode_from_item() -> void:
	if current_weapon == Weapon.HEART_MODE:
		_set_weapon(Weapon.PISTOL)


func _sync_music_to_weapon() -> void:
	var current_scene := get_tree().current_scene
	if current_scene == null:
		return
	if current_scene.has_method("set_heart_mode"):
		current_scene.call("set_heart_mode", current_weapon == Weapon.HEART_MODE)
		return
	var music := current_scene.get_node_or_null("BackgroundMusic") as AudioStreamPlayer
	if music == null:
		return
	if current_weapon == Weapon.HEART_MODE:
		if not music.playing:
			music.play()
	else:
		music.stop()


func shoot() -> void:
	var new_bullet = BULLET.instantiate()
	if current_weapon == Weapon.HEART_MODE:
		new_bullet.configure_projectile(HEART_MODE_BULLET_TEXTURE, 1800.0, 1000.0, PI / 2.0, 3, true)
	else:
		new_bullet.configure(equipped_weapon)
		if is_heavy_weapon:
			new_bullet.damage = HEAVY_WEAPON_DAMAGE
	var firing_transform: Transform2D = %ShootingPoint.global_transform
	var projectile_parent: Node = get_tree().current_scene
	if projectile_parent == null:
		projectile_parent = get_tree().root
	projectile_parent.add_child(new_bullet)
	new_bullet.global_transform = firing_transform
	if current_weapon == Weapon.HEART_MODE and first_wand_shot:
		new_bullet.global_rotation = -PI / 2.0
		first_wand_shot = false

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


func equip_weapon(weapon: Dictionary) -> void:
	equipped_weapon = weapon.duplicate()
	is_heavy_weapon = false
	_pistol_sprite.texture = DEFAULT_PISTOL_TEXTURE
	_pistol_sprite.region_enabled = false
	_pistol_sprite.scale = Vector2.ONE
	_pistol_sprite.offset = Vector2(16, 0)
	var weapon_color: Color = equipped_weapon.get("weapon_color", Color.WHITE)
	_apply_tint(_pistol_sprite, weapon_color)
	_weapon_visual.call("configure", str(equipped_weapon.get("weapon_type", "pistol")), weapon_color)
	_refresh_weapon_sprites()
	_update_fire_rate()


func _update_fire_rate() -> void:
	var shots_per_second := maxf(float(equipped_weapon.get("shots_per_second", 2.83)), 0.01)
	_fire_timer.stop()
	_fire_timer.wait_time = 1.0 / shots_per_second
	_fire_timer.start()


func _apply_tint(sprite: Sprite2D, tint: Color) -> void:
	var tint_material := ShaderMaterial.new()
	tint_material.shader = TINT_SHADER
	tint_material.set_shader_parameter("tint_color", tint)
	sprite.material = tint_material


func _on_timer_timeout() -> void:
	shoot()
