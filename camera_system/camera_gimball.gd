class_name Camera_Gimball extends Node3D

@export var grid_resource:Grid_Resource = preload("res://grid_system/grid_resource.tres")

@onready var grid_position: Marker3D = $GridPosition
@onready var horizontal_gimball: Marker3D = $GridPosition/HorizontalGimball
@onready var vertical_gimball: Marker3D = $GridPosition/HorizontalGimball/VerticalGimball
@onready var camera: Camera3D = $GridPosition/HorizontalGimball/VerticalGimball/Camera
@onready var target_visual: MeshInstance3D = $Target_Visual

@export_category("Camera Control")
@export_subgroup("Movement")
@export_range(0.001, 0.1) var mouse_sensitivity:float = 0.001
@export var movement_speed:float = 2

var movement_input:Vector2 = Vector2.ZERO:
	set = _set_movement_input
var camera_rotation_mode:bool = false:
	set = _set_camera_rotation_mode
	
var _current_cell:Grid_Cell:
	set = _set_current_cell
	
@export_subgroup("Zoom")
@export var max_zoom:float = 20.0
@export var min_zoom:float = 0.4
@export_range(0.05, 1.0) var zoom_speed:float = 0.5
var zoom = 1.5

func _unhandled_input(event: InputEvent) -> void:
	#Handle Camera Rotation
	if event.is_action_pressed("camera_rotate"):
		camera_rotation_mode = true		
	if event.is_action_released("camera_rotate"):
		camera_rotation_mode = false
		
	if camera_rotation_mode:
		if event is InputEventMouseMotion:
			if event.relative.x != 0:
				horizontal_gimball.rotate_object_local(Vector3.UP, event.relative.x * mouse_sensitivity)
			if event.relative.y != 0:
				var y_rotation = clamp(event.relative.y, -30, 30)
				vertical_gimball.rotate_object_local(Vector3.RIGHT, -y_rotation * mouse_sensitivity)
	
	#Handle Camera Zoom
	if event.is_action_pressed("camera_zoom_in"):
		zoom -= zoom_speed
	if event.is_action_pressed("camera_zoom_out"):
		zoom += zoom_speed	
	
	zoom = clamp(zoom, min_zoom, max_zoom)

	#Handle Camera Movement
	movement_input = Input.get_vector("camera_move_left", "camera_move_right", "camera_move_forward", "camera_move_back")
	
func _set_camera_rotation_mode(value:bool) -> void:
	camera_rotation_mode = value
	if camera_rotation_mode:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	else:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _process(delta: float) -> void:
	vertical_gimball.rotation.x = clamp(vertical_gimball.rotation.x, -1.4, -0.01)
	horizontal_gimball.scale = lerp(scale, Vector3.ONE * zoom, zoom_speed)
	
	var movement_vector:Vector3 = horizontal_gimball.basis * (Vector3(movement_input.x, 0, movement_input.y))
	position += movement_vector * delta * movement_speed
	
func _set_current_cell(value:Grid_Cell) -> void:
	_current_cell = value
	
func _set_movement_input(value:Vector2) -> void:
	movement_input = value
