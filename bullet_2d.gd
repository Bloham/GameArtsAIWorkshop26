extends Area2D

const TINT_SHADER = preload("res://weapon_tint.gdshader")
const ROUND_BULLET_TEXTURE = preload("res://pistol/projectile.png")
const HEART_ARROW_TEXTURE = preload("res://pistol/heart_arrow.png")
const HIT_EFFECT_SCRIPT = preload("res://weapon_hit_effect.gd")
const HEART_MODE_BULLET_REGION := Rect2(1248, 176, 560, 584)

@export var speed := 1000.0
@export var max_distance := 1200.0

var travelled_distance := 0.0
var damage := 1
var is_heart_mode_projectile := false
var slow_fraction := 0.0
var freeze_duration := 0.0
var projectile_style := "round"
var bullet_color := Color.WHITE
var _pink_trail: Line2D


func configure_projectile(texture: Texture2D, projectile_speed: float, projectile_range: float, sprite_rotation: float, projectile_damage: int = 1, heart_mode: bool = false) -> void:
	speed = projectile_speed
	max_distance = projectile_range
	damage = projectile_damage
	var sprite := get_node("Sprite") as Sprite2D
	sprite.visible = true
	sprite.material = null
	sprite.texture = texture
	sprite.region_enabled = heart_mode
	if heart_mode:
		sprite.region_rect = HEART_MODE_BULLET_REGION
		sprite.scale = Vector2(100.0, 100.0) / HEART_MODE_BULLET_REGION.size
		sprite.position = Vector2.ZERO
		var heart_hitbox := CircleShape2D.new()
		heart_hitbox.radius = 50.0
		$CollisionShape2D.shape = heart_hitbox
		$CollisionShape2D.position = Vector2.ZERO
	else:
		sprite.scale = Vector2(0.2, 0.2)
		sprite.position = Vector2(-11, -1)
		$CollisionShape2D.position = Vector2(0, 3)
	sprite.rotation = sprite_rotation
	is_heart_mode_projectile = heart_mode


func configure(weapon: Dictionary) -> void:
	damage = int(weapon.get("damage", 1))
	slow_fraction = float(weapon.get("slow_fraction", 0.0))
	freeze_duration = float(weapon.get("freeze_duration", 0.0))
	projectile_style = str(weapon.get("projectile_style", "round"))
	bullet_color = weapon.get("bullet_color", Color.WHITE)
	speed = float(weapon.get("projectile_speed", 1000.0))
	max_distance = float(weapon.get("projectile_range", 1200.0))
	is_heart_mode_projectile = false

	var sprite := get_node("Sprite") as Sprite2D
	sprite.material = null
	sprite.region_enabled = false
	if projectile_style == "round":
		sprite.visible = true
		sprite.texture = ROUND_BULLET_TEXTURE
		sprite.position = Vector2(-11, -1)
		sprite.scale = Vector2.ONE
		var tint_material := ShaderMaterial.new()
		tint_material.shader = TINT_SHADER
		tint_material.set_shader_parameter("tint_color", bullet_color)
		sprite.material = tint_material
	elif projectile_style == "heart_arrow":
		sprite.visible = true
		sprite.texture = HEART_ARROW_TEXTURE
		sprite.position = Vector2.ZERO
		sprite.scale = Vector2(0.16, 0.16)
	else:
		sprite.visible = false
	queue_redraw()


func _ready() -> void:
	if projectile_style == "heart_arrow":
		_pink_trail = Line2D.new()
		_pink_trail.name = "PinkArrowTrail"
		_pink_trail.width = 7.0
		_pink_trail.z_index = -1
		var trail_gradient := Gradient.new()
		trail_gradient.colors = PackedColorArray([
			Color(1.0, 0.35, 0.74, 0.0),
			Color(1.0, 0.35, 0.74, 0.82),
		])
		_pink_trail.gradient = trail_gradient
		_pink_trail.add_point(Vector2(-22, 0))
		_pink_trail.add_point(Vector2(-11, 0))
		_pink_trail.add_point(Vector2.ZERO)
		add_child(_pink_trail)


func _draw() -> void:
	if projectile_style == "ice_spike":
		_draw_ice_spike()


func _draw_ice_spike() -> void:
	var crystal := PackedVector2Array([
		Vector2(16, 0), Vector2(8, -3), Vector2(6, -12), Vector2(2, -5),
		Vector2(-5, -10), Vector2(-3, -3), Vector2(-14, 0), Vector2(-3, 3),
		Vector2(-5, 10), Vector2(2, 5), Vector2(6, 12), Vector2(8, 3),
	])
	draw_colored_polygon(crystal, bullet_color)
	var outline := crystal.duplicate()
	outline.append(crystal[0])
	draw_polyline(outline, Color(0.88, 0.98, 1.0), 1.5, true)
	draw_line(Vector2(-7, 0), Vector2(9, 0), Color(0.95, 1.0, 1.0), 1.5, true)
	draw_line(Vector2(2, -4), Vector2(7, -9), Color(0.95, 1.0, 1.0), 1.0, true)
	draw_line(Vector2(2, 4), Vector2(7, 9), Color(0.95, 1.0, 1.0), 1.0, true)


func _physics_process(delta):
	position += Vector2.RIGHT.rotated(rotation) * speed * delta
	if _pink_trail != null:
		for point_index in range(_pink_trail.get_point_count()):
			var trail_point := _pink_trail.get_point_position(point_index)
			trail_point.x -= speed * delta
			_pink_trail.set_point_position(point_index, trail_point)
		_pink_trail.add_point(Vector2.ZERO)
		while _pink_trail.get_point_count() > 10:
			_pink_trail.remove_point(0)

	travelled_distance += speed * delta
	if travelled_distance > max_distance:
		queue_free()


func _on_body_entered(body: Node2D) -> void:
	_spawn_hit_effect()
	if body.has_method("take_damage"):
		if is_heart_mode_projectile:
			var current_scene := get_tree().current_scene
			if current_scene != null and current_scene.has_method("spawn_heart_hit_effect"):
				current_scene.call("spawn_heart_hit_effect", body)
			body.take_damage(damage)
		elif freeze_duration > 0.0 and body.has_method("take_ice_damage"):
			body.take_ice_damage(damage, freeze_duration)
		elif body.has_method("take_weapon_damage"):
			body.take_weapon_damage(damage, slow_fraction)
		else:
			body.take_damage(damage)
	queue_free()


func _spawn_hit_effect() -> void:
	if projectile_style != "ice_spike" and projectile_style != "heart_arrow":
		return
	var effect := HIT_EFFECT_SCRIPT.new() as Node2D
	effect.call("configure", projectile_style)
	effect.top_level = true
	effect.z_index = 20
	var effect_parent: Node = get_tree().current_scene
	if effect_parent == null:
		effect_parent = get_tree().root
	effect_parent.add_child(effect)
	effect.global_position = global_position
