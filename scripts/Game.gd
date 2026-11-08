extends Node

@onready var player := $Player
@onready var da_monsta := $Da_Monsta
@onready var nav_region := $NavigationRegion3D
@onready var uicontrol := $UI

var bake_finished := false

func _ready() -> void:
	nav_region.connect("generation_finished", on_generation)
func on_generation():
	nav_region.bake_navigation_mesh()
	await nav_region.bake_finished
	bake_finished = true
	
func _physics_process(delta: float):
	da_monsta.update_target_location(player.global_transform.origin,bake_finished)
