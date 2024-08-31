class_name SavedDataSaveFile extends SavedData

@export var my_seed: int
@export var area_data: SavedDataArea

func _init(_id: int = 0, _my_seed: int = 0, _area_data: SavedDataArea = null) -> void:
	super(_id)
	my_seed = _my_seed
	area_data = _area_data

func getInfoType() -> GDScript: return SaveFileInfo
