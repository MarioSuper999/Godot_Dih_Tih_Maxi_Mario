class_name Lobby
extends Control
signal leave_lobby

@onready var player_profile: Button = preload("res://prefabs/rooms/box.tscn")


func _ready():
	handle_connecting_signals()
	set_process(false)

func on_back_pressed() -> void:
	leave_lobby.emit()
	set_process(false)

func handle_connecting_signals() -> void:
	back_button.button_up.connect(on_back_pressed)
