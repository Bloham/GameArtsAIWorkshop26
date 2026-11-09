extends Control

@onready var address_input: LineEdit = %AddressInput
@onready var status_label: Label = %StatusLabel

func _ready() -> void:
	NetworkManager.connection_status.connect(_show_status)

func _on_host_button_pressed() -> void:
	NetworkManager.host_game()

func _on_join_button_pressed() -> void:
	var address := address_input.text.strip_edges()
	if address.is_empty():
		address = "127.0.0.1" # Тест на цьому самому комп'ютері.
	NetworkManager.join_game(address)

func _show_status(message: String) -> void:
	status_label.text = message
