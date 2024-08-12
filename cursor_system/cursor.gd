class_name Cursor extends Node3D
const RAY_LENGTH = 1000

signal cursor_moved(to)
signal cursor_interacted(at_cell)

@onready var mesh_instance_3d: MeshInstance3D = $MeshInstance3D

@export_category("Grid Info")
@export var current_cell:Grid_Cell

var _over_valid_cell:bool = false

func _unhandled_input(event: InputEvent) -> void:
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		return
		
	if event is InputEventMouseMotion:
		if !_cast_ray_to_unit():
			_cast_ray_to_ground()
		
	if event.is_action_released("cursor_interact"):
		if _over_valid_cell:
			cursor_interacted.emit(current_cell)
		else:
			cursor_interacted.emit(null)
	

func _cast_ray_to_ground() -> void:
	var space_state:PhysicsDirectSpaceState3D = get_world_3d().direct_space_state
	var cam:Camera3D = get_viewport().get_camera_3d()
	var mousepos:Vector2 = get_viewport().get_mouse_position()

	var origin:Vector3 = cam.project_ray_origin(mousepos)
	var end:Vector3 = origin + cam.project_ray_normal(mousepos) * RAY_LENGTH
	var query:PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(origin, end, 256)

	var result:Dictionary = space_state.intersect_ray(query)
	
	if !result:
		_over_valid_cell = false
		mesh_instance_3d.hide()
		current_cell = null
	else:
		mesh_instance_3d.show()
		_over_valid_cell = true
		current_cell = result['collider'].owner
		
		var tween = create_tween()
		tween.set_ease(Tween.EASE_OUT_IN)
		tween.set_trans(Tween.TRANS_LINEAR)
		tween.tween_property(self, "global_position", current_cell.center_offset.global_position, 0.1)
	
	cursor_moved.emit(current_cell)

func _cast_ray_to_unit() -> bool:
	var space_state:PhysicsDirectSpaceState3D = get_world_3d().direct_space_state
	var cam:Camera3D = get_viewport().get_camera_3d()
	var mousepos:Vector2 = get_viewport().get_mouse_position()

	var origin:Vector3 = cam.project_ray_origin(mousepos)
	var end:Vector3 = origin + cam.project_ray_normal(mousepos) * RAY_LENGTH
	var query:PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(origin, end, 4096)

	var result:Dictionary = space_state.intersect_ray(query)
	
	if !result:
		return false
	
	mesh_instance_3d.show()
	_over_valid_cell = true
	current_cell = result['collider'].owner.current_cell
	
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT_IN)
	tween.set_trans(Tween.TRANS_LINEAR)
	tween.tween_property(self, "global_position", current_cell.center_offset.global_position, 0.1)
	
	cursor_moved.emit(current_cell)
	
	return true
