extends Node
signal generation_finished
#signal box_made
const BOUNDARY_X := 1
const BOUNDARY_Y := 1
const BOUNDARY_Z := 1
@onready var box = preload("res://prefabs/rooms/box.tscn")
var spawned_boxes: Array = []
var boxes_size: Array = []
@export var pathlen : int = 50
@onready var pposition = $"../Player".global_position

func _ready() -> void:
	#connect("box_made", connect_signals)
	var pos = Vector3(0,0,0)
	
	var spawn_box = make_box(Vector3(20,7.5,20))
	spawn_box.position = pos
	genPath(pos, pathlen)
	

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
		
		#var area_collision_node = new_box.get_node("Area3D/CollisionShape3D")
		#area_collision_node.shape = area_collision_node.shape.duplicate()
		#area_collision_node.shape.size = size 
		
		
		spawned_boxes.append(new_box)
		boxes_size.append(size)
		if len(spawned_boxes) > 1: 
			#emit_signal("box_made")
			connect_signals()
		return new_box

func genPath(pos, length):
	var attempts = 0
	var i = len(spawned_boxes)
	while i < length + 1:
		var size = Vector3(randi_range(20,50),7.5,randi_range(20,50))
		
		var prev_size = boxes_size [i - 1]
		
		var pos_new = get_new_pos(pos, size, prev_size)
		
		var new_box = make_box(size)
		
		new_box.position += pos_new
		
		if await collides(new_box) and attempts < 5:
			attempts += 1
			new_box.queue_free()
			spawned_boxes.remove_at(-1)
			boxes_size.remove_at(-1)
		elif attempts == 5:
			new_box.queue_free()
			spawned_boxes.remove_at(-1)
			boxes_size.remove_at(-1)
			break
		else:
			pos = pos_new
		i = len(spawned_boxes)
	generation_finished.emit()


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
	await get_tree().physics_frame
	var area_node = new_box.get_node("Area3D")
	for boxes in spawned_boxes:
		if not boxes:
			var boxes_area = boxes.get_node("Area3D")
			print("f")
			if area_node.overlaps_area(boxes_area):
				return true
	print("h")
	return false
	
func more_path(_body):
	print("i")
	var last_box_position = spawned_boxes[-1].position
	genPath(last_box_position,5)

func connect_signals():
	spawned_boxes[-1].get_node("Area3D").body_entered.connect(more_path)
	if len(spawned_boxes) > 2:
		spawned_boxes[-2].get_node("Area3D").body_entered.disconnect(more_path)


func _process(_delta: float) -> void:
	pass
