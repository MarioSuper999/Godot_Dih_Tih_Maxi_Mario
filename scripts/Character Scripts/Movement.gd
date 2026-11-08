extends CharacterBody3D

@export var can_move : bool = true
@export var can_jump : bool = true
@export var can_sprint : bool = true
@export var can_lerp : bool = true
@export var flashlight_on : bool = true
@export_group("Speeds")
@export var base_speed : float = 7.0
@export var smooth_speed := 17.5
@export var jump_velocity : float = 3
@export var sprint_speed : float = 10.0
@export_group("Input Actions")
@export var input_left : String = "input_left"
@export var input_right : String = "input_right"
@export var input_forward : String = "input_forward"
@export var input_back : String = "input_backward"
@export var input_jump : String = "input_jump"
@export var input_sprint : String = "input_sprint"

var move_speed : float = 0.0
var weight_velocity : float = 0.0
var target_velocity : Vector3
var smooth_velocity : Vector3

@onready var head: Node3D = $Head
@onready var collider: CollisionShape3D = $Collider

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
	if can_jump:
		if Input.is_action_just_pressed(input_jump) and is_on_floor():
			velocity.y = jump_velocity
	if can_sprint and Input.is_action_pressed(input_sprint):
			move_speed = sprint_speed
			flashlight_on = false
	else:
		move_speed = base_speed
	if can_move:
		if can_lerp:
			weight_velocity = 1 - exp(-smooth_speed * delta)
		var input_dir := Input.get_vector(input_left, input_right, input_forward, input_back)
		var move_dir := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		smooth_velocity.x = lerp(smooth_velocity.x,move_dir.x,weight_velocity)
		smooth_velocity.z = lerp(smooth_velocity.z,move_dir.z,weight_velocity)
		velocity.x = move_dir.x * move_speed
		velocity.z = move_dir.z * move_speed
	else:
		velocity.x = 0
		velocity.y = 0
	move_and_slide()
