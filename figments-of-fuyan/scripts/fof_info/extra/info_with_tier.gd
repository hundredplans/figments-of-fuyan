class_name InfoWithTier extends Resource

@export var info: FofInfo
@export var tier: int
func _init(_info: FofInfo = null, _tier: int = 1) -> void:
	info = _info
	tier = _tier

func getTier() -> int:
	return tier

func getDescription(use_default_values: bool = false) -> String:
	return info.getDescription(tier, use_default_values)
