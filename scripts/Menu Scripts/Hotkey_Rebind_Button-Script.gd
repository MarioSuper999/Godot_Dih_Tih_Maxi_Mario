class_name RebindRebindButton
extends Control


@onready var label: Label = $Label
@onready var button: Button = $Button

@export var action_name : String = "input_left"


func _ready() -> void:
	set_process_unhandled_input(false)
	set_action_name()

func set_action_name() -> void:
	match action_name:
		"input_left":
			label.text = "Strafe Left"
		"input_right":
			label.text = "Strafe Right"
		"input_forward":
			label.text = "Walk Backwards"
		"input_backward":
			label.text = "Walk Forwards"
		"input_jump":
			label.text = "Jump"
		"input_crouch":
			label.text = "Crouch"
		"input_sprint":
			label.text = "Run"
		"input_pickup":
			label.text = "Pick Up"
		"input_interact":
			label.text = "Interact"
		"input_drop":
			label.text = "Drop"
		"input_inventory":
			label.text = "Inventory"

func _on_button_button_up() -> void:
	pass
