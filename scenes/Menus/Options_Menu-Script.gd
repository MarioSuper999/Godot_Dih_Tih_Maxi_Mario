class_name OptionsMenu
extends Control
signal exit_options_menu

@onready var back_button: Button = $"MarginContainer/VBoxContainer/Back Button"

func _ready():
	handle_connecting_signals()
	set_process(false)

func on_back_pressed() -> void:
	exit_options_menu.emit()
	set_process(false)

func handle_connecting_signals() -> void:
	back_button.button_up.connect(on_back_pressed)
