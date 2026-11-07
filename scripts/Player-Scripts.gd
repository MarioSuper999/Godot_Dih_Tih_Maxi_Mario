extends CharacterBody3D

@export var can_move : bool = true
@export var can_jump : bool = true
@export var can_sprint : bool = true
@export var can_lerp : bool = true
@export var flashlight_on : bool = true
@export var mouse_sensitivity := 0.002
@export_group("Speeds")
@export var base_speed : float = 7.0
@export var smooth_speed := 17.5
@export var smooth_speed_velocity := 17.5
@export var jump_velocity : float = 3.5
@export var sprint_speed : float = 10.0
@export_group("Input Actions")
@export var input_left : String = "input_left"
@export var input_right : String = "input_right"
@export var input_forward : String = "input_forward"
@export var input_back : String = "input_backward"
@export var input_jump : String = "input_jump"
@export var input_sprint : String = "input_sprint"


var mouse_captured : bool = true
var look_rotation : Vector2
var move_speed : float = 0.0
var target_rotation := Vector2.ZERO
var smooth_rotation := Vector2.ZERO
var target_velocity : Vector3
var smooth_velocity : Vector3
var weight : float = 1.0
var weight_velocity : float = 1.0

@onready var head: Node3D = $Head
@onready var collider: CollisionShape3D = $Collider
@onready var rhand: Node3D = %RHand

func _ready() -> void:
	look_rotation.y = rotation.y
	look_rotation.x = head.rotation.x

func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("left_click"):
		capture_mouse()
	if event is InputEventMouseMotion and mouse_captured:
		target_rotation.y -= event.relative.x * mouse_sensitivity
		target_rotation.x -= event.relative.y * mouse_sensitivity
		target_rotation.x = clamp(target_rotation.x,deg_to_rad(-85),deg_to_rad(85))
	
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
			weight_velocity = 1 - exp(-smooth_speed_velocity * delta)
		var input_dir := Input.get_vector(input_left, input_right, input_forward, input_back)
		var move_dir := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		smooth_velocity.x = lerp(smooth_velocity.x,move_dir.x,weight_velocity)
		smooth_velocity.z = lerp(smooth_velocity.z,move_dir.z,weight_velocity)
		velocity.x = smooth_velocity.x * move_speed
		velocity.z = smooth_velocity.z * move_speed
	else:
		velocity.x = 0
		velocity.y = 0
	
	move_and_slide()

func _process(delta: float) -> void:
	if can_lerp:
		weight = 1 - exp(-smooth_speed * delta)
	smooth_rotation.x = lerp_angle(smooth_rotation.x,target_rotation.x,weight)
	smooth_rotation.y = lerp_angle(smooth_rotation.y,target_rotation.y,weight)
	transform.basis = Basis()
	rotate_y(smooth_rotation.y)
	head.transform.basis = Basis()
	head.rotate_x(smooth_rotation.x)
	
func capture_mouse():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	mouse_captured = true
	can_move = true
func release_mouse():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	mouse_captured = false
	can_move = false
