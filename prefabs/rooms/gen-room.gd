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

func get_room_type():
	var size = Vector3()
	var dir = ["z","x"].pick_random()
	var room_type = room_dict[types.pick_random()]
	var short_side = randi_range(room_type[0].x,room_type[0].y)
	if dir == "z":
		size = Vector3(short_side * randi_range(room_type[1].x,room_type[1].y),7.5,short_side)
	elif dir == "x":
		size = Vector3(short_side,7.5,short_side * randi_range(room_type[1].x,room_type[1].y))
	else:
		print("fuck you")
	return size
	
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
