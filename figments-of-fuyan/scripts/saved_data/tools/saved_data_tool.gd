class_name SavedDataTool extends SavedData

@export var active_effects: Array[ActiveEffectDatastore]
@export var charges: int
@export var ability_save: Dictionary
@export var tier: int

func _init(_id: int = 0, _first_init: bool = false, _public_id: int = 0, _active_effects: Array[ActiveEffectDatastore] = [],\
 	_charges: int = 0, _ability_save: Dictionary = {}, _tier: int = 1) -> void:
	super(_id, _first_init, _public_id)
	active_effects = _active_effects
	charges = _charges
	ability_save = _ability_save
	tier = _tier

func getInfoType() -> GDScript: return ToolInfo

func onTierUp() -> void:
	tier = min(tier + 1, 4)
