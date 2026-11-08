class_name MainMenu
extends Control


@onready var host_button: Button = $"MarginContainer/HBoxContainer/VBoxContainer/Host Button"
@onready var join_button: Button = $"MarginContainer/HBoxContainer/VBoxContainer/Join Button"
@onready var customize_button: Button = $"MarginContainer/HBoxContainer/VBoxContainer/Customize Button"
@onready var options_button: Button = $"MarginContainer/HBoxContainer/VBoxContainer/Options Button"
@onready var quit_button: Button = $"MarginContainer/HBoxContainer/VBoxContainer/Quit Button"
@onready var options_menu: OptionsMenu = $"Options Menu"
@onready var margin_container: MarginContainer = $MarginContainer
#@onready var lobby : PackedScene = preload()
#@onready var customize : PackedScene = preload()
#@onready var options : PackedScene = preload()


func _ready() -> void:
	handle_connecting_signals()


func on_host_pressed() -> void:
	pass
	#get_tree().change_scene_to_packed(lobby)
	
func on_join_pressed() -> void:
	Steam.activateGameOverlay()
	
func on_customize_pressed() -> void:
	pass
	
func on_options_pressed() -> void:
	margin_container.visible = false
	options_menu.set_process(true)
	options_menu.visible = true
	
func on_quit_pressed() -> void:
	get_tree().quit()
	
func on_exit_options_menu() -> void:
	margin_container.visible = true
	options_menu.visible = false


func handle_connecting_signals() -> void:
	host_button.button_up.connect(on_host_pressed)
	join_button.button_up.connect(on_join_pressed)
	customize_button.button_up.connect(on_customize_pressed)
	options_button.button_up.connect(on_options_pressed)
	quit_button.button_up.connect(on_quit_pressed)
	options_menu.exit_options_menu.connect(on_exit_options_menu)
