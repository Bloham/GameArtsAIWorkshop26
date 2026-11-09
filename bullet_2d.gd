extends Area2D

@export var speed := 1000.0
@export var max_distance := 1200.0

var travelled_distance := 0.0


func configure_projectile(texture: Texture2D, projectile_speed: float, projectile_range: float, sprite_rotation: float) -> void:
	speed = projectile_speed
	max_distance = projectile_range
	$Sprite.texture = texture
	$Sprite.scale = Vector2(0.2, 0.2)
	$Sprite.rotation = sprite_rotation


func _physics_process(delta):
	position += Vector2.RIGHT.rotated(rotation) * speed * delta
	
	travelled_distance += speed * delta
	if travelled_distance > max_distance:
		queue_free()


func _on_body_entered(body):
	queue_free()
	if body.has_method("take_damage"):
		body.take_damage()
