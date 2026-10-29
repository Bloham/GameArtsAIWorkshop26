extends Node2D

## Seconds between item drops. Set to 0 to turn items off.
@export var item_interval: float = 8.0

var _item_timer: float = 0.0


func spawn_mob():
	%PathFollow2D.progress_ratio = randf()
	# FeatureLibrary picks a random enemy from features/enemies.txt,
	# or the original slime if no student has registered one yet.
	var scene: PackedScene = FeatureLibrary.random_enemy()
	var new_mob = scene.instantiate()
	new_mob.global_position = %PathFollow2D.global_position
	add_child(new_mob)


func _process(delta: float) -> void:
	if item_interval <= 0.0 or FeatureLibrary.items.is_empty():
		return

	_item_timer -= delta
	if _item_timer <= 0.0:
		_item_timer = item_interval
		spawn_item()


func spawn_item():
	var scene: PackedScene = FeatureLibrary.random_item()
	if scene == null:
		return
	%PathFollow2D.progress_ratio = randf()
	var new_item = scene.instantiate()
	new_item.global_position = %PathFollow2D.global_position
	add_child(new_item)


func _on_timer_timeout():
	spawn_mob()


func _on_player_health_depleted():
	%GameOver.show()
	get_tree().paused = true
