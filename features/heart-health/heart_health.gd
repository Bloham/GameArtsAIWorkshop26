extends Area2D

## Health restored when the player collects this pickup.
@export var heal_amount: float = 25.0


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return

	if body.has_method("heal"):
		body.heal(heal_amount)

	queue_free()
