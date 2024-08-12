@tool
class_name Game_Grid extends Node3D

@export var grid_cells:Array[Grid_Cell]

@export_category('Debug')
@export var debug:bool:
	set = _set_debug
	
@export_subgroup('Pathfinding')
@export var test_pathfinding:bool:
	set = _set_test_pathfinding
@export var debug_pathfinding_starting_cell:Grid_Cell
@export var debug_pathfinding_max_range:int

@export var debug_pathfinding_target_cell:Grid_Cell

func get_reachable_cells_from_cell(from:Grid_Cell, max_range:int) -> Array[Grid_Cell]:
	var pathfinding:Pathfind = Pathfind.new()
	var reachable_cells:Array[Grid_Cell] = pathfinding.get_reachable_cells_in_range(from, max_range)
	return reachable_cells


func get_cell_path_to_cell(from:Grid_Cell, to:Grid_Cell) -> Array[Grid_Cell]:
	var path_cells:Array[Grid_Cell] = []
	if !grid_cells.has(to):
		return path_cells
		
	if !to.current_parent_cell:
		return path_cells
		
	var pathfinding:Pathfind = Pathfind.new()
	path_cells = pathfinding.find_path_to_cell(from, to)
			
	return path_cells

func fill_cell_selection_hint(cells:Array[Grid_Cell], clear_old:bool = true) -> void:
	if clear_old:
		clear_selection_hint()

	for cell:Grid_Cell in cells:
		cell.cell_selection_hint = true	
		
func clear_selection_hint() -> void:
	for cell:Grid_Cell in grid_cells:
		cell.cell_selection_hint = false

func fill_aoe_hint(cells:Array[Grid_Cell], clear_old:bool = true) -> void:
	if clear_old:
		clear_aoe_hint()
	
	for cell:Grid_Cell in cells:
		cell.cell_aoe_hint = true
			
func clear_aoe_hint() -> void:
	for cell:Grid_Cell in grid_cells:
		cell.cell_aoe_hint = false
		
func fill_path_hint(cells:Array[Grid_Cell], clear_old:bool = true) -> void:
	if clear_old:
		clear_path_hint()
	for cell:Grid_Cell in cells:
		cell.cell_path_hint = true
		
func clear_path_hint() -> void:
	for cell:Grid_Cell in grid_cells:
		cell.cell_path_hint = false
		

func reset_cells_pathfinding_info() -> void:
	for cell:Grid_Cell in grid_cells:
		cell.reset_cell_pathfinding()

# Editor things
func _enter_tree() -> void:
	if !child_entered_tree.is_connected(_on_child_entered_tree):
		child_entered_tree.connect(_on_child_entered_tree)
	if !child_exiting_tree.is_connected(_on_child_exiting_tree):
		child_exiting_tree.connect(_on_child_exiting_tree)
		
	if Engine.is_editor_hint():
		if !EditorInterface.get_selection().selection_changed.is_connected(_on_editor_selection_changed):
			EditorInterface.get_selection().selection_changed.connect(_on_editor_selection_changed)
		
func _on_child_entered_tree(child:Node) -> void:
	if not child is Grid_Cell:
		child.queue_free()
		return
		
	var cell:Grid_Cell = child as Grid_Cell
	if !grid_cells.has(cell):
		grid_cells.append(cell)
	
	if !cell.cell_coordinate_changed.is_connected(_on_cell_coordinate_changed):
		cell.cell_coordinate_changed.connect(_on_cell_coordinate_changed)
	
	if !cell.trying_auto_connect.is_connected(_on_cell_trying_auto_connect):
		cell.trying_auto_connect.connect(_on_cell_trying_auto_connect)
	
func _on_child_exiting_tree(child:Node) -> void:
	if grid_cells.has(child):
		grid_cells.erase(child)

func _on_cell_coordinate_changed(cell:Grid_Cell, new_coordinate:Vector3) -> void:
	pass
	
func _get_all_cells_at_coordinate(grid_coordinate:Vector3) -> Array[Grid_Cell]:
	var out:Array[Grid_Cell] = []
	for cell:Grid_Cell in grid_cells:
		if cell.cell_coordinates == grid_coordinate:
			out.append(cell)
		
	return out

func _get_all_cells_at_adjacent_coordinate(grid_coordinate:Vector3) -> Array[Grid_Cell]:
	const DIRECTIONS:Array[Vector3] = [Vector3.ZERO, Vector3.LEFT, Vector3.RIGHT, Vector3.FORWARD, Vector3.BACK]
	var out:Array[Grid_Cell] = []
	
	for cell:Grid_Cell in grid_cells:
		for direction:Vector3 in DIRECTIONS:
			if cell.cell_coordinates == grid_coordinate + direction:
				out.append(cell)
	return out
	
func _on_cell_trying_auto_connect(cell:Grid_Cell) -> void:
	var adjacent_cells:Array[Grid_Cell] = _get_all_cells_at_adjacent_coordinate(cell.cell_coordinates)
	if adjacent_cells.has(cell):
		adjacent_cells.erase(cell)
		
	cell.connected_cells = adjacent_cells
	pass

func _set_debug(value:bool) -> void:
	debug = value
	
	if !Engine.is_editor_hint():
		return

	for cell:Grid_Cell in grid_cells:
		cell.debug = debug

func _set_test_pathfinding(value:bool) -> void:
	test_pathfinding = value
	
	if !Engine.is_editor_hint():
		return
	
	for cell in grid_cells:
		cell.cell_selection_hint = false
	
	if !test_pathfinding:
		return 
		
	if !debug_pathfinding_starting_cell:
		return
		
	if !debug_pathfinding_max_range:
		return
		
	var pathfinding:Pathfind = Pathfind.new()
	var pathfinding_cells:Array[Grid_Cell] = pathfinding.get_reachable_cells_in_range(debug_pathfinding_starting_cell, debug_pathfinding_max_range)
	for cell in pathfinding_cells:
		cell.cell_selection_hint = true	
	
	if !debug_pathfinding_target_cell:
		return
	if !pathfinding_cells.has(debug_pathfinding_target_cell):
		return
	
	var path_cells:Array[Grid_Cell] = pathfinding.find_path_to_cell(debug_pathfinding_starting_cell, debug_pathfinding_target_cell)
	for cell:Grid_Cell in path_cells:
		cell.cell_path_hint = true
	
func _on_editor_selection_changed() -> void:
	var selection:EditorSelection = EditorInterface.get_selection()
	var selections_array:Array[Node] = selection.get_selected_nodes()

	_clear_debug_adjacent_hint()
	if selections_array.is_empty():
		return
	
	if !selections_array[0] is Grid_Cell:
		return
		
	for node in selections_array:
		if !grid_cells.has(node):
			return
		var cell:Grid_Cell = node as Grid_Cell
		for connected_cell:Grid_Cell in cell.connected_cells:
			connected_cell.show_adjacent_mesh_debug_hint = true
	
func _clear_debug_adjacent_hint() -> void:
	for cell:Grid_Cell in grid_cells:
		cell.show_adjacent_mesh_debug_hint = false
