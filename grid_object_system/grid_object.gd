@tool
class_name Grid_Object extends Path3D

@export var current_cell:Grid_Cell:
	set = _set_current_cell

func _init() -> void:
	if Engine.is_editor_hint():
		set_notify_transform(true)
		return

	curve = Curve3D.new()

func _set_current_cell(value:Grid_Cell) -> void:
	var old_cell:Grid_Cell = current_cell
	current_cell = value
	if current_cell:
		current_cell.current_object = self
	
	if old_cell and old_cell != current_cell:
		old_cell.current_object = null

func _notification(what: int) -> void:
	if not Engine.is_editor_hint():
		return
		
	if position == Vector3.ZERO:
		return
	
	if what == NOTIFICATION_TRANSFORM_CHANGED:
		current_cell = _try_finding_cell_down()
		_adjust_position_to_cell()

func _adjust_position_to_cell() -> void:
	if !current_cell:
		return
	global_position = current_cell.center_offset.global_position

func _try_finding_cell_down() -> Grid_Cell:
	var space_state:PhysicsDirectSpaceState3D = get_world_3d().direct_space_state
	
	var origin:Vector3 = position + (Vector3.UP * 1)
	var end:Vector3 = origin + (Vector3.DOWN * 3)
	var query:PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(origin, end, 256)
	
	var result:Dictionary = space_state.intersect_ray(query)
	if result:
		var cell:Grid_Cell = result['collider'].owner
		if cell.has_object:
			if cell.current_object != self:
				return null
		
		return cell
	
	return null
