class_name PlayerProfile
extends Button
signal leave_lobby
var n = 0

@onready var profile_button: Button = $"Profile Button"
const PlayerScripts = preload("res://scripts/Character Scripts/Player-Scripts.gd")


func _on_button_up() -> void:
	Steam.activateGameOverlayToUser("friendadd", NetworkingScript.players_on_server[0])
