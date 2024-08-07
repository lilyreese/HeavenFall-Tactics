@tool
class_name Test_Editor extends Node

@export var test:bool:
	set = _set_test

func _run_test() -> void:
	print(EditorInterface.get_editor_viewport_3d())

func _set_test(value:bool) -> void:
	test = value
	_run_test()
