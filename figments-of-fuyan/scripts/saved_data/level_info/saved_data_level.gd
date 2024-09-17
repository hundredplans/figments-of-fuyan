class_name SavedDataLevel extends SavedData
	
@export var timeout: int
func _init(_id: int = 0, _first_init: bool = false, _timeout: int = 0) -> void:
	super(_id, _first_init)
	timeout = _timeout
	
func getInfoType() -> GDScript: return LevelInfo
