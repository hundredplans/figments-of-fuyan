class_name SavedDataSaveFile extends SavedData

@export var my_seed: int
@export var area_data: SavedDataArea
@export var shillings: int
@export var map_effects: Array
@export var time: int
@export var deck: Array
@export var boons: Array

func _init(_id: int = 0, _first_init: bool = false, _my_seed: int = 0, _area_data: SavedDataArea = null,\
 _shillings: int = 0, _map_effects: Array = [], _time: int = 0, _deck: Array = [], _boons: Array = []) -> void:
	super(_id, _first_init)
	my_seed = _my_seed
	area_data = _area_data
	shillings = _shillings
	map_effects = _map_effects
	time = _time
	deck = _deck
	boons = _boons

func getInfoType() -> GDScript: return SaveFileInfo
func getChampionData() -> SavedDataCard:
	for data in deck:
		if Helper.getFofInfoID(CardInfo, data.id).rarity == Game.Rarities.CHAMPION:
			return data
	return null
