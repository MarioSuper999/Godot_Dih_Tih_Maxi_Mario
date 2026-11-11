class_name Lobby
extends Control
signal leave_lobby
signal max_lobby

const PLAYER_PROFILE = preload("res://scenes/Menus/profile_button.tscn")
@onready var profile_container: VBoxContainer = $MarginContainer/MarginContainer2/MarginContainer/VBoxContainer/VBoxContainer
@onready var leave_button: Button = $"MarginContainer/HBoxContainer/MarginContainer/VBoxContainer/Leave Button"
@onready var customize_button: Button = $"MarginContainer/HBoxContainer/MarginContainer/VBoxContainer/Customize Button"
@onready var invite_button: Button = $"MarginContainer/MarginContainer2/MarginContainer/VBoxContainer/Invite Button"

var ready_yet : bool = false

func _ready():
	Steam.lobby_created.connect(the_lobby_created)
	handle_connecting_signals()

func the_lobby_created() -> void:
	print("ready")
	var new_profile := PLAYER_PROFILE.instantiate()
	new_profile.text = str(Steam.getPersonaName()) + " (HOST)"
	profile_container.add_child(new_profile)
	ready_yet = true

func on_player_joined():
	if ready_yet:
		var new_profile := PLAYER_PROFILE.instantiate()
		new_profile.text = str(Steam.getFriendPersonaName(NetworkingScript.players_on_server[NetworkingScript.players_on_server.size()-1]))
		profile_container.add_child(new_profile)
	if NetworkingScript.players_on_server.size() == NetworkingScript.MAX_MEMBERS:
		invite_button.queue_free()

func on_leave_pressed():
	NetworkingScript.on_lobby_left()
	get_tree().change_scene_to_file("res://scenes/Menus/main_menu.tscn")

func on_customize_pressed():
	on_player_joined()

func handle_connecting_signals() -> void:
	leave_button.button_up.connect(on_leave_pressed)
	customize_button.button_up.connect(on_customize_pressed)
#	NetworkingScript.ready_to_call.connect(on_player_joined)
