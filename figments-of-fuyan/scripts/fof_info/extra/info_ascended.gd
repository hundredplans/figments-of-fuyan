class_name InfoAscended extends InfoWithExtra

@export var ascended: bool
func _init(_info: FofInfo = null, _ascended: bool = false) -> void:
	super(_info)
	ascended = _ascended

func getDescription() -> String:
	return info.getDescription(ascended)
