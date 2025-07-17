class_name InfoWithTier extends InfoWithExtra

@export var tier: int
func _init(_info: FofInfo = null, _tier: int = 1) -> void:
	super(_info)
	tier = _tier

func getTier() -> int:
	return tier

func getDescription() -> String:
	return info.getDescription(tier)
