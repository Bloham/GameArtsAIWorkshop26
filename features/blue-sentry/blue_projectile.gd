extends Area2D

const HEART_TEXTURE := preload("res://pistol/heart_mode_bullet.png")
const HEART_REGION := Rect2(1248, 176, 560, 584)

@export var speed: float = 520.0
@export var damage: float = 8.0
@export var lifetime: float = 5.0

var _direction := Vector2.ZERO


func set_heart_mode(enabled: bool) -> void:
	var orb := get_node_or_null("Orb") as Polygon2D
	var heart := get_node_or_null("HeartSprite") as Sprite2D
	if not enabled:
		if heart != null:
			heart.queue_free()
		if orb != null:
			orb.visible = true
		return
	if orb != null:
		orb.visible = false
	if heart == null:
		heart = Sprite2D.new()
		heart.name = "HeartSprite"
		heart.texture = HEART_TEXTURE
		heart.region_enabled = true
		heart.region_rect = HEART_REGION
		heart.scale = Vector2(100, 100) / HEART_REGION.size
		add_child(heart)


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
