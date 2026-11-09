extends Button

func _on_button_up() -> void:
	Steam.activateGameOverlayInviteDialog(NetworkingScript.current_lobby_id)
func _ready() -> void:
	pass
