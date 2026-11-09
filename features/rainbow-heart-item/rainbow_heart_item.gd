extends Area2D


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	var game := get_tree().current_scene
	if game != null and game.has_method("activate_heart_mode_item"):
		game.call("activate_heart_mode_item")
	queue_free()
