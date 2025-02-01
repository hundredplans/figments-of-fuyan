class_name EliteFightNodeGD extends FightNodeGD

var curse_info: BoonInfo
const MAX_RESTART_AMOUNT: int = 16

func onFofInit() -> void:
	super()
	setLevelInfo()
	var empty_spawn_coords: Array = getEmptySpawnCoords(level_info)
	var base_budget: int = getBudget()
	var enemy_spawn_amount: int = min(randi_range(level_info.enemy_min_spawn_amount, level_info.enemy_max_spawn_amount), empty_spawn_coords.size() - 1)
	var chief_spawn_coords: Vector4i = empty_spawn_coords.pop_front()
	var chief_infos: Array = Game.area.basic_card_ids.map(func(x: int): return Helper.getFofInfoID(CardInfo, x)).filter(func(x: CardInfo): return x.rarity == Game.Rarities.EXALT)
	setChiefAndSpawns(base_budget, empty_spawn_coords, enemy_spawn_amount, chief_infos, chief_spawn_coords)
	
func setChiefAndSpawns(base_budget: int, empty_spawn_coords: Array, enemy_spawn_amount: int, chief_infos: Array, chief_spawn_coords: Vector4i) -> void:
	var chief_data: SavedDataCard = getChief(chief_infos, chief_spawn_coords)
	
	var ChiefCard: CardGD = SavedData.onLoadModel(chief_data, self)
	ChiefCard.queue_free()
	Game.setCardDataFromInfo(chief_data, Helper.getFofInfoID(CardInfo, chief_data.id))
	
	var budget: int = max(base_budget - chief_data.energy, 0)
	enemy_spawns = Game.area.setEnemySpawnsFromBudget(max(base_budget - chief_data.energy, 0), enemy_spawn_amount, empty_spawn_coords, map_location.progress, true)
	
	var restart_amount: int = 0
	while(!ChiefCard.isValidEliteLevelSpawns(enemy_spawns) and restart_amount < MAX_RESTART_AMOUNT):
		enemy_spawns = Game.area.setEnemySpawnsFromBudget(budget, enemy_spawn_amount, empty_spawn_coords, map_location.progress, true)
		restart_amount += 1
		
	if restart_amount >= MAX_RESTART_AMOUNT:
		setChiefAndSpawns(base_budget, empty_spawn_coords, enemy_spawn_amount, chief_infos, chief_spawn_coords)
		return
	enemy_spawns.append(chief_data)
	
func onSave() -> SavedDataMapNode:
	return SavedDataEliteFight.new(info.id, false, public_id, map_location, links, is_entered, is_finished, rotation.y, level_info, enemy_spawns)
	
func onEntered() -> void:
	onSelectRandomCurseInfo()
	super()
	
func onSelectRandomCurseInfo() -> void:
	var curse_infos: Array = Helper.getFofInfoArray(BoonInfo).filter(func(x: BoonInfo): return x.elite_fight_curse)
	
	if Helper.admin_datastore.force_elite_fight_curse_id == 0:
		curse_info = onGenerateCurseInfo(curse_infos)
	else:
		curse_info = Helper.getFofInfoID(BoonInfo, Helper.admin_datastore.force_elite_fight_curse_id)
		var curse: BoonGD = SavedData.onLoadModel(curse_info.saved_data.new(curse_info.id, true), self)
		Game.save_file.onAddBoon(curse)
	
func onGenerateCurseInfo(curse_infos: Array) -> BoonInfo:
	var _curse_info: BoonInfo = curse_infos.pick_random()
	curse_infos.erase(_curse_info)
	var curse: BoonGD = SavedData.onLoadModel(_curse_info.saved_data.new(_curse_info.id, true), self)
	
	if !curse.isAddRequirementMet():
		curse.queue_free()
		return onGenerateCurseInfo(curse_infos)
	
	Game.save_file.onAddBoon(curse)
	return _curse_info
	
func onFinished() -> void:
	super()
	var new_level_data: SavedDataLevel = level_info.saved_data.new(level_info.id, true, 0, level_info.data.duplicate(), enemy_spawns)
	new_level_data.is_elite = true
	load_level.emit(new_level_data)

#region Level Gen
func getBudget() -> int:
	return Game.area.getBudget(map_location.progress + 1, level_info.enemy_budget_offset, Game.isDivinus() and !isHoly())
	
func getChief(chief_infos: Array, chief_spawn_coords: Vector4i) -> SavedDataCard:
	var exalt_info: CardInfo = chief_infos.pick_random()
	chief_infos.erase(exalt_info)
	var card_data: SavedDataCard = exalt_info.saved_data.new(exalt_info.id, true)
	card_data.ascended = true
	card_data.team = 1
	card_data.coords = chief_spawn_coords
	
	var add_tool: bool = Random.rollFloat(Game.area.getWorld().tool_enemy_spawn_rate / 100.0)
	if add_tool:
		card_data.tool_data = Random.getRandomFofByOdds(ToolInfo, Game.area.getWorld().tool_enemy_spawn_rarity_odds.getDictionary())
		
	return card_data
#endregion
