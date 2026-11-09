extends Node2D

## Seconds between item drops. Set to 0 to turn items off.
@export var item_interval: float = 8.0

const REPLAY_COUNTDOWN_SECONDS: int = 10

var _item_timer: float = 0.0
var _replay_seconds_remaining: int = 0
var _round_kills: int = 0
var _high_score: int = 0

const HIGH_SCORE_PATH := "user://highscore.cfg"


func _ready() -> void:
	var save := ConfigFile.new()
	if save.load(HIGH_SCORE_PATH) == OK:
		_high_score = int(save.get_value("score", "high_score", 0))
	_update_score_display()


func spawn_mob():
	%PathFollow2D.progress_ratio = randf()
	# FeatureLibrary picks a random enemy from features/enemies.txt,
	# or the original slime if no student has registered one yet.
	var scene: PackedScene = FeatureLibrary.random_enemy()
	var new_mob = scene.instantiate()
	new_mob.global_position = %PathFollow2D.global_position
	new_mob.tree_exited.connect(_on_enemy_removed)
	add_child(new_mob)


func _on_enemy_removed() -> void:
	_round_kills += 1
	if _round_kills > _high_score:
		_high_score = _round_kills
		var save := ConfigFile.new()
		save.set_value("score", "high_score", _high_score)
		save.save(HIGH_SCORE_PATH)
	_update_score_display()


func _update_score_display() -> void:
	%ScoreLabel.text = "Round Kills: %d\nHigh Score: %d" % [_round_kills, _high_score]


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
	_replay_seconds_remaining = REPLAY_COUNTDOWN_SECONDS
	_update_replay_button()
	%ReplayCountdown.start()


func _on_replay_button_pressed() -> void:
	_restart_game()


func _on_replay_countdown_timeout() -> void:
	_replay_seconds_remaining -= 1
	if _replay_seconds_remaining <= 0:
		_restart_game()
		return

	_update_replay_button()


func _update_replay_button() -> void:
	%ReplayButton.text = "Replay (%d)" % _replay_seconds_remaining


func _restart_game() -> void:
	%ReplayCountdown.stop()
	get_tree().paused = false
	get_tree().reload_current_scene()
