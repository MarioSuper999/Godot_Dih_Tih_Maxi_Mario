class_name PlayerProfile
extends Control
signal leave_lobby
var n = 0

@onready var profile_button: Button = $"Profile Button"
const PlayerScripts = preload("res://scripts/Character Scripts/Player-Scripts.gd")



func _ready():
	handle_connecting_signals()
	set_process(false)

func on_profile_pressed(steam_id):
	Steam.activateGameOverlayToUser("friendadd", steam_id)

func handle_connecting_signals() -> void:
	pass
	#profile_button.button_up.connect(on_profile_pressed(NetworkingScript.players_on_server[n]))
