@tool
class_name bigtest extends Resource

var my_val = 1
@export var new_val: int

func _init() -> void:
	if my_val == 1:
		new_val = 3
