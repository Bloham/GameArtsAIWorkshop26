extends Node2D

## Seconds between item drops. Set to 0 to turn items off.
@export var item_interval: float = 8.0

const REPLAY_COUNTDOWN_SECONDS: int = 10
const WEAPON_CHOICE_SECONDS: float = 5.0
const DEFAULT_WEAPON_TEXTURE := "res://pistol/pistol.png"
const ALT_WEAPON_TEXTURE := "res://heavy_weapon.png"
const BOSS_SCENE := "res://features/liselle-boss/boss.tscn"
const GREEN_ENEMY_SCENE := "res://mob.tscn"
const HEART_WAND_ENEMY_TEXTURE := preload("res://characters/heart_wand_enemy.png")
const HEART_EFFECT_TEXTURE := preload("res://pistol/heart_bullet.png")
const ARENA_HALF_EXTENTS := Vector2(1600.0, 1000.0)
const SPAWN_MARGIN := 64.0
const BASE_MAX_ENEMIES := 15
const ENEMIES_PER_LEVEL := 10

var _item_timer: float = 0.0
var _weapon_seconds_remaining: float = WEAPON_CHOICE_SECONDS
var _weapon_choice_open := true
var _replay_seconds_remaining: int = 0
var _survival_time: float = 0.0
var _round_kills: int = 0
var _high_score: int = 0
var _boss_respawn_pending := false
var _active_boss: Node2D = null
var _max_enemies: int = BASE_MAX_ENEMIES
var _heart_wand_mode := false
const HIGH_SCORE_PATH := "user://highscore.cfg"
var _level_label: Label
var _points_label: Label
var _xp_bar: ProgressBar
var _hud_panel: PanelContainer
var _weapon_countdown_label: Label


func _ready() -> void:
	var save := ConfigFile.new()
	if save.load(HIGH_SCORE_PATH) == OK:
		_high_score = int(save.get_value("score", "high_score", 0))
	_update_score_display()
	_build_progress_hud()
	_build_weapon_choice()
	get_node("Timer").stop()
	get_node("Player").set_physics_process(false)
	get_node("Player/Gun/Timer").stop()
	var player_node: Node = get_node("Player")
	player_node.connect("progression_changed", Callable(self, "_update_progress_hud"))
	player_node.connect("level_up", Callable(self, "_animate_level_up_hud"))
	_update_progress_hud(player_node.get("level"), player_node.get("skill_points"), player_node.get("experience"), player_node.get("xp_to_next"))


func _build_weapon_choice() -> void:
	var layer := CanvasLayer.new()
	layer.name = "WeaponChoice"
	layer.layer = 20
	layer.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(layer)
	var backdrop := ColorRect.new()
	backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	backdrop.color = Color(0.015, 0.025, 0.055, 0.88)
	layer.add_child(backdrop)
	var panel := PanelContainer.new()
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.position = Vector2(-480, -250)
	panel.custom_minimum_size = Vector2(960, 500)
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color(0.04, 0.08, 0.15, 1.0)
	panel_style.border_color = Color(0.1, 0.85, 1.0, 1.0)
	panel_style.set_border_width_all(3)
	panel_style.set_corner_radius_all(18)
	panel_style.set_content_margin_all(24)
	panel.add_theme_stylebox_override("panel", panel_style)
	layer.add_child(panel)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 16)
	panel.add_child(column)
	var title := Label.new()
	title.text = "CHOOSE YOUR WEAPON"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 36)
	title.add_theme_color_override("font_color", Color(0.4, 0.95, 1.0))
	column.add_child(title)
	_weapon_countdown_label = Label.new()
	_weapon_countdown_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_weapon_countdown_label.add_theme_font_size_override("font_size", 22)
	_weapon_countdown_label.add_theme_color_override("font_color", Color(1.0, 0.82, 0.24))
	column.add_child(_weapon_countdown_label)
	var choices := HBoxContainer.new()
	choices.alignment = BoxContainer.ALIGNMENT_CENTER
	choices.add_theme_constant_override("separation", 24)
	column.add_child(choices)
	_add_weapon_choice(choices, "ORIGINAL PISTOL", DEFAULT_WEAPON_TEXTURE)
	_add_weapon_choice(choices, "HEAVY WEAPON", ALT_WEAPON_TEXTURE)
	_update_weapon_countdown()


func _add_weapon_choice(parent: HBoxContainer, title: String, texture_path: String) -> void:
	var choice := Button.new()
	choice.custom_minimum_size = Vector2(400, 330)
	choice.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	choice.size_flags_vertical = Control.SIZE_EXPAND_FILL
	choice.pressed.connect(_on_weapon_chosen.bind(texture_path))
	parent.add_child(choice)
	var column := VBoxContainer.new()
	column.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	column.mouse_filter = Control.MOUSE_FILTER_IGNORE
	column.add_theme_constant_override("separation", 10)
	choice.add_child(column)
	var preview := TextureRect.new()
	preview.texture = load(texture_path)
	preview.custom_minimum_size = Vector2(340, 240)
	preview.size_flags_vertical = Control.SIZE_EXPAND_FILL
	preview.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	preview.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	preview.mouse_filter = Control.MOUSE_FILTER_IGNORE
	column.add_child(preview)
	var label := Label.new()
	label.text = title
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 26)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	column.add_child(label)


func _update_weapon_countdown() -> void:
	if _weapon_countdown_label:
		_weapon_countdown_label.text = "Starting in %d seconds — pistol is the default" % int(ceil(_weapon_seconds_remaining))


func _on_weapon_chosen(texture_path: String) -> void:
	if not _weapon_choice_open:
		return
	_weapon_choice_open = false
	_survival_time = 0.0
	%SurvivalTimeLabel.text = "Time survived: 00:00"
	get_node("Player/Gun").set_weapon_texture(texture_path)
	get_node("WeaponChoice").queue_free()
	get_node("Player").set_physics_process(true)
	get_node("Player/Gun/Timer").start()
	get_node("Timer").start()


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
	_max_enemies = BASE_MAX_ENEMIES + (level - 1) * ENEMIES_PER_LEVEL
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
	if not _heart_wand_mode and get_tree().get_nodes_in_group("enemies").size() >= _max_enemies:
		return
	%PathFollow2D.progress_ratio = randf()
	# FeatureLibrary picks a random enemy from features/enemies.txt,
	# or the original slime if no student has registered one yet.
	var scene: PackedScene
	if _boss_respawn_pending:
		if _has_active_boss():
			return
		scene = load(BOSS_SCENE)
	else:
		scene = _random_enemy_scene()
	var is_boss := scene.resource_path == BOSS_SCENE
	if is_boss and _has_active_boss():
		return
	var new_mob := scene.instantiate() as Node2D
	new_mob.global_position = _clamp_to_arena(%PathFollow2D.global_position)
	new_mob.tree_exited.connect(_on_enemy_removed)
	new_mob.add_to_group("enemies")
	if is_boss:
		_active_boss = new_mob
		new_mob.add_to_group("boss")
		_boss_respawn_pending = false
		new_mob.tree_exited.connect(_on_boss_removed)
	add_child(new_mob)
	if _heart_wand_mode:
		_set_enemy_heart_skin(new_mob, true)
	if new_mob.has_signal("died"):
		new_mob.connect("died", Callable(get_node("Player"), "gain_experience"))
		new_mob.connect("died", _on_enemy_died.bind(new_mob))


func spawn_heart_hit_effect(enemy: Node2D) -> void:
	if not _heart_wand_mode:
		return
	enemy.set_meta("heart_wand_hit", true)
	for index in 3:
		var heart := Sprite2D.new()
		heart.texture = HEART_EFFECT_TEXTURE
		heart.scale = Vector2(0.035, 0.035)
		heart.global_position = enemy.global_position + Vector2((index - 1) * 16.0, -38.0)
		add_child(heart)
		var tween := heart.create_tween()
		tween.set_parallel(true)
		tween.tween_property(heart, "position:y", heart.position.y - 28.0 - randf_range(0.0, 10.0), 0.55)
		tween.tween_property(heart, "modulate:a", 0.0, 0.55)
		tween.chain().tween_callback(heart.queue_free)


func _on_enemy_died(...signal_args) -> void:
	if signal_args.is_empty():
		return
	var enemy := signal_args.back() as Node2D
	if not is_instance_valid(enemy) or not enemy.has_meta("heart_wand_hit"):
		return
	var heart := Sprite2D.new()
	heart.texture = HEART_EFFECT_TEXTURE
	heart.scale = Vector2(0.0, 0.0)
	heart.global_position = enemy.global_position
	add_child(heart)
	var tween := heart.create_tween()
	tween.tween_property(heart, "scale", Vector2(0.14, 0.14), 0.18).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_interval(0.55)
	tween.tween_property(heart, "modulate:a", 0.0, 0.27)
	tween.tween_callback(heart.queue_free)


func _random_enemy_scene() -> PackedScene:
	var choices: Array[PackedScene] = FeatureLibrary.enemies.duplicate()
	if choices.is_empty():
		choices.append(load(GREEN_ENEMY_SCENE))
	if _heart_wand_mode:
		for enemy_scene in FeatureLibrary.enemies:
			if enemy_scene.resource_path == GREEN_ENEMY_SCENE:
				choices.append(enemy_scene)
				break
	return choices.pick_random()


func set_heart_wand_mode(enabled: bool) -> void:
	_heart_wand_mode = enabled
	for enemy in get_tree().get_nodes_in_group("enemies"):
		_set_enemy_heart_skin(enemy, enabled)


func is_heart_wand_active() -> bool:
	return _heart_wand_mode


func _set_enemy_heart_skin(enemy: Node, enabled: bool) -> void:
	var skin := enemy.get_node_or_null("HeartWandSkin") as Sprite2D
	if enabled:
		if skin == null:
			var hidden_visuals: Array[NodePath] = []
			for visual in enemy.find_children("*", "CanvasItem", true, false):
				if visual is CollisionShape2D or visual is CollisionPolygon2D:
					continue
				if visual.visible:
					hidden_visuals.append(enemy.get_path_to(visual))
					visual.visible = false
			enemy.set_meta("heart_hidden_visuals", hidden_visuals)
			skin = Sprite2D.new()
			skin.name = "HeartWandSkin"
			skin.texture = HEART_WAND_ENEMY_TEXTURE
			skin.centered = true
			skin.z_index = 10
			enemy.add_child(skin)
			var shape := enemy.find_child("CollisionShape2D", true, false) as CollisionShape2D
			var display_size := Vector2(64, 64)
			if shape != null:
				skin.position = enemy.to_local(shape.global_position)
				if shape.shape is CircleShape2D:
					display_size = Vector2.ONE * shape.shape.radius * 2.0
				elif shape.shape is RectangleShape2D:
					display_size = shape.shape.size
			skin.scale = display_size / Vector2(HEART_WAND_ENEMY_TEXTURE.get_size())
		else:
			skin.visible = true
	else:
		if skin != null:
			skin.visible = false
		if enemy.has_meta("heart_hidden_visuals"):
			for visual_path in enemy.get_meta("heart_hidden_visuals"):
				var visual := enemy.get_node_or_null(visual_path) as CanvasItem
				if visual != null:
					visual.visible = true
			enemy.remove_meta("heart_hidden_visuals")


func _on_enemy_removed() -> void:
	_round_kills += 1
	if _round_kills > _high_score:
		_high_score = _round_kills
		var save := ConfigFile.new()
		save.set_value("score", "high_score", _high_score)
		save.save(HIGH_SCORE_PATH)
	_update_score_display()


func _on_boss_removed() -> void:
	_active_boss = null
	_boss_respawn_pending = true


func _has_active_boss() -> bool:
	if is_instance_valid(_active_boss) and _active_boss.is_inside_tree():
		return true
	return not get_tree().get_nodes_in_group("boss").is_empty()


func _update_score_display() -> void:
	%ScoreLabel.text = "Round Kills: %d\nHigh Score: %d" % [_round_kills, _high_score]


func _process(delta: float) -> void:
	if _weapon_choice_open:
		_weapon_seconds_remaining -= delta
		_update_weapon_countdown()
		if _weapon_seconds_remaining <= 0.0:
			_on_weapon_chosen(DEFAULT_WEAPON_TEXTURE)
		return

	_survival_time += delta
	%SurvivalTimeLabel.text = "Time survived: %s" % _format_survival_time()
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
	new_item.global_position = _clamp_to_arena(%PathFollow2D.global_position)
	add_child(new_item)


func _clamp_to_arena(position: Vector2) -> Vector2:
	var spawn_limit := ARENA_HALF_EXTENTS - Vector2.ONE * SPAWN_MARGIN
	return Vector2(
		clampf(position.x, -spawn_limit.x, spawn_limit.x),
		clampf(position.y, -spawn_limit.y, spawn_limit.y)
	)


func _on_timer_timeout():
	spawn_mob()


func _on_player_health_depleted():
	%FinalTimeLabel.text = "Time survived: %s" % _format_survival_time()
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


func _format_survival_time() -> String:
	var total_seconds := int(_survival_time)
	var minutes := int(total_seconds / 60)
	var seconds := total_seconds % 60
	return "%02d:%02d" % [minutes, seconds]
