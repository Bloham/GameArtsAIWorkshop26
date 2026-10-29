extends Area2D
## START HERE if your feature is an ITEM / PICKUP.
##
## Copy this whole folder, rename it to yourname-featurename, then change this
## script and the scene until it is your item. Press F6 to run just this scene.
##
## What the game expects from an item (it all works out of the box below):
##   - collision_mask = 1  -> it notices the player walking into it
##   - it does its own thing on pickup, then deletes itself
## You can heal, speed up, spawn something, play a sound, whatever you like --
## just keep those two things true and it will work in the game.

## How much health the player gets back. Set to 0 for items that do something else.
@export var heal_amount: float = 25.0

## Optional: drag a sound file here and it plays when the item is collected.
@export var pickup_sound: AudioStream


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return

	if heal_amount > 0.0 and body.has_method("heal"):
		body.heal(heal_amount)

	if pickup_sound != null:
		_play_sound(pickup_sound, global_position)

	queue_free()


## Small helper so you can play a sound without adding nodes to the scene.
func _play_sound(stream: AudioStream, at: Vector2) -> void:
	var player := AudioStreamPlayer2D.new()
	player.stream = stream
	player.finished.connect(player.queue_free)
	get_parent().add_child(player)
	player.global_position = at
	player.play()
