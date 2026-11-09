class_name Lobby
extends Control
signal leave_lobby

const PLAYER_PROFILE = preload("res://scenes/Menus/profile_button.tscn")
@onready var profile_container: VBoxContainer = $MarginContainer/MarginContainer2/MarginContainer/VBoxContainer/VBoxContainer
@onready var leave_button: Button = $"MarginContainer/HBoxContainer/MarginContainer/VBoxContainer/Leave Button"
@onready var customize_button: Button = $"MarginContainer/HBoxContainer/MarginContainer/VBoxContainer/Customize Button"

var ready_yet : bool = false

func _ready():
	handle_connecting_signals()
	set_process(false)

func on_lobby_created():
	var new_profile := PLAYER_PROFILE.instantiate()
	new_profile.text = str(Steam.getPersonaName()) + " (HOST)"
	profile_container.add_child(new_profile)
	ready_yet = true

func on_player_joined():
	if ready_yet:
		var new_profile := PLAYER_PROFILE.instantiate()
		new_profile.text = str(Steam.getFriendPersonaName(NetworkingScript.players_on_server[NetworkingScript.players_on_server.size()-1]))
		profile_container.add_child(new_profile)
		ready_yet = true

func on_leave_pressed():
	get_tree().change_scene_to_file("res://scenes/Menus/main_menu.tscn")
	set_process(false)

func on_customize_pressed():
	on_player_joined()

func handle_connecting_signals() -> void:
	leave_button.button_up.connect(on_leave_pressed)
	customize_button.button_up.connect(on_customize_pressed)
	NetworkingScript.ready_to_call.connect(on_player_joined)
	NetworkingScript.host_created.connect(on_lobby_created)
