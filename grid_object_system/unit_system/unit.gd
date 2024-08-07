@tool
class_name Unit extends Grid_Object

@onready var path_follow_3d: PathFollow3D = $PathFollow3D
@export var unit_resource:Unit_Resource

@export var selected:bool:
	set = _set_selected
	
var movement_array:Array[Grid_Cell] = []
var is_moving:bool = false
	
func _set_selected(value:bool) -> void:
	selected = value
	print(unit_resource.unit_name, ' set Selected: ', selected)

func move_along_path(cells_path:Array[Grid_Cell]) -> void:
	if is_moving:
		return
		
	movement_array = cells_path

	if movement_array.is_empty():
		return
	
	is_moving = true
	_reset_movement_path()
	
	current_cell = movement_array[-1]
	
	for cell:Grid_Cell in cells_path:
		curve.add_point(to_local(cell.center_offset.global_position))
	
	_tween_movement()

func _tween_movement() -> void:
	if movement_array.is_empty():
		_finish_movement()
		return
	
	var tween_speed:float = unit_resource.seconds_per_cell * movement_array.size() 
	
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_SINE)
	
	tween.tween_property(path_follow_3d, "progress_ratio", 1, tween_speed)
	
	tween.tween_callback(_finish_movement)

func _finish_movement() -> void:
	_reset_movement_path()
	is_moving = false
	
func _reset_movement_path() -> void:
	path_follow_3d.position = Vector3.ZERO
	path_follow_3d.progress = 0
	global_position = current_cell.center_offset.global_position
	curve.clear_points()
