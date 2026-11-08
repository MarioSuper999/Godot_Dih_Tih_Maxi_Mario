extends Node
signal generation_finished
signal box_made
const BOUNDARY_X := 1
const BOUNDARY_Y := 1
const BOUNDARY_Z := 1
@onready var box = preload("res://prefabs/rooms/box.tscn")
var spawned_boxes: Array = []
var boxes_size: Array = []
@export var pathlen :int
@onready var pposition = $"../Player".global_position
@onready var player = $"../Player"

func _ready() -> void:
	make_box(Vector3(20,7.5,20))	
	genPath(pathlen)
	await $"..".ready
	

func make_box(size):
		var new_box = box.instantiate()
		add_child(new_box)
		
		var collision_node = new_box.get_node("CollisionShape3D")
		collision_node.shape = collision_node.shape.duplicate()
		collision_node.shape.size = size 
		
		var mesh_node = new_box.get_node("MeshInstance3D")
		mesh_node.scale = size
		
		var area_node = new_box.get_node("Area3D")
		area_node.scale = size + Vector3(0,5,0)
		
	
		spawned_boxes.append(new_box)
		boxes_size.append(size)
		if len(spawned_boxes) > 1: 
			connect_signals()
		return new_box


func place_box(pos_new, new_box, branch_index):
	new_box.position += pos_new
	var attempts = 0
	while attempts <5:
		if not collides(new_box):
			return true
		else:
			attempts += 1
			pos_new = get_new_pos(spawned_boxes[branch_index].position, new_box.get_node("CollisionShape3D").scale, boxes_size[branch_index])
	
	new_box.queue_free()
	spawned_boxes.remove_at(-1)
	boxes_size.remove_at(-1)
	return false
	

func genPath(length):
	print("genpath")
	#default branch index position of box -> box meaning the box which you try to put your new box next to
	var branch_index = -2
	for i in range(length):
		var size = Vector3(randi_range(20,50),7.5,randi_range(20,50))
		
		var prev_size = boxes_size [i - 1]
		
		var pos_new = get_new_pos(spawned_boxes[-1].position, size, prev_size)
		
		var new_box = make_box(size)
		
		if not place_box(pos_new, new_box, branch_index):
			if abs(branch_index) < len(spawned_boxes):
				branch_index -= 1
				print("new Branch")
			else:
				print("this path is not spawnable")
				break
			i -= 1
		else:
			branch_index = -2
			emit_signal("generation_finished")


func get_new_pos(pos, size, prev_size):
	var pos_new = pos
	var offset = (size + prev_size) / 2 
	var dir = -1 * (randi_range(0,1) * 2 - 1) 
	if randi() % 2 == 0:
		pos_new = pos + Vector3(offset.x * dir ,0,0)
	else:
		pos_new = pos + Vector3(0,0,offset.z * dir )
	return pos_new


func collides(new_box) ->  bool:
	var shape_node = new_box.get_node_or_null("Area3D/CollisionShape3D")
	if not shape_node:
		print("k")
		return false
		
	var space_state = new_box.get_world_3d().direct_space_state
	
	var query = PhysicsShapeQueryParameters3D.new()
	query.shape = shape_node.shape
	query.transform = shape_node.global_transform
	query.exclude = [new_box]
	var results = space_state.intersect_shape(query)
	if results.size() > 0:
		print("collides")
		return true
	print("no collision")
	return false
	
func more_path(body):
	print("got message body entered")
	if body == player:
		genPath(5)

func connect_signals():
	spawned_boxes[-1].get_node("Area3D").body_entered.connect(more_path)
	if spawned_boxes[-2].get_node("Area3D").body_entered.is_connected(more_path):
		spawned_boxes[-2].get_node("Area3D").body_entered.disconnect(more_path)


func _process(_delta: float) -> void:
	pass
