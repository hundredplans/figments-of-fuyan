class_name SaveFileGD extends FofGD

signal load_map
signal load_level
signal update_shillings
signal update_toolbelt

var id: int
var my_seed: int
var area: AreaGD
var last_loaded_deck: Array
var map_effects_data: Array
var tool_belt: Array
var boons: Array

var shillings: int
var time: int

var timer: Timer

#region Helper
func getChampionCard() -> CardGD:
	for Card in get_tree().get_nodes_in_group("AllyCardsGD"):
		if Game.isChampion(Card.info.rarity): return Card
	return null
#endregion

#region Save / Load
func onSaveToFile() -> void:
	#if !Helper.getAdmin():
	var saved_data: SavedDataSaveFile = onSave()
	saved_data.resource_path = SaveFileInfo.SAVE_DIRECTORY + str(id) + ".tres"
	ResourceSaver.save(saved_data)

func onSave() -> SavedData:
	var map_effects: Array = SavedData.onSaveGroup(get_tree().get_nodes_in_group("MapEffectsGD"))
	var deck_cards: Array = SavedData.onSaveGroup(get_tree().get_nodes_in_group("AllyCardsGD"))
	var tool_belt_data: Array = SavedData.onSaveGroup(tool_belt)
	var highest_public_id: int = Game.highest_public_id
	boons = SavedData.onSaveGroup(boons)
	time = getTimeElapsed()
	
	return SavedDataSaveFile.new(id, false, public_id, my_seed, area.onSave(), shillings,\
	map_effects, time, deck_cards, boons, highest_public_id, tool_belt_data)

func onLoadData(data: SavedData) -> void:
	super(data)
	id = data.id
	my_seed = data.my_seed
	
	var ChampionCard: CardGD
	for card_data in data.deck:
		var Card: CardGD = SavedData.onLoadModel(card_data, get_parent())
		Card.add_to_group("AllyCardsGD")
		if Game.isChampion(Card.info.rarity): ChampionCard = Card
	
	boons = data.boons.map(func(x: SavedDataBoon): return SavedData.onLoadModel(x, self))
	tool_belt = data.tool_belt.map(func(x: SavedDataTool): return SavedData.onLoadModel(x, self))
	
	area = SavedData.onLoadModel(data.area_data, get_parent(), [ChampionCard])
	area.load_level.connect(onLoadLevel)
	
	shillings = data.shillings
	map_effects_data = data.map_effects
	time = data.time
	last_loaded_deck = data.deck
	
	timer = Timer.new()
	timer.wait_time = 99999999
	add_child(timer)
	timer.start()
	
	add_to_group("SaveFilesGD")
	
func onFofInit() -> void:
	var boon_info: BoonInfo = getChampionCard().info.boon_info
	SavedData.onLoadModel(boon_info.saved_data.new(boon_info.id, true), self)
	
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

#region Shillings
func getShillings() -> int:
	return shillings
	
func onUpdateShillings(delta: int) -> void:
	shillings += delta
	update_shillings.emit(shillings)
#endregion

#region Load Level / Map
func onLoadLevel(level_data: SavedDataLevel) -> void:
	load_level.emit(level_data, self, area)
	
func onLoadMap() -> void:
	load_map.emit(self, area)
	
func onLoadGame() -> void:
	if area.level_data == null: onLoadMap()
	else: onLoadLevel(area.level_data)
#endregion

#region Timer
func getTimeElapsed() -> int:
	return time + int(timer.wait_time - timer.time_left)
#endregion

#region Tools
func onUpdateToolbelt(Tool: ToolGD) -> void:
	if !Tool.is_inside_tree():
		add_child(Tool)
	elif Tool.get_parent() != self:
		Tool.reparent(self)
		
	tool_belt.append(Tool)
	update_toolbelt.emit(tool_belt)
	
func onRemoveToolFromToolbelt(Tool: ToolGD) -> void:
	tool_belt.erase(Tool)
	remove_child(Tool)
#endregion

#region Boons
func onAddBoon(Boon: BoonGD) -> void:
	boons.append(Boon)
	if !Boon.is_inside_tree():
		add_child(Boon)
		
	elif Boon.get_parent() != self:
		Boon.reparent(self)
	
func onRemoveBoon(boon: BoonGD) -> void:
	boons.erase(boon)
#endregion
