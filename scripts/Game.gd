extends Node

@onready var player := $Player
@onready var da_monsta := $Da_Monsta
@onready var nav_region := $NavigationRegion3D
@onready var rooms := $Rooms
@onready var uicontrol := $UI

func _ready() -> void:
	rooms.connect("generation_finished", on_generation)
func on_generation():
	nav_region.bake_navigation_mesh()
	print("warum gaht das nöd :'(")
func _physics_process(delta: float):
	da_monsta.update_target_location(player.global_transform.origin)
