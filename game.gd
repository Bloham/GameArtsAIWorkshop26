extends Node2D

## Seconds between item drops. Set to 0 to turn items off.
@export var item_interval: float = 8.0

const REPLAY_COUNTDOWN_SECONDS: int = 10

var _item_timer: float = 0.0
var _replay_seconds_remaining: int = 0
var _round_kills: int = 0
var _high_score: int = 0
const HIGH_SCORE_PATH := "user://highscore.cfg"
var _level_label: Label
var _points_label: Label
var _xp_bar: ProgressBar
var _hud_panel: PanelContainer


func _ready() -> void:
	var save := ConfigFile.new()
	if save.load(HIGH_SCORE_PATH) == OK:
		_high_score = int(save.get_value("score", "high_score", 0))
	_update_score_display()
	_build_progress_hud()
	var player_node: Node = get_node("Player")
	player_node.connect("progression_changed", Callable(self, "_update_progress_hud"))
	player_node.connect("level_up", Callable(self, "_animate_level_up_hud"))
	_update_progress_hud(player_node.get("level"), player_node.get("skill_points"), player_node.get("experience"), player_node.get("xp_to_next"))


func _build_progress_hud() -> void:
	var layer := CanvasLayer.new()
	layer.layer = 10
	add_child(layer)
	var panel := PanelContainer.new()
	_hud_panel = panel
	panel.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	panel.position = Vector2(-150, -140)
	panel.custom_minimum_size = Vector2(300, 112)
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.035, 0.055, 0.11, 0.92)
	style.border_color = Color(0.1, 0.9, 1.0, 1.0)
	style.set_border_width_all(3)
	style.set_corner_radius_all(14)
	style.set_content_margin_all(14)
	panel.add_theme_stylebox_override("panel", style)
	layer.add_child(panel)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 4)
	panel.add_child(column)
	_level_label = Label.new()
	_level_label.add_theme_font_size_override("font_size", 23)
	_level_label.add_theme_color_override("font_color", Color(0.4, 0.95, 1.0))
	column.add_child(_level_label)
	_points_label = Label.new()
	_points_label.add_theme_font_size_override("font_size", 19)
	_points_label.add_theme_color_override("font_color", Color(1.0, 0.82, 0.24))
	column.add_child(_points_label)
	_xp_bar = ProgressBar.new()
	_xp_bar.custom_minimum_size = Vector2(260, 15)
	_xp_bar.show_percentage = false
	_xp_bar.max_value = 5
	_xp_bar.add_theme_stylebox_override("fill", _make_bar_style(Color(0.1, 0.9, 1.0)))
	_xp_bar.add_theme_stylebox_override("background", _make_bar_style(Color(0.12, 0.16, 0.23)))
	column.add_child(_xp_bar)


func _make_bar_style(color: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.set_corner_radius_all(8)
	return style


func _update_progress_hud(level: int, points: int, xp: int, needed: int) -> void:
	_level_label.text = "✦  LEVEL %02d" % level
	_points_label.text = "SKILL POINTS: %d" % points
	_xp_bar.max_value = needed
	_xp_bar.value = xp


func _animate_level_up_hud(_level: int) -> void:
	var tween := create_tween().set_parallel(true)
	tween.tween_property(_hud_panel, "scale", Vector2(1.12, 1.12), 0.16).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(_hud_panel, "modulate", Color(1.0, 0.9, 0.45), 0.16)
	tween.chain().tween_property(_hud_panel, "scale", Vector2.ONE, 0.28).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	_hud_panel.create_tween().tween_property(_hud_panel, "modulate", Color.WHITE, 0.55)


func spawn_mob():
	%PathFollow2D.progress_ratio = randf()
	# FeatureLibrary picks a random enemy from features/enemies.txt,
	# or the original slime if no student has registered one yet.
	var scene: PackedScene = FeatureLibrary.random_enemy()
	var new_mob = scene.instantiate()
	new_mob.global_position = %PathFollow2D.global_position
	new_mob.tree_exited.connect(_on_enemy_removed)
	add_child(new_mob)
	if new_mob.has_signal("died"):
		new_mob.connect("died", Callable(get_node("Player"), "gain_experience"))


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
