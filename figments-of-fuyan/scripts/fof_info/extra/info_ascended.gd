class_name InfoAscended extends Resource

@export var info: FofInfo
@export var ascended: bool

func _init(_info: FofInfo = null, _ascended: bool = false) -> void:
	info = _info
	ascended = _ascended
