extends Node

const PORT := 7000
const MAX_CLIENTS := 8
const GAME_SCENE := "res://survivors_game.tscn"

signal connection_status(message: String)

func host_game() -> Error:
	var peer := ENetMultiplayerPeer.new()
	var error := peer.create_server(PORT, MAX_CLIENTS)
	if error != OK:
		connection_status.emit("Не вдалося створити сервер: %s" % error_string(error))
		return error

	multiplayer.multiplayer_peer = peer
	connection_status.emit("Сервер запущено на порту %d" % PORT)
	get_tree().change_scene_to_file(GAME_SCENE)
	return OK

func join_game(address: String) -> Error:
	var peer := ENetMultiplayerPeer.new()
	var error := peer.create_client(address.strip_edges(), PORT)
	if error != OK:
		connection_status.emit("Не вдалося почати підключення: %s" % error_string(error))
		return error

	multiplayer.multiplayer_peer = peer
	connection_status.emit("Підключення до %s:%d…" % [address, PORT])
	return OK

func _on_connected_to_server() -> void:
	connection_status.emit("Під'єднано до сервера")
	get_tree().change_scene_to_file(GAME_SCENE)

func _on_connection_failed() -> void:
	connection_status.emit("Не вдалося під'єднатися до сервера")
	multiplayer.multiplayer_peer = OfflineMultiplayerPeer.new()

func _on_server_disconnected() -> void:
	connection_status.emit("З'єднання із сервером втрачено")
	multiplayer.multiplayer_peer = OfflineMultiplayerPeer.new()
	get_tree().change_scene_to_file("res://survivors_game.tscn")

func _ready() -> void:
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.connection_failed.connect(_on_connection_failed)
	multiplayer.server_disconnected.connect(_on_server_disconnected)
