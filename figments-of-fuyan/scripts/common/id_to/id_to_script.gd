class_name IdToScript extends Resource

@export var id: int
@export var gdscript: GDScript

func _init(_id: int = 0, _gdscript: GDScript = null) -> void:
	id = _id
	gdscript = _gdscript
