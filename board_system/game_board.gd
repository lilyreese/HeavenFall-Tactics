class_name Game_Board extends Node3D

@onready var cursor: Cursor = $Cursor
@onready var game_grid: Game_Grid = $GameGrid

var selected_cell:Grid_Cell = null

var valid_cells:Array[Grid_Cell] = []
	
func _ready() -> void:
	cursor.cursor_interacted.connect(_on_cursor_interacted)
	cursor.cursor_moved.connect(_on_cursor_moved)
	
	
func _on_cursor_interacted(cell:Grid_Cell) -> void:
	if !game_grid.grid_cells.has(cell):
		selected_cell = null
		game_grid._reset_cells_pathfinding_info()
		game_grid._clear_selection_hint()
		game_grid._clear_path_hint()

		return
	
	if cell.has_object:
		selected_cell = cell
		
		var unit:Unit = selected_cell.current_object
		
		unit.selected = true
		valid_cells = game_grid.fill_reachable_cells_from_cell(selected_cell, unit.unit_resource.movement_range)
		return
	
	if selected_cell:
		if valid_cells.has(cell) and selected_cell.has_object:
			var unit:Unit = selected_cell.current_object
			unit.move_along_path(game_grid.fill_path_hint_to_cell(selected_cell, cell))
	
	game_grid._reset_cells_pathfinding_info()
	game_grid._clear_selection_hint()
	game_grid._clear_path_hint()
	
func _on_cursor_moved(new_cell:Grid_Cell) -> void:
	if selected_cell:
		if selected_cell.has_object:
			game_grid.fill_path_hint_to_cell(selected_cell, new_cell)
