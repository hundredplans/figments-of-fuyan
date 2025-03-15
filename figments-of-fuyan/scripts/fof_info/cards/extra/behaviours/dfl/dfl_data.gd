class_name DFLData extends Resource

var tiles_to_value: Dictionary
var kill_path: Array

func _init(_tiles_to_value: Dictionary = {}, _kill_path: Array = []) -> void:
	tiles_to_value = _tiles_to_value
	kill_path = _kill_path
