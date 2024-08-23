class_name SavedData extends Resource

# Stores the id to the info
@export var id: int

func _init(_id: int = 0) -> void:
	id = _id
