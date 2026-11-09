extends Area2D

@export var boost_duration: float = 5.0
@export var speed_multiplier: float = 1.75


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	_spawn_near_player()


func _spawn_near_player() -> void:
	var player := get_tree().get_first_node_in_group("player") as Node2D
	if player == null:
		return

	var angle := randf() * TAU
	var distance := randf_range(180.0, 250.0)
	global_position = player.global_position + Vector2.RIGHT.rotated(angle) * distance


func _on_body_entered(body: Node2D) -> void:
	var player := get_tree().get_first_node_in_group("player") as Node2D
	if body != player or not player.has_method("apply_speed_boost"):
		return

	player.apply_speed_boost(boost_duration, speed_multiplier)
	queue_free()
