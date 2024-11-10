class_name VisionDatastore extends Resource

@export var level_visible: bool
@export var is_revealed: bool
@export var turns: int

func _init(_level_visible: bool = false, _is_revealed: bool = false, _turns: int = 0) -> void:
	level_visible = _level_visible
	is_revealed = _is_revealed
	turns = _turns
