class_name Lobby
extends Control
signal leave_lobby

const PLAYER_PROFILE = preload("res://scenes/Menus/profile_button.tscn")
@onready var profile_container: VBoxContainer = $"MarginContainer/MarginContainer2/MarginContainer/VBoxContainer/Profile Container"
@onready var leave_button: Button = $"MarginContainer/HBoxContainer/MarginContainer/VBoxContainer/Leave Button"
@onready var options_button: Button = $"MarginContainer/HBoxContainer/MarginContainer/VBoxContainer/Options Button"
@onready var invite_button: Button = $"MarginContainer/MarginContainer2/MarginContainer/VBoxContainer/Invite Button"
@onready var options_menu: OptionsMenu = $"Options Menu"

var ready_yet : bool = false

func _ready():
	handle_connecting_signals()

func on_lobby_created():
	var new_profile := PLAYER_PROFILE.instantiate()
	new_profile.text = str(Steam.getPersonaName()) + " (HOST)"
	profile_container.add_child(new_profile)

func on_player_joined():
	NetworkingScript.get_lobby_members()
	print(NetworkingScript.players_on_server)
	for players in NetworkingScript.players_on_server:
		var new_profile := PLAYER_PROFILE.instantiate()
		var steam_dictionary : Dictionary = NetworkingScript.players_on_server[NetworkingScript.players_on_server.size()-1]
		new_profile.text = str(Steam.getFriendPersonaName(steam_dictionary["steam_id"]))
		profile_container.add_child(new_profile)
	if NetworkingScript.players_on_server.size() > 5:
		invite_button.queue_free()

func on_leave_pressed():
	NetworkingScript.on_lobby_left()
	get_tree().change_scene_to_file("res://scenes/Menus/main_menu.tscn")

func on_options_pressed():
	options_menu.visible = true

func on_exit_options_menu() -> void:
	options_menu.visible = false
	
func handle_connecting_signals() -> void:
	leave_button.button_up.connect(on_leave_pressed)
	options_button.button_up.connect(on_options_pressed)
	options_menu.exit_options_menu.connect(on_exit_options_menu)
	NetworkingScript.ready_to_call.connect(on_player_joined)
	NetworkingScript.host_created.connect(on_lobby_created)
