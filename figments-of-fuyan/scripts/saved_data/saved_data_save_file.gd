class_name SavedDataSaveFile extends SavedData

@export var my_seed: int
@export var area_data: SavedDataArea
@export var shillings: int
@export var time: int
@export var ally_cards: Array
@export var boons: Array
@export var highest_public_id: int
@export var world_difficulty: int # Default starts at 1
@export var max_energy: int
@export var energy_limit: int
@export var deck_slots: Array # [DeckSlot]
@export var stash_sort_type: int
@export var area_ids: Array

func _init(_id: int = 0, _first_init: bool = false, _public_id: int = 0, _my_seed: int = 0, _area_data: SavedDataArea = null,\
 _shillings: int = 0, _time: int = 0, _ally_cards: Array = [], _boons: Array = [], _highest_public_id: int = 0,\
	_world_difficulty: int = 1, _max_energy: int = 0,\
	_energy_limit: int = 0, _deck_slots: Array = [], _stash_sort_type: int = 0, _area_ids: Array = []) -> void:
	super(_id, _first_init, _public_id)
	my_seed = _my_seed
	area_data = _area_data
	shillings = _shillings
	time = _time
	ally_cards = _ally_cards
	boons = _boons
	highest_public_id = _highest_public_id
	world_difficulty = _world_difficulty
	max_energy = _max_energy
	energy_limit = _energy_limit
	deck_slots = _deck_slots
	stash_sort_type = _stash_sort_type
	area_ids = _area_ids

func getInfoType() -> GDScript: return SaveFileInfo
func getChampionData() -> SavedDataCard:
	for card_data: SavedDataCard in ally_cards:
		if Helper.getFofInfoID(CardInfo, card_data.id).rarity == Game.Rarities.CHAMPION:
			return card_data
	return null
