extends Node
signal generation_finished
const BOUNDARY_X := 1
const BOUNDARY_Y := 1
const BOUNDARY_Z := 1
@onready var box_template = preload("res://prefabs/rooms/box_template.tscn")
@onready var player = $"../Player"
var spawned_boxes: Array = []
var boxes_size: Array = []
@export var pathlen :int
var is_generating = false

func _ready() -> void:
	get_box("square")	
	genPath(pathlen)
	await $"..".ready
	

func get_box(type):
	var box = box_template.instantiate()
	add_child(box)
	var result = box.box_innit(type)
	var size = result[0]
	spawned_boxes.append(box)
	boxes_size.append(size)
	if len(spawned_boxes) > 1 :
		box.position = Vector3(100,0,100)
		connect_signals()
	return [box, result]



func place_box(box, branch_index, results):
	await get_tree().physics_frame
	if not is_instance_valid(spawned_boxes[branch_index]):
		box.queue_free()
		spawned_boxes.pop_back()
		boxes_size.pop_back()
		return false
	var axis = results[1]
	var size = results[0]
	
	var prev_size = boxes_size[branch_index]
	if not move_box(branch_index, size, prev_size, axis, box):
		print("k")
		return false
	print("i")
	return true
	
	#return false
	

func genPath(length):
	if is_generating:
		return
	is_generating = true
	#print("genpath")
	#default branch index position of box -> box meaning the box which you try to put your new box next to
	var branch_index := -2
	var branch_backoff := 0
	var i := 0
	var boxes_attempted := 0
	while i < length:
		var info = get_box("any")
		var box = info[0]
		var results = info[1]
		var is_placed = await place_box(box, branch_index, results)
		if not is_placed and boxes_attempted > 5:
			if abs(branch_index) < len(spawned_boxes):
				branch_index -= 1
			#if abs(branch_index)+ 1 + 1 * branch_backoff <= len(spawned_boxes):
				#branch_index -= 1 + 1*  branch_backoff
				#branch_backoff += 1
			#elif abs(branch_index) < len(spawned_boxes):
				#branch_index -= 1
			else:
				print("this path is not spawnable")
				break
		elif boxes_attempted > 5:
			branch_index = -2
			branch_backoff = 0
			boxes_attempted = 0
		else:
			boxes_attempted += 1
		if is_placed:
			i+=1
	#for f in range(len(spawned_boxes)):
		#print(spawned_boxes[f].position)
		#print(boxes_size[f])
	emit_signal("generation_finished")
	is_generating = false

func  move_box(branch_index, size, prev_size, axis, box):
	var pos_old = spawned_boxes[branch_index].position
	var dir = [-1,1].pick_random()
	var offsetx = (size.x/2) + (prev_size.x/ 2)
	var offsetz = (size.z/2) + (prev_size.z/ 2) 
	if axis == "x":
		box.position = pos_old + Vector3(offsetx * dir,0,0)
	elif axis == "z":
		box.position = pos_old + Vector3(0,0,offsetz * dir)
	if collides(box):
		dir = dir * -1
		if axis == "x":
			box.position = pos_old + Vector3(offsetx * dir,0,0)
		elif axis == "z":
			box.position = pos_old + Vector3(0,0,offsetz * dir)
	if collides(box):
		box.queue_free()
		spawned_boxes.pop_back()
		boxes_size.pop_back()
		return false
	return true


func collides(box) ->  bool:
	var shape_node = box.get_node_or_null("Area3D/CollisionShape3D")
	if not shape_node:
		#print("k")
		return true
	
	var space_state = box.get_world_3d().direct_space_state
	
	var query = PhysicsShapeQueryParameters3D.new()
	query.shape = shape_node.shape
	query.transform = shape_node.global_transform
	query.exclude = [box.get_rid()]
	var results = space_state.intersect_shape(query)
	if results.size() > 0:
		#print("collides with", results)
		#print(box.position)
		return true
	#print("no collision")
	return false
	
	
func more_path(body):
	#print("got message body entered")
	if body == player:
		if	spawned_boxes[-5].get_node("Area3D").body_entered.is_connected(more_path):
				spawned_boxes[-5].get_node("Area3D").body_entered.disconnect(more_path)
		genPath(pathlen)

func connect_signals():
	if len(spawned_boxes) > 6:
		if spawned_boxes[-6].get_node("Area3D").body_entered.is_connected(more_path):
			spawned_boxes[-6].get_node("Area3D").body_entered.disconnect(more_path)
		if not spawned_boxes[-5].get_node("Area3D").body_entered.is_connected(more_path):
			spawned_boxes[-5].get_node("Area3D").body_entered.connect(more_path)



func _process(_delta: float) -> void:
	pass
