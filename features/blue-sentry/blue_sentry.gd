extends CharacterBody2D

signal died

const PROJECTILE_SCENE := preload("res://features/blue-sentry/blue_projectile.tscn")

@export var health: int = 4
@export var shoot_interval: float = 1.7
@export var projectile_speed: float = 520.0
@export var projectile_damage: float = 8.0

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


func take_damage() -> void:
	if _is_dying:
		return
	health -= 1
	modulate = Color(0.65, 0.85, 1.0)
	create_tween().tween_property(self, "modulate", Color.WHITE, 0.12)
	if health <= 0:
		_is_dying = true
		died.emit()
		queue_free()
