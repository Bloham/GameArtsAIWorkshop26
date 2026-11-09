extends Area2D

@export var boost_duration: float = 5.0
@export var speed_multiplier: float = 1.75


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	var player := get_tree().get_first_node_in_group("player")
	if body != player or not player.has_method("apply_speed_boost"):
		return

	player.apply_speed_boost(boost_duration, speed_multiplier)
	queue_free()
