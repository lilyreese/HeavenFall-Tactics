class_name Pathfind extends RefCounted

func get_reachable_cells_in_range(starting_cell:Grid_Cell, max_range:int) -> Array[Grid_Cell]:
	var visited_cells:Array[Grid_Cell] = []
	var stack:Array[Grid_Cell] = [starting_cell]
	
	starting_cell.reset_cell_pathfinding()
	
	while !stack.is_empty():
		var current_cell:Grid_Cell = stack.pop_front()
		
		if current_cell.current_cell_depth > max_range:
			continue
			
		if visited_cells.has(current_cell):
			continue
			
		visited_cells.append(current_cell)
		
		for neighbor:Grid_Cell in current_cell.connected_cells:
			if visited_cells.has(neighbor):
				continue
				
			if neighbor.has_object:
				continue
			
			neighbor.current_cell_depth = current_cell.current_cell_depth + 1

			if neighbor.current_cell_depth > max_range:
				continue
			
			neighbor.current_parent_cell = current_cell
			stack.append(neighbor)		
	
	return visited_cells
	
func find_path_to_cell(from:Grid_Cell, to:Grid_Cell) -> Array[Grid_Cell]:
	var visited_cells:Array[Grid_Cell]
	
	var current_cell = to
	
	while current_cell != from:
		visited_cells.append(current_cell)
				
		if !current_cell.current_parent_cell:
			break
			
		current_cell = current_cell.current_parent_cell
	
	visited_cells.append(from)
	visited_cells.reverse()
	return visited_cells
	
