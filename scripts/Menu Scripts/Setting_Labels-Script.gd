extends HBoxContainer

@onready var label: Label = $Label
@export var setting_name : String

func _ready() -> void:
	label.text = setting_name
