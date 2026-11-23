extends Node

@onready var player := $Player
@onready var da_monsta := $Da_Monsta
@onready var nav_region := $NavigationRegion3D
@onready var uicontrol := $UI
var bake_finished := false



func _ready() -> void:
	nav_region.connect("generation_finished", on_generation)
	uicontrol.connect("uiopen", _openui)
	for i in $Items.get_children():
		i.connect("itempickup", _itempickedup)
func on_generation():
	#if not bake_finished:
		#return
	#bake_finished = false
	nav_region.bake_navigation_mesh()
	#bake_finished = true
	
func _physics_process(_delta: float):
	da_monsta.update_target_location(player.global_transform.origin,bake_finished)

func _openui(state):
	for child in $Items.get_children():
		child._change_pickup(state)

func _itempickedup(icon,itemname,pord):
	if pord:
		$"UI/Inventar/Panel4/Rhandslot/TextureRect".texture = ImageTexture.create_from_image(icon)
	else:
		$"UI/Inventar/Panel4/Rhandslot/TextureRect".texture = null
