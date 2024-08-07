@tool
class_name Grid_Resource extends Resource

@export var cell_size:float = 1:
	set=_set_cell_size

var cell_size_vector:Vector3 = Vector3.ONE * cell_size
var half_cell:Vector3 = (Vector3(1,0,1) * cell_size) / 2

func to_world(grid_coordinate:Vector3) -> Vector3:
	var world_position:Vector3 = (grid_coordinate * cell_size) + half_cell
	return world_position
	
func to_grid(world_position:Vector3) -> Vector3:
	var grid_coordinate:Vector3 = (world_position / cell_size_vector).floor()
	return grid_coordinate

func _set_cell_size(value:float) -> void:
	cell_size = value
	cell_size_vector = Vector3.ONE * cell_size
	half_cell = (Vector3(1,0,1) * cell_size) / 2
