extends Control

var openui : bool
@onready var Inventar := $Inventar
@onready var player = preload("res://scenes/player.tscn")


func _process(_delta: float) -> void:
	if get_node_or_null("res://scenes/player.tscn"):
		var trues = []
		for i in get_children():
			trues.append(i.visible)
		if true in trues:
			openui = true
			player.release_mouse()
		else:
			openui = false
			player.capture_mouse()
		if Input.is_action_just_pressed("inventar"):
			if not openui or Inventar.visible:
				Inventar.visible = not Inventar.visible
