class_name SavedDataRegularLevel extends SavedDataLevel

@export var timeout: int

func _init(_id: int = 0, _timeout: int = 0) -> void:
	super(id)
	timeout = _timeout

func getInfoType() -> GDScript: return RegularLevelInfo
