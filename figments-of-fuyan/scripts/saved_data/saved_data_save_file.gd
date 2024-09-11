class_name SavedDataSaveFile extends SavedData

@export var my_seed: int
@export var area_data: SavedDataArea
@export var shillings: int
@export var map_effects: Array
@export var time: int
@export var deck: Array

func _init(_id: int = 0, _my_seed: int = 0, _area_data: SavedDataArea = null,\
 _shillings: int = 0, _map_effects: Array = [], _time: int = 0, _deck: Array = []) -> void:
	super(_id)
	my_seed = _my_seed
	area_data = _area_data
	shillings = _shillings
	map_effects = _map_effects
	time = _time
	deck = _deck

func getInfoType() -> GDScript: return SaveFileInfo
func getChampionData() -> SavedDataCard:
	for data in deck:
		if Helper.getFofInfoID(CardInfo, data.id).rarity == Game.Rarities.CHAMPION:
			return data
	return null
