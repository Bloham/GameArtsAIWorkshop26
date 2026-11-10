extends CharacterBody2D

const ICE_FREEZE_VISUAL = preload("res://ice_freeze_visual.gd")

signal died
signal green_monster_died(death_position: Vector2)


var speed = randf_range(200, 300)
var health = 5
var _is_frozen := false
var _is_dying := false
var _freeze_elapsed := 0.0
var _freeze_duration := 0.0
var _freeze_damage_interval := 0.0
var _freeze_damage_total := 0
var _freeze_damage_applied := 0
var _speed_before_freeze := 0.0
var _slime_color_before_freeze := Color.WHITE
var _freeze_visual: Node2D

@onready var player = get_node("/root/Game/Player")


func _ready():
	%Slime.play_walk()


func _physics_process(delta):
	if _is_frozen:
		_update_ice_freeze(delta)
		velocity = Vector2.ZERO
		if not _is_dying:
			move_and_slide()
		return

	var direction = global_position.direction_to(player.global_position)
	velocity = direction * speed
	move_and_slide()


func take_weapon_damage(damage_amount: int, slow_fraction: float) -> void:
	if slow_fraction > 0.0:
		speed *= 1.0 - clampf(slow_fraction, 0.0, 1.0)
	take_damage(damage_amount)


func take_ice_damage(damage_amount: int, freeze_seconds: float) -> void:
	if _is_frozen or _is_dying or health <= 0:
		return
	if freeze_seconds <= 0.0:
		take_damage(damage_amount)
		return

	_is_frozen = true
	_freeze_elapsed = 0.0
	_freeze_duration = freeze_seconds
	_freeze_damage_total = mini(maxi(damage_amount, 1), health)
	_freeze_damage_applied = 0
	_freeze_damage_interval = _freeze_duration / float(_freeze_damage_total)
	_speed_before_freeze = speed
	speed = 0.0
	_slime_color_before_freeze = %Slime.modulate
	%Slime.modulate = Color(0.55, 0.84, 1.0, 1.0)
	_freeze_visual = ICE_FREEZE_VISUAL.new() as Node2D
	_freeze_visual.name = "IceFreezeVisual"
	_freeze_visual.z_index = 8
	add_child(_freeze_visual)


func _update_ice_freeze(delta: float) -> void:
	_freeze_elapsed = minf(_freeze_elapsed + delta, _freeze_duration)
	var damage_due := mini(
		_freeze_damage_total,
		floori((_freeze_elapsed + 0.0001) / _freeze_damage_interval)
	)
	while _freeze_damage_applied < damage_due:
		_freeze_damage_applied += 1
		take_damage(1)
		if _is_dying:
			return
	if _freeze_elapsed >= _freeze_duration:
		_end_ice_freeze()


func _end_ice_freeze() -> void:
	_is_frozen = false
	speed = _speed_before_freeze
	%Slime.modulate = _slime_color_before_freeze
	if is_instance_valid(_freeze_visual):
		_freeze_visual.queue_free()
	_freeze_visual = null


func take_damage(damage_amount: int = 1) -> void:
	if _is_dying:
		return
	if not _is_frozen:
		%Slime.play_hurt()
	health -= damage_amount

	if health <= 0:
		_is_dying = true
		if is_instance_valid(_freeze_visual):
			_freeze_visual.queue_free()
		died.emit()
		green_monster_died.emit(global_position)
		var smoke_scene = preload("res://smoke_explosion/smoke_explosion.tscn")
		var smoke = smoke_scene.instantiate()
		get_parent().add_child(smoke)
		smoke.global_position = global_position
		queue_free()
