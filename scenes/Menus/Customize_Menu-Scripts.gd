class_name CostumizeMenu
extends Control
signal exit_customize_menu

@onready var back_button: Button = $"MarginContainer/VBoxContainer/Back Button"

func _ready():
	handle_connecting_signals()

func on_back_pressed() -> void:
	exit_customize_menu.emit()

func handle_connecting_signals() -> void:
	back_button.button_up.connect(on_back_pressed)
