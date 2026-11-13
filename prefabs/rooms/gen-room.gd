extends StaticBody3D
var room_dict = {
	# example = [Vector2(min_short_side,max_short_side), Vector2(min_ration,max_ratio)]
	square = [Vector2(50, 100), Vector2(1,1)],
	long = [Vector2(20, 50), Vector2(4,6)],
}
var types = ["square", "long"]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func make_box():
	var size = Vector3()
	var axis = ["z","x"].pick_random()
	var dir = [1,-1].pick_random()
	var room_type = room_dict[types.pick_random()]
	var short_side = randi_range(room_type[0].x,room_type[0].y)
	if axis == "z":
		size = Vector3(short_side * randi_range(room_type[1].x,room_type[1].y),7.5,short_side)
	elif axis == "x":
		size = Vector3(short_side,7.5,short_side * randi_range(room_type[1].x,room_type[1].y))
	else:
		print("fuck you")
		#del_system32()
		return
	var collision_node = self.get_node("CollisionShape3D")
	collision_node.shape = collision_node.shape.duplicate()
	collision_node.shape.size = size 
	
	var mesh_node = self.get_node("MeshInstance3D")
	mesh_node.scale = size
	
	var area_node = self.get_node("Area3D")
	area_node.scale = size + Vector3(0,5,0)
	
	return [size, axis, dir, room_type]

	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
