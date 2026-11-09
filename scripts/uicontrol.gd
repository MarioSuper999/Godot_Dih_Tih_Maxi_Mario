extends Control

var openui : bool
@onready var Inventar := $Inventar
signal uiopen

func _process(_delta: float) -> void:
	var trues = []
	for i in get_children():
		trues.append(i.visible)
	if true in trues:
		openui = true
		$"../Player".release_mouse()
	else:
		openui = false
		$"../Player".capture_mouse()
	emit_signal("uiopen", openui)
	if Input.is_action_just_pressed("inventar"):
		if not openui or Inventar.visible:
			Inventar.visible = not Inventar.visible
