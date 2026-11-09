extends Area2D

@export var speed: float = 520.0
@export var damage: float = 8.0
@export var lifetime: float = 5.0

var _direction := Vector2.ZERO


func set_direction(direction: Vector2) -> void:
	_direction = direction.normalized()
	rotation = _direction.angle()


func _physics_process(delta: float) -> void:
	global_position += _direction * speed * delta
	lifetime -= delta
	if lifetime <= 0.0:
		queue_free()


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and body.has_method("take_damage"):
		body.call("take_damage", damage)
	queue_free()
