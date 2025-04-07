class_name PalmIslandDecoration extends Resource

@export var data: Array
@export var coords: Vector4
@export var tile_rotation: int

func _init(_data: Array = []) -> void:
	data = _data
