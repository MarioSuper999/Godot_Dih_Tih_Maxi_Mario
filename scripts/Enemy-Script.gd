extends CharacterBody3D

@export var base_speed : float = 5.0
@export var sprint_speed : float = 7.5

@onready var nav_agent = $NavigationAgent3D

var behavioral_attributes := ["normal","lurking","aggressive","semi_random"]
var actional_attributes := ["venting","checking","running","crawling","climbing","sight"]
var scary_attributes := ["paranoia","schizophrenia"]
var mby_zu_schwierig_zu_machen_oder_nicht_geeignet_fuer_singleplyer_attributes := ["mimicry"]
var current_attributes := []

var current_behavior : String = behavioral_attributes.pick_random()
var is_spawned : bool = false
var has_target : bool = true
var move_speed : float = 0.0
var bake_is_finished := false

func _ready() -> void:
	pass
func _process(delta: float) -> void:
	pass
func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += get_gravity().y * delta
	if current_attributes.has("running") and target_in_running_range():
		move_speed = sprint_speed
	else:
		move_speed = base_speed
	if has_target and bake_is_finished:
		var current_location = global_transform.origin
		var next_location = nav_agent.get_next_path_position()
		var new_velocity = (next_location - current_location).normalized() * move_speed
		var direction := global_position.direction_to(next_location)
		
		velocity = velocity.move_toward(new_velocity, 0.33 * delta * 20)
		print(nav_agent.is_navigation_finished(),next_location,current_location)
	move_and_slide()
	
# pathfinding functions here:
func update_target_location(target_location,bake_status):
	nav_agent.target_position = target_location
	bake_is_finished = bake_status
func pathfinding():
	pass
func target_in_running_range():
	pass

# functions for actional attributes here:
func venting():
	pass
func checking():
	pass
func running():
	pass
func crawling():
	pass
func climbing():
	pass
func sight():
	pass

# functions for scary attributes here:
func mimicry():
	pass
func paranoia():
	pass
func schizophrenia():
	pass
