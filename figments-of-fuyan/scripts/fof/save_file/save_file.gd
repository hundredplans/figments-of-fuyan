class_name SaveFileGD extends FofGD

signal load_map
signal load_main_menu
signal load_level
signal exit_save
signal update_shillings
signal input_saved

var id: int
var my_seed: int
var area: AreaGD
var boons: Array

var shillings: int
var time: int
var world_difficulty: int
var max_energy: int

var deck_slots: Array # [DeckSlot]
var energy_limit: int
var timer: Timer
var stash_sort_type: int

#region Helper
func getChampionCard() -> CardGD:
	for Card in get_tree().get_nodes_in_group("AllyCardsGD"):
		if Game.isChampion(Card.info.rarity): return Card
	return null
#endregion

#region Save / Load
func onSaveToFile() -> void:
	var saved_data: SavedDataSaveFile = onSave()
	saved_data.resource_path = SaveFileInfo.SAVE_DIRECTORY + str(id) + ".tres"
	
	ResourceSaver.save(saved_data)

func onSave() -> SavedData:
	var ally_cards: Array = SavedData.onSaveGroup(get_tree().get_nodes_in_group("AllyCardsGD"))
	var highest_public_id: int = Game.highest_public_id
	var saved_boons: Array = SavedData.onSaveGroup(boons)
	var time_elapsed: int = getTimeElapsed()
	
	return SavedDataSaveFile.new(id, false, public_id, my_seed, area.onSave(), shillings, time_elapsed,\
	ally_cards, saved_boons, highest_public_id, world_difficulty,\
	max_energy, energy_limit, deck_slots, stash_sort_type)

func onLoadData(data: SavedData) -> void:
	super(data)
	get_tree().set_auto_accept_quit(false)
	Game.save_file = self
	add_to_group("SaveFilesGD")
	id = data.id
	my_seed = data.my_seed
	max_energy = data.max_energy
	energy_limit = data.energy_limit
	deck_slots = data.deck_slots
	stash_sort_type = data.stash_sort_type
	
	for card_data: SavedDataCard in data.ally_cards:
		var Card: CardGD = SavedData.onLoadModel(card_data, get_parent())
		Card.add_to_group("AllyCardsGD")
	
	world_difficulty = data.world_difficulty
	boons = data.boons.map(func(x: SavedDataBoon): return SavedData.onLoadModel(x, self))
	
	if data.area_data != null:
		var _area: AreaGD = SavedData.onLoadModel(data.area_data, get_parent())
		_area.load_level.connect(onLoadLevel)
		setArea(_area)
	
	shillings = data.shillings
	time = data.time
	
	timer = Timer.new()
	timer.wait_time = 99999999
	add_child(timer)
	timer.start()
	
func onFofInit() -> void:
	var boon_info: BoonInfo = getChampionCard().info.boon_info
	var actions: Array = [AddToDeckAction.new(getChampionCard()), AddBoonAction.new(boon_info.id, 1),\
		getPlayerDeckUpgradeAction(0)]
	
	onPushAction(actions)
	onChooseArea()
	
func setInfo(_area: AreaGD) -> void:
	setArea(_area)
	
func setArea(_area: AreaGD) -> void:
	area = _area
	
func setStashSortType(_stash_sort_type: int) -> void:
	stash_sort_type = _stash_sort_type

func getStashSortType() -> int:
	return stash_sort_type
	
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("Save"):
		onSaveToFile()
		input_saved.emit()
#endregion

#region Base Functions
func _tree_exited() -> void:
	onSaveToFile()
	
func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		if Game.ActionManagerReference.getActionsByType(ExitGameAction).is_empty():
			onAppendAction(ExitGameAction.new())
#endregion

#region Shillings
func getShillings() -> int:
	return shillings
#endregion

#region Load Level / Map / Main Menu
func onLoadLevel(level_data: SavedDataLevel) -> void:
	load_level.emit(level_data, self, area)
	
func onLoadMap() -> void:
	load_map.emit(self, area)
	
func onLoadMainMenu() -> void:
	onSaveToFile()
	load_main_menu.emit()
	
func onLoadGame() -> void:
	if area.active_level_data == null: onLoadMap()
	else: onLoadLevel(area.active_level_data)
	
func onAreaFinished() -> void:
	world_difficulty += 1
	area.queue_free()
	
	await get_tree().process_frame # Important for everything to despawn
	onChooseArea()
	onLoadMap()
	area.init_load.emit()
	
func onChooseArea() -> void:
	var valid_areas: Array = [1, 3]
	if area != null: valid_areas.erase(area.info.id)
	if area == null and Helper.admin_datastore.starting_area_id > 0:
		valid_areas = valid_areas.filter(func(x: int):\
			return x == Helper.admin_datastore.starting_area_id)
			
	var area_id: int = valid_areas.pick_random()
	var area_data: SavedDataArea = SavedDataArea.new(area_id, true)
	var _area: AreaGD = SavedData.onLoadModel(area_data, get_parent())
	_area.load_level.connect(onLoadLevel)
	setArea(_area)
#endregion

#region Timer
func getTimeElapsed() -> int:
	return time + int(timer.wait_time - timer.time_left)
#endregion

#region Boons
func getBoons() -> Array:
	return boons
	
func getBoon(boon_id: int) -> BoonGD:
	for Boon: BoonGD in boons:
		if Boon.info.id == boon_id: return Boon
	return null
#endregion

#region Game Loss
func onGameLost() -> void:
	DirAccess.remove_absolute(SaveFileInfo.SAVE_DIRECTORY + str(id) + ".tres")
	exit_save.emit()
#endregion

func onProcessAction(action: Action) -> void:
	super(action)
	if action.post:
		if action is ChangeShillingsAction:
			update_shillings.emit()
		elif action is ExitGameAction:
			onSaveToFile()
			get_tree().quit()

#region Player Deck Upgrade
func onPlayerDeckUpgrade(player_deck_upgrade: PlayerDeckUpgrade) -> void:
	if player_deck_upgrade == null: assert(false); return
	energy_limit += player_deck_upgrade.energy_limit_gain
	deck_slots += range(player_deck_upgrade.deck_limit_gain).map(func(__: int): return DeckSlot.new())
	max_energy += player_deck_upgrade.max_energy_gain
	
func getPlayerDeckUpgradeAction(world: int, fight_type := Game.FightTypes.NULL) -> PlayerDeckUpgradeAction:
	var DIR: String = info.PLAYER_DECK_UPGRADE_DIRECTORY
	var player_deck_upgrades := Array(DirAccess.get_files_at(DIR)).map(func(x: String): return load(DIR + x))
	var player_deck_upgrade: PlayerDeckUpgrade = null
	for _player_deck_upgrade: PlayerDeckUpgrade in player_deck_upgrades:
		if _player_deck_upgrade.world == world and _player_deck_upgrade.fight_type == fight_type:
			player_deck_upgrade = _player_deck_upgrade
			break
			
	if player_deck_upgrade == null: assert(false); return
	var player_deck_upgrade_action := PlayerDeckUpgradeAction.new(player_deck_upgrade)
	return player_deck_upgrade_action
	
func getDeckSlots() -> Array:
	return deck_slots
	
func isCardValidForDeck(Card: CardGD) -> bool:
	var is_energy_limit_unmet: bool = getEnergyLimit() >= Card.energy + getDecksTotalEnergy()
	var is_slot_available: bool = deck_slots.any(func(x: DeckSlot): return !x.isUsed())
	return is_energy_limit_unmet and is_slot_available

func getDecksTotalEnergy() -> int:
	var total: int = 0
	for deck_slot: DeckSlot in deck_slots:
		total += 0 if !deck_slot.isCardUsed() else Game.onFindPublicIDObject(deck_slot.card_public_id).energy
	return total
	
func getFirstAvailableDeckSlot() -> DeckSlot:
	return deck_slots.filter(func(x: DeckSlot): return !x.isUsed())[0]
	
func getUsedDeckSlotCount() -> int:
	return deck_slots.filter(func(x: DeckSlot): return x.isCardUsed()).size()
	
func getDeckSlotByPublicID(card_public_id: int) -> DeckSlot:
	for deck_slot: DeckSlot in deck_slots:
		if deck_slot.card_public_id == card_public_id:
			return deck_slot
	return null
	
func getDeckLimit() -> int:
	return deck_slots.size()
	
func getEnergyLimit() -> int:
	return energy_limit
	
func getMaxEnergy() -> int:
	return max_energy
#endregion

func getWorldDifficulty() -> int:
	return world_difficulty
