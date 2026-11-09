extends Area2D

@export var speed := 1000.0
@export var max_distance := 1200.0

var travelled_distance := 0.0
var damage := 1
var is_heart_wand_projectile := false


func configure_projectile(texture: Texture2D, projectile_speed: float, projectile_range: float, sprite_rotation: float, projectile_damage: int = 1, heart_wand: bool = false) -> void:
	speed = projectile_speed
	max_distance = projectile_range
	damage = projectile_damage
	$Sprite.texture = texture
	$Sprite.scale = Vector2(0.17, 0.17)
	$Sprite.rotation = sprite_rotation
	is_heart_wand_projectile = heart_wand


func _physics_process(delta):
	position += Vector2.RIGHT.rotated(rotation) * speed * delta
	
	travelled_distance += speed * delta
	if travelled_distance > max_distance:
		queue_free()


func _on_body_entered(body):
	queue_free()
	if body.has_method("take_damage"):
		if is_heart_wand_projectile:
			var current_scene := get_tree().current_scene
			if current_scene != null and current_scene.has_method("spawn_heart_hit_effect"):
				current_scene.call("spawn_heart_hit_effect", body)
		body.take_damage(damage)
