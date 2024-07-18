class_name StatsGD
extends Resource

var array: Array
# An array of StatInfoGD

enum {
	ATTACK,
	HEALTH, # aka heal
	MAX_HEALTH,
	BOTH_HEALTH, # Buffs both max health and current health
	BOTH_SPEED, # Buffs both the current and max speed
	CURRENT_SPEED,
	MAX_SPEED,
}

func _init(info: Variant) -> void:
	array = []
	if info is Array: array = info
	elif info is StatInfoGD: array.append(info)

func add(stat_info: StatInfoGD) -> void:
	array.append(stat_info)
