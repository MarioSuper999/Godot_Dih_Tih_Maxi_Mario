class_name Lobby
extends Control
signal leave_lobby

const PLAYER_PROFILE = preload("res://scenes/Menus/player_profile.tscn")
@onready var profile_container: VBoxContainer = $MarginContainer/MarginContainer2/MarginContainer/VBoxContainer
@onready var leave_button: Button = $"MarginContainer/HBoxContainer/MarginContainer/VBoxContainer/Leave Button"
@onready var customize_button: Button = $"MarginContainer/HBoxContainer/MarginContainer/VBoxContainer/Customize Button"

func _ready():
	handle_connecting_signals()
	set_process(false)
	await NetworkingScript.players_on_server.size() > 0
	on_player_joined()

func on_player_joined():
	var new_profile := PLAYER_PROFILE.instantiate()
	profile_container.add_child(new_profile)
	print("baby")

func on_leave_pressed():
	get_tree().change_scene_to_file("res://scenes/Menus/main_menu.tscn")
	set_process(false)

func handle_connecting_signals() -> void:
	leave_button.button_up.connect(on_leave_pressed)
	NetworkingScript.ready_to_call.connect(on_player_joined)
