extends CharacterBody2D
## START HERE if your feature is an ENEMY.
##
## Copy this whole folder, rename it to yourname-featurename, then change this
## script and the scene until it is your enemy. Press F6 to run just this scene.
##
## What the game expects from an enemy (it all works out of the box below):
##   - it is on collision layer 2  -> bullets hit it, touching it hurts the player
##   - it has a take_damage() function -> that is what a bullet calls
##   - it chases the player
## Do not remove those three things, or your enemy will not work in the game.

@export var speed: float = 220.0
@export var health: int = 3

## Optional: drag a sound file here and it plays when the enemy dies.
@export var death_sound: AudioStream

var _player: Node2D


func _ready() -> void:
	_player = get_tree().get_first_node_in_group("player")


func _physics_process(_delta: float) -> void:
	if _player == null:
		return
	var direction := global_position.direction_to(_player.global_position)
	velocity = direction * speed
	move_and_slide()


## Called by bullets. Every enemy needs this function.
func take_damage() -> void:
	health -= 1
	_flash()

	if health <= 0:
		_die()


func _flash() -> void:
	modulate = Color(1.0, 0.45, 0.45)
	var tween := create_tween()
	tween.tween_property(self, "modulate", Color.WHITE, 0.12)


func _die() -> void:
	if death_sound != null:
		_play_sound(death_sound, global_position)
	queue_free()


## Small helper so you can play a sound without adding nodes to the scene.
func _play_sound(stream: AudioStream, at: Vector2) -> void:
	var player := AudioStreamPlayer2D.new()
	player.stream = stream
	player.finished.connect(player.queue_free)
	get_parent().add_child(player)
	player.global_position = at
	player.play()
