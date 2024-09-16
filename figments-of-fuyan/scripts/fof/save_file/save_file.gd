class_name SaveFileGD extends FofGD

signal load_level
signal update_shillings

var id: int
var my_seed: int
var area: AreaGD
var shillings: int
var map_effects_data: Array
var time: int
var last_loaded_deck: Array

var timer: Timer

#region Save / Load
func onSaveToFile() -> void:
	#if !Helper.getAdmin():
	var saved_data: SavedDataSaveFile = onSave()
	saved_data.resource_path = SaveFileInfo.SAVE_DIRECTORY + str(id) + ".tres"
	ResourceSaver.save(saved_data)

func onSave() -> SavedData:
	var map_effects: Array = SavedData.onSaveGroup(get_tree().get_nodes_in_group("MapEffectsGD"))
	var deck_cards: Array = SavedData.onSaveGroup(get_tree().get_nodes_in_group("DeckCardsGD"))
	var boons: Array = SavedData.onSaveGroup(get_tree().get_nodes_in_group("BoonsGD"))
	time += int(timer.wait_time - timer.time_left)
	return SavedDataSaveFile.new(id, false, my_seed, area.onSave(), shillings, map_effects, time, deck_cards, boons)

func onLoadData(data: SavedData) -> void:
	super(data)
	id = data.id
	my_seed = data.my_seed
	
	var ChampionCard: CardGD
	for card_data in data.deck:
		var Card: CardGD = SavedData.onLoadModel(card_data, get_parent())
		if Game.isChampion(Card.info.rarity): ChampionCard = Card
	
	area = SavedData.onLoadModel(data.area_data, get_parent(), [ChampionCard])
	area.load_level.connect(func(): load_level.emit())
	
	shillings = data.shillings
	map_effects_data = data.map_effects
	time = data.time
	last_loaded_deck = data.deck
	
	timer = Timer.new()
	timer.wait_time = 99999999999
	add_child(timer)
	timer.start()
	
	add_to_group("SaveFilesGD")
	
func setInfo(_area: AreaGD) -> void:
	area = _area
#endregion

#region Base Functions
func _tree_exited() -> void:
	onSaveToFile()
	
func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		onSaveToFile()
#endregion

#region Getters
func getShillings() -> int:
	return shillings
	
func onUpdateShillings(delta: int) -> void:
	shillings += delta
	update_shillings.emit(shillings)
	
func getChampionCard() -> CardGD:
	for Card in get_tree().get_nodes_in_group("DeckCardsGD"):
		if Game.isChampion(Card.info.rarity): return Card
	return null
#endregion
