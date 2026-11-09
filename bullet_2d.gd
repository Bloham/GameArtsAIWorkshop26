extends Area2D

@export var speed := 1000.0
@export var max_distance := 1200.0

var travelled_distance := 0.0
var is_heart_mode_projectile := false
const HEART_MODE_BULLET_REGION := Rect2(1248, 176, 560, 584)


func configure_projectile(texture: Texture2D, projectile_speed: float, projectile_range: float, sprite_rotation: float, heart_mode: bool = false) -> void:
	speed = projectile_speed
	max_distance = projectile_range
	$Sprite.texture = texture
	$Sprite.region_enabled = heart_mode
	if heart_mode:
		$Sprite.region_rect = HEART_MODE_BULLET_REGION
		$Sprite.scale = Vector2(100.0, 100.0) / HEART_MODE_BULLET_REGION.size
		$Sprite.position = Vector2.ZERO
		var heart_hitbox := CircleShape2D.new()
		heart_hitbox.radius = 50.0
		$CollisionShape2D.shape = heart_hitbox
		$CollisionShape2D.position = Vector2.ZERO
	else:
		$Sprite.scale = Vector2(0.2, 0.2)
		$Sprite.position = Vector2(-11, -1)
		$CollisionShape2D.position = Vector2(0, 3)
	$Sprite.rotation = sprite_rotation
	is_heart_mode_projectile = heart_mode


func _physics_process(delta):
	position += Vector2.RIGHT.rotated(rotation) * speed * delta
	
	travelled_distance += speed * delta
	if travelled_distance > max_distance:
		queue_free()


func _on_body_entered(body):
	queue_free()
	if body.has_method("take_damage"):
		if is_heart_mode_projectile:
			var current_scene := get_tree().current_scene
			if current_scene != null and current_scene.has_method("spawn_heart_hit_effect"):
				current_scene.call("spawn_heart_hit_effect", body)
		body.take_damage()
		if is_heart_mode_projectile and is_instance_valid(body):
			body.take_damage()
