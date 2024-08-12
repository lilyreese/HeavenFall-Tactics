class_name Action extends Resource

@export_category('Action Info')
@export var action_name:String = 'Default Action'
@export var action_icon:Texture
@export_multiline var action_description:String = 'This is a default Action'

@export_category('Action Behaviour')
@export var action_range:int = 1
@export var action_aoe:int = 0


func act(target_cell:Grid_Cell) -> void:
	print(action_name, ' at cell ', target_cell)
