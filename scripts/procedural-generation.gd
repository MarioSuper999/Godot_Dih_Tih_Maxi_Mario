extends Node
signal generation_finished
const BOUNDARY_X := 1
const BOUNDARY_Y := 1
const BOUNDARY_Z := 1
@onready var box = preload("res://prefabs/rooms/box.tscn")
@onready var player = $"../Player"
var spawned_boxes: Array = []
var boxes_size: Array = []
@export var pathlen :int
var is_generating = false

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
		if len(spawned_boxes) > 1 :
			connect_signals()
		return new_box


func place_box(pos_new, new_box, branch_index):
	var attempts = 0
	new_box.position += pos_new
	while attempts <4:
		await get_tree().physics_frame
		if not is_instance_valid(spawned_boxes[branch_index]):
			new_box.queue_free()
			spawned_boxes.pop_back()
			boxes_size.pop_back()
			return false
		var prev_box = spawned_boxes[branch_index].position
		var prev_size = boxes_size[branch_index]
		if not collides(new_box):
			return true
		else:
			pos_new = get_new_pos(prev_box, new_box.get_node("CollisionShape3D").shape.size, prev_size, attempts)
			attempts += 1
			new_box.position = pos_new
	new_box.queue_free()
	spawned_boxes.pop_back()
	boxes_size.pop_back()
	return false
	

func genPath(length):
	if is_generating:
		return
	is_generating = true
	
	#print("genpath")
	#default branch index position of box -> box meaning the box which you try to put your new box next to
	var branch_index = -2
	var branch_backoff = 0
	var i = 0
	while i < length:
		var size = Vector3(randi_range(20,50),7.5,randi_range(20,50))
		
		var prev_size = boxes_size [branch_index +1 ]
		
		var pos_new = get_new_pos(spawned_boxes[branch_index + 1].position, size, prev_size,randi_range(0,3))
		
		var new_box = make_box(size)
		
		if not await place_box(pos_new, new_box, branch_index):
			if abs(branch_index) <= len(spawned_boxes):
				if abs(branch_index)+ 1 + 3* branch_backoff <= len(spawned_boxes):
					branch_index -= 1 + 3* branch_backoff
				elif abs(branch_index)+ 1 <= len(spawned_boxes):
					branch_index -= 1
				else:
					branch_index = - len(spawned_boxes) 
				#print("new Branch at:", branch_index)
				branch_backoff += 1
				i -= 1
			else:
				#print("this path is not spawnable")
				break
		else:
			branch_index = -2
			branch_backoff = 0
			emit_signal("generation_finished")
		i+=1
	#for f in range(len(spawned_boxes)):
		#print(spawned_boxes[f].position)
		#print(boxes_size[f])
	is_generating = false

func get_new_pos(pos, size, prev_size, attempt):
	var dirs = ["x_negative", "x_positive", "z_negative", "z_positive"]
	dirs.shuffle()
	var dir = dirs[attempt]
	var pos_new = pos
	var offsetx = (size.x/2) + (prev_size.x/ 2)
	var offsetz = (size.z/2) + (prev_size.z/ 2) 
	if dir == "x_negative":
		pos_new = pos + Vector3(-offsetx ,0,0)
	elif dir == "x_positive":
		pos_new = pos + Vector3(offsetx,0,0)		
	elif dir == "z_negative":
		pos_new = pos + Vector3(0,0, -offsetz)
	elif dir == "z_positive":
		pos_new = pos + Vector3(0,0,offsetz)
	return pos_new


func collides(new_box) ->  bool:
	var shape_node = new_box.get_node_or_null("Area3D/CollisionShape3D")
	if not shape_node:
		#print("k")
		return false
		
	var space_state = new_box.get_world_3d().direct_space_state
	
	var query = PhysicsShapeQueryParameters3D.new()
	query.shape = shape_node.shape
	query.transform = shape_node.global_transform
	query.exclude = [new_box.get_rid()]
	var results = space_state.intersect_shape(query)
	if results.size() > 0:
		#print("collides with", results)
		#print(new_box.position)
		return true
	#print("no collision")
	return false
	
	
func more_path(body):
	#print("got message body entered")
	if body == player:
		if	spawned_boxes[-1].get_node("Area3D").body_entered.is_connected(more_path):
				spawned_boxes[-1].get_node("Area3D").body_entered.disconnect(more_path)
		genPath(5)

func connect_signals():
	if spawned_boxes[-2].get_node("Area3D").body_entered.is_connected(more_path):
		spawned_boxes[-2].get_node("Area3D").body_entered.disconnect(more_path)
	spawned_boxes[-1].get_node("Area3D").body_entered.connect(more_path)



func _process(_delta: float) -> void:
	pass
