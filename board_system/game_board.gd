class_name Game_Board extends Node3D

@onready var cursor: Cursor = $Cursor
@onready var game_grid: Game_Grid = $GameGrid


var selected_cell:Grid_Cell = null
var selected_unit:Unit = null

var valid_cells:Array[Grid_Cell] = []

var current_action:Action
@export var test_action:Action

func _ready() -> void:
	cursor.cursor_interacted.connect(_on_cursor_interacted)
	cursor.cursor_moved.connect(_on_cursor_moved)
		
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_released("test_skill"):
		if selected_unit:
			print('Using ', test_action.action_name)
			_initialize_action(test_action)
			
func _on_cursor_interacted(cell:Grid_Cell) -> void:
	_clear_game_grid_hints()
	
	if !cell:
		selected_cell = null
		if selected_unit:
			selected_unit.selected = false
		selected_unit = null
		valid_cells.clear()
		return
		
	if valid_cells.has(cell): 
		if selected_cell:
			if selected_unit:
				if current_action:
					current_action.act(cell)
					current_action = null
				else:
					print(selected_unit)
					selected_unit.move_along_path(game_grid.get_cell_path_to_cell(selected_cell, cell))
					selected_cell = selected_unit.current_cell
					valid_cells = game_grid.get_reachable_cells_from_cell(selected_cell, selected_unit.unit_resource.movement_range)
					game_grid.fill_cell_selection_hint(valid_cells)
				return
				
	if cell.has_object:
		selected_cell = cell
		
		if selected_cell.current_object is Unit:
			selected_unit = selected_cell.current_object as Unit
			selected_unit.selected = true
			valid_cells = game_grid.get_reachable_cells_from_cell(selected_cell, selected_unit.unit_resource.movement_range)
			game_grid.fill_cell_selection_hint(valid_cells)
	else:	
		selected_cell = null
		if selected_unit:
			selected_unit.selected = false
		selected_unit = null
		valid_cells.clear()
	
	
func _clear_game_grid_hints() -> void:
	game_grid.clear_selection_hint()
	game_grid.clear_path_hint()	
	game_grid.clear_aoe_hint()
	
func _on_cursor_moved(new_cell:Grid_Cell) -> void:
	game_grid.clear_path_hint()
	
	if !new_cell:
		return
		
	if valid_cells.is_empty():
		return
		
	if !valid_cells.has(new_cell):
		return
		
	if selected_unit:
		if current_action:
			var action_aoe:Array[Grid_Cell] = game_grid.get_reachable_cells_from_cell(new_cell, current_action.action_aoe)
			game_grid.fill_aoe_hint(action_aoe)
		else:
			game_grid.fill_path_hint(game_grid.get_cell_path_to_cell(selected_cell, new_cell))

func _initialize_action(action:Action) -> void:
	current_action = action
	_clear_game_grid_hints()
	valid_cells = game_grid.get_reachable_cells_from_cell(selected_cell, current_action.action_range)
	game_grid.fill_cell_selection_hint(valid_cells)
	
