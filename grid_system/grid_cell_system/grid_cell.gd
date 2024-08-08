@tool
class_name Grid_Cell extends Node3D

signal cell_coordinate_changed(cell:Grid_Cell,new_coordinate:Vector3)
signal trying_auto_connect(cell:Grid_Cell)

@onready var center_offset: Marker3D = $CenterOffset
@onready var grid_snap: Marker3D = $GridSnap
@onready var debug_label: Label3D = $Debug/DebugLabel

@export_category('Cell Info')
@export var selected:bool:
	set = _set_selected
@export var current_object:Grid_Object:
	set = _set_current_object
@export var has_object:bool
@export var walkable:bool

@export_category('Grid Info')
@export var grid_resource:Grid_Resource = preload("res://grid_system/grid_resource.tres")
@export var cell_coordinates:Vector3:
	set = _set_cell_coordinates
@export var snap_to_grid:bool = false:
	set = _set_snap_to_grid
	
@export_category('Pathfinding')
@export var auto_connect:bool = false:
	set = _set_auto_connect
@export var manually_connect_cell:bool:
	set = _set_manually_connect_cell
@export var both_ways_connection:bool

@export var connected_cells:Array[Grid_Cell] = []

var current_cell_depth:int = 0
var current_parent_cell:Grid_Cell = null

@export_category('Visual Overlays')
@export var path_mesh: MeshInstance3D
@export var selection_mesh: MeshInstance3D
@export var cell_selection_hint:bool = false:
	set = _set_cell_selection_hint
@export var cell_path_hint:bool = false:
	set = _set_cell_path_hint

@export_category('Debug')
@export var debug:bool:
	set = _set_debug
@export var adjacent_mesh_debug: MeshInstance3D
@export var show_adjacent_mesh_debug_hint:bool:
	set = _show_adjacent_mesh_debug_hint

func _enter_tree() -> void:
	if Engine.is_editor_hint():
		set_notify_transform(true)
		
	manually_connect_cell = false

func _set_cell_coordinates(value:Vector3) -> void:
	var old_coordinates:Vector3 = cell_coordinates
	
	cell_coordinates = value
	
	if old_coordinates != cell_coordinates:
		cell_coordinate_changed.emit(self, cell_coordinates)
		_update_debug_label()
		
	if Engine.is_editor_hint() and snap_to_grid:
		_align_position_to_grid()
		
func _set_snap_to_grid(value:bool) -> void:
	if not Engine.is_editor_hint():
		return 
		
	if snap_to_grid == value:
		return
		
	snap_to_grid = value
	
	if snap_to_grid :
		_align_position_to_grid()
		
func _align_position_to_grid() -> void:
	if position == grid_resource.to_world(cell_coordinates):
		return
		
	position = grid_resource.to_world(cell_coordinates)

func _notification(what: int) -> void:
	if not Engine.is_editor_hint():
		return
		
	if position == Vector3.ZERO:
		return
	
	if what == NOTIFICATION_TRANSFORM_CHANGED:
		if debug:
			_update_debug_label()
		cell_coordinates = grid_resource.to_grid(position)
		
func _set_auto_connect(value:bool) -> void:
	if not Engine.is_editor_hint():
		return 
		
	if auto_connect == value:
		return
			
	auto_connect = value
	
	if auto_connect:
		trying_auto_connect.emit(self)
		auto_connect = !auto_connect	
	
func _set_debug(value:bool) -> void:
	if not Engine.is_editor_hint():
		return 
		
	debug = value
	
	if debug_label:
		debug_label.visible = debug
		_update_debug_label()
	
func _update_debug_label() -> void:
	if !debug_label:
		return
	debug_label.global_position = center_offset.global_position
	debug_label.text = str(name, '\n', cell_coordinates, '\n', current_cell_depth)

func _set_cell_selection_hint(value:bool) -> void:
	cell_selection_hint = value
	selection_mesh.visible = cell_selection_hint
	
	if !cell_selection_hint:
		cell_path_hint = false

func _set_cell_path_hint(value:bool) -> void:
	cell_path_hint = value
	path_mesh.visible = cell_path_hint

func reset_cell_pathfinding() -> void:
	current_cell_depth = 0
	current_parent_cell = null

func _set_selected(value:bool) -> void:
	selected = value
	
func _set_current_object(value:Grid_Object) -> void:
	current_object = value
	if current_object:
		has_object = true
	else: 
		has_object = false

func _show_adjacent_mesh_debug_hint(value:bool) -> void:
	show_adjacent_mesh_debug_hint = value
	adjacent_mesh_debug.visible = value

func _set_manually_connect_cell(value:bool) -> void:
	manually_connect_cell = value
	if Engine.is_editor_hint():
		if !EditorInterface.get_selection().selection_changed.is_connected(_on_editor_selection_changed):
			EditorInterface.get_selection().selection_changed.connect(_on_editor_selection_changed)
	
	if !manually_connect_cell:
		if Engine.is_editor_hint():
			if EditorInterface.get_selection().selection_changed.is_connected(_on_editor_selection_changed):
				EditorInterface.get_selection().selection_changed.disconnect(_on_editor_selection_changed)
				
func _on_editor_selection_changed() -> void:
	if !manually_connect_cell:
		return
		
	var selection:EditorSelection = EditorInterface.get_selection()
	var selections_array:Array[Node] = selection.get_selected_nodes()
	if selections_array.is_empty():
		manually_connect_cell = false
		return
		
	if selections_array[0] == self:
		return
		
	if !selections_array[0] is Grid_Cell:
		selection.remove_node(selections_array[0])
		selection.add_node(self)
		return
		
	if selections_array.is_empty():
		manually_connect_cell = false
		return
		
	for node in selections_array:
		if !node is Grid_Cell:
			continue 

		var cell:Grid_Cell = node as Grid_Cell
	
		if connected_cells.has(cell):
			connected_cells.erase(cell)
			if both_ways_connection:
				if cell.connected_cells.has(self):
					cell.connected_cells.erase(self)
		elif !connected_cells.has(cell):
			connected_cells.append(cell)
			if both_ways_connection:
				if !cell.connected_cells.has(self):
					cell.connected_cells.append(self)
			
		selection.remove_node(cell)
		break
		
	selection.add_node(self)
