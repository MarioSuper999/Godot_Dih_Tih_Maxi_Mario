extends Node

@onready var player := $Player
@onready var da_monsta := $Da_Monsta
@onready var nav_region := $NavigationRegion3D
@onready var uicontrol := $UI

const PLAYER = preload("uid://d2xrw5swb5xo0")

var bake_finished := false


func _ready() -> void:
	nav_region.connect("generation_finished", on_generation)




#func _physics_process(delta: float):
	#da_monsta.update_target_location($player.global_transform.origin,bake_finished)

		
func on_generation():
	if nav_region.is_baking():
		await nav_region.bake_finished
	nav_region.bake_navigation_mesh()
	await nav_region.bake_finished
	bake_finished = true
