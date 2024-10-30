class_name SavedDataTool extends SavedData

@export var ascended: bool
@export var active_effects: Array[ActiveEffectDatastore]
@export var ability_save: Dictionary

func _init(_id: int = 0, _first_init: bool = false, _public_id: int = 0, _ascended: bool = false, _active_effects: Array[ActiveEffectDatastore] = [], _ability_save: Dictionary = {}) -> void:
	super(_id, _first_init, _public_id)
	ascended = _ascended
	active_effects = _active_effects
	ability_save = _ability_save

func getInfoType() -> GDScript: return ToolInfo
