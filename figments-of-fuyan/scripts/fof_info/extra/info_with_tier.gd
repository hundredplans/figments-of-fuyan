class_name InfoWithTier extends Resource

@export var info: FofInfo
@export var tier: int
func _init(_info: FofInfo = null, _tier: int = 1) -> void:
	info = _info
	tier = _tier

func getTier() -> int:
	return tier

func getDescription() -> String:
	return info.getDescription(tier)
