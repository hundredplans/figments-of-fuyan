class_name EliteFightNodeGD extends FightNodeGD

var curse_id: int
const MAX_RESTART_AMOUNT: int = 16

func onFofInit() -> void:
	setLevelInfo()
	spawn_group = level_info.getRandomSpawnGroup()
	var enemy_spawns: Array = level_info.getEnemySpawnsInGroup(spawn_group) # Array[SavedDataSpawn]
	enemy_spawns.shuffle()
	
	var base_budget: int = getBudget()
	var chief_spawn_coords: Vector4i = enemy_spawns.pop_front().coords
	
	var other_chief_ids: Array = get_tree().get_nodes_in_group("EliteFightMapNodesGD")\
		.filter(func(x: MapNodeGD): return x != self)\
		.map(func(x: MapNodeGD): return x.getChiefFromCards().id)
	
	var chief_infos: Array = Game.area.basic_card_ids\
		.map(func(x: int): return Helper.getFofInfoID(CardInfo, x))\
		.filter(func(x: CardInfo): return x.rarity == Game.Rarities.EXALT and x.id not in other_chief_ids)
	
	setChiefAndSpawns(base_budget, enemy_spawns, level_info.enemy_min_spawn_amount, level_info.enemy_max_spawn_amount - 1, chief_infos, chief_spawn_coords)
	setRandomCurseID()
	
func setChiefAndSpawns(base_budget: int, enemy_spawns: Array, min_spawn_amount: int, max_spawn_amount: int, chief_infos: Array, chief_spawn_coords: Vector4i) -> void:
	var chief_data: SavedDataCard = getChief(chief_infos, chief_spawn_coords)
	
	var ChiefCard: CardGD = SavedData.onLoadModel(chief_data, self)
	ChiefCard.queue_free()
	Game.setCardDataFromInfo(chief_data, Helper.getFofInfoID(CardInfo, chief_data.id))
	
	var budget: int = max(base_budget - chief_data.energy, 0)
	enemy_cards = Game.area.setEnemySpawnsFromBudget(max(base_budget - chief_data.energy, 0), min_spawn_amount, max_spawn_amount, enemy_spawns, map_location.progress, true)
	
	while(!ChiefCard.isValidEliteLevelSpawns(enemy_cards)):
		enemy_cards = Game.area.setEnemySpawnsFromBudget(budget, min_spawn_amount, max_spawn_amount, enemy_spawns, map_location.progress, true)
		
	level_preview = Game.getArea().getLevelPreview(enemy_cards)
	level_preview.setChiefData(chief_data, true)
	
	enemy_cards.append(chief_data)
	
func onSave() -> SavedDataMapNode:
	return SavedDataEliteFight.new(info.id, false, public_id, map_location, links, is_entered, is_finished, rotation.y, ability_save, level_info,\
		spawn_group, enemy_cards, level_preview, curse_id)
	
func onLoadData(data: SavedData) -> void:
	super(data)
	curse_id = data.curse_id
	add_to_group("EliteFightMapNodesGD")
	
func onEntered() -> void:
	super()
	
func setRandomCurseID() -> void:
	if Helper.admin_datastore.force_elite_fight_curse_id == 0:
		var existing_curse_ids: Array = get_tree().get_nodes_in_group("EliteFightMapNodesGD").map(func(x: MapNodeGD): return x.curse_id)
		var curse_infos: Array = Helper.getFofInfoArray(BoonInfo).filter(func(x: BoonInfo): return x.elite_fight_curse and x.id not in existing_curse_ids)
		curse_id = onGenerateCurseID(curse_infos)
	else: curse_id =  Helper.admin_datastore.force_elite_fight_curse_id
	
func onGenerateCurseID(curse_infos: Array) -> int:
	var _curse_info: BoonInfo = curse_infos.pick_random()
	curse_infos.erase(_curse_info)
	var curse: BoonGD = SavedData.onLoadModel(_curse_info.saved_data.new(_curse_info.id, true), self)
	curse.onClear()
	if !curse.isAddRequirementMet():
		return onGenerateCurseID(curse_infos)
	
	return curse.info.id
	
func onFinished() -> void:
	super()
	var new_level_data: SavedDataLevel = level_info.saved_data.new(level_info.id, true, 0, level_info.data.duplicate())
	new_level_data.spawn_group = spawn_group
	new_level_data.level_preview = level_preview
	new_level_data.enemy_cards = enemy_cards
	new_level_data.fight_type = Game.FightTypes.ELITE
	new_level_data.curse_id = curse_id
	load_level.emit(new_level_data)

#region Level Gen
func getBudget() -> int:
	return Game.area.getBudget(map_location.progress + 1, level_info.enemy_budget_offset)
	
func getChief(chief_infos: Array, chief_spawn_coords: Vector4i) -> SavedDataCard:
	var exalt_info: CardInfo = chief_infos.pick_random()
	chief_infos.erase(exalt_info)
	
	var card_data: SavedDataCard = exalt_info.saved_data.new(exalt_info.id, true)
	card_data.tier = Game.getArea().getWorldDifficulty() + 1
	card_data.team = 1
	card_data.coords = chief_spawn_coords
	
	var add_tool: bool = Random.rollFloat(Game.area.getWorld().tool_enemy_spawn_rate)
	if add_tool:
		card_data.tool_data = Random.getRandomToolData(Game.getArea().getWorld().getToolEnemySpawnRarityOdds(),\
			Game.getArea().getWorld().getToolEnemySpawnTierOdds())
	return card_data
#endregion

func getChiefFromCards() -> SavedDataCard:
	var chief_tier: int = Game.getArea().getWorldDifficulty() + 1
	return enemy_cards.filter(func(y: SavedDataCard): return y.tier == chief_tier and Helper.getFofInfoID(CardInfo, y.id).rarity == Game.Rarities.EXALT)[0]
