extends Node

@onready var da_monsta := $Da_Monsta
@onready var nav_region := $NavigationRegion3D
@onready var uicontrol := $UI

const PLAYER = preload("uid://d2xrw5swb5xo0")

var is_a_player_spawned := false
var players : Array[CharacterBody3D]
var bake_finished := false

func _ready() -> void:
	NetworkingScript.host_created.connect(on_host_created)
	nav_region.connect("generation_finished", on_generation)
#func _physics_process(delta: float):
	#if is_a_player_spawned:
		#da_monsta.update_target_location($player.global_transform.origin,bake_finished)
func on_host_created() -> void:
	spawn_player(multiplayer.get_unique_id())
	multiplayer.peer_connected.connect(spawn_player)
func spawn_player(peer_id : int) -> void:
	var new_player := PLAYER.instantiate() as CharacterBody3D
	new_player.name = str(peer_id)
	add_child(new_player)
	initialize_player(new_player)
func initialize_player(player : CharacterBody3D) -> void:
	player.position = $SpawnPoint.position
	for other in players:
		player.add_collision_exception_with(other)
	is_a_player_spawned = true
	players.append(player)
func _on_host_pressed() -> void:
	NetworkingScript.host_lobby()
func _on_multiplayer_spawner_spawned(node: Node) -> void:
	if node is CharacterBody3D:
		initialize_player(node)
		
func on_generation():
	if nav_region.is_baking():
		await nav_region.bake_finished
	nav_region.bake_navigation_mesh()
	await nav_region.bake_finished
	bake_finished = true
