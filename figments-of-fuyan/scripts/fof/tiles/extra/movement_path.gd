class_name MovementPathGD extends Resource

@export var tiles: Array
@export var display: bool

func _init(_tiles: Array = [], _display: bool = true) -> void:
	tiles = _tiles
	display = _display
