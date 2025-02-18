class_name SavedDataSaveFile extends SavedData

@export var my_seed: int
@export var area_data: SavedDataArea
@export var shillings: int
@export var time: int
@export var deck: Array
@export var boons: Array
@export var highest_public_id: int
@export var tool_belt: Array
@export var safe_encounter_count: int # Default starts at 1
@export var upgrade_level: int

func _init(_id: int = 0, _first_init: bool = false, _public_id: int = 0, _my_seed: int = 0, _area_data: SavedDataArea = null,\
 _shillings: int = 0, _time: int = 0, _deck: Array = [], _boons: Array = [], _highest_public_id: int = 0,\
	_tool_belt: Array = [], _safe_encounter_count: int = 1, _upgrade_level: int = 0) -> void:
	super(_id, _first_init, _public_id)
	my_seed = _my_seed
	area_data = _area_data
	shillings = _shillings
	time = _time
	deck = _deck
	boons = _boons
	highest_public_id = _highest_public_id
	tool_belt = _tool_belt
	safe_encounter_count = _safe_encounter_count
	upgrade_level = _upgrade_level

func getInfoType() -> GDScript: return SaveFileInfo
func getChampionData() -> SavedDataCard:
	for data in deck:
		if Helper.getFofInfoID(CardInfo, data.id).rarity == Game.Rarities.CHAMPION:
			return data
	return null
