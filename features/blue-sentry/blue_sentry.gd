extends CharacterBody2D

signal died

const PROJECTILE_SCENE := preload("res://features/blue-sentry/blue_projectile.tscn")

@export var health: int = 4
@export var shoot_interval: float = 3.0
@export var projectile_speed: float = 520.0
@export var projectile_damage: float = 8.0

@onready var _visuals: Node2D = $Visuals

var _player: Node2D
var _shoot_timer: float = 0.7
var _is_dying := false


func _ready() -> void:
	_player = get_tree().get_first_node_in_group("player") as Node2D


func _physics_process(delta: float) -> void:
	if not is_instance_valid(_player):
		_player = get_tree().get_first_node_in_group("player") as Node2D
	if _player == null:
		return

	_shoot_timer -= delta
	if _shoot_timer <= 0.0:
		_shoot_timer = shoot_interval
		_shoot_at_player()


func _shoot_at_player() -> void:
	var direction := global_position.direction_to(_player.global_position)
	var projectile := PROJECTILE_SCENE.instantiate() as Area2D
	get_parent().add_child(projectile)
	projectile.global_position = global_position + direction * 32.0
	projectile.set("speed", projectile_speed)
	projectile.set("damage", projectile_damage)
	projectile.call("set_direction", direction)
	_bounce_on_shot()


func _bounce_on_shot() -> void:
	var tween := create_tween()
	tween.tween_property(_visuals, "scale", Vector2(1.3, 0.7), 0.08)
	tween.tween_property(_visuals, "position:y", -14.0, 0.1)
	tween.parallel().tween_property(_visuals, "scale", Vector2(0.8, 1.25), 0.1)
	tween.tween_property(_visuals, "position:y", 0.0, 0.16).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(_visuals, "scale", Vector2(1.18, 0.82), 0.16)
	tween.tween_property(_visuals, "scale", Vector2.ONE, 0.16).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)


func take_damage(amount: int = 1) -> void:
	if _is_dying:
		return
	health -= amount
	_flash()
	if health <= 0:
		_is_dying = true
		died.emit()
		queue_free()


func _flash() -> void:
	modulate = Color(1.0, 0.45, 0.45)
	var tween := create_tween()
	tween.tween_property(self, "modulate", Color.WHITE, 0.12)
