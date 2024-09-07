class_name SavedDataSaveFile extends SavedData

@export var my_seed: int
@export var area_data: SavedDataArea
@export var shillings: int
@export var map_effects: Array

func _init(_id: int = 0, _my_seed: int = 0, _area_data: SavedDataArea = null,\
 _shillings: int = 0, _map_effects: Array = []) -> void:
	super(_id)
	my_seed = _my_seed
	area_data = _area_data
	shillings = _shillings
	map_effects = _map_effects

func getInfoType() -> GDScript: return SaveFileInfo
