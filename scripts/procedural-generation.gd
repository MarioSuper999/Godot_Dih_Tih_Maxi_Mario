extends Node
signal generation_finished
const BOUNDARY_X := 1
const BOUNDARY_Y := 1
const BOUNDARY_Z := 1
@onready var box = preload("res://prefabs/rooms/box.tscn")
var spawned_boxes: Array = []
var boxes_size: Array = []
@export var pathlen :int
@onready var pposition = $"../Player".global_position

func _ready() -> void:
	var pos = Vector3(0,0,0)
	
	var spawn_box = make_box(Vector3(20,7.5,20))
	spawn_box.position = pos	
	genPath(pos, pathlen)
	await $"..".ready
	emit_signal("generation_finished")
	

func make_box(size):
		
		var new_box = box.instantiate()
		add_child(new_box)
		
		var collision_node = new_box.get_node("CollisionShape3D")
		collision_node.shape = collision_node.shape.duplicate()
		collision_node.shape.size = size 
		
		var mesh_node = new_box.get_node("MeshInstance3D")
		mesh_node.scale = size
		
		var area_collision_node = new_box.get_node("Area3D/CollisionShape3D")
		area_collision_node.shape = area_collision_node.shape.duplicate()
		area_collision_node.shape.size = size 
		
		spawned_boxes.append(new_box)
		boxes_size.append(size)
		
		return new_box

func genPath(pos, length):
	var i = len(spawned_boxes)
	while i < length + 1:
		var size = Vector3(randi_range(20,50),7.5,randi_range(20,50))
		
		var prev_size = boxes_size [i - 1]
		
		var pos_new = get_new_pos(pos, size, prev_size)
		
		var new_box = make_box(size)
		
		new_box.position += pos_new
		
		if collides(new_box):
			new_box.queue_free()
			spawned_boxes.remove_at(-1)
			boxes_size.remove_at(-1)
		else:
			pos = pos_new
		i = len(spawned_boxes)


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
	var area_node = new_box.get_node("Area3D")
	for boxes in spawned_boxes:
		var boxes_area = boxes.get_node("Area3D")
		if area_node.overlaps_area(boxes_area):
			return true
	return false
	


func _process(_delta: float) -> void:
	pass
