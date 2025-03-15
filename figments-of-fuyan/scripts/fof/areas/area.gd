class_name AreaGD extends FofGD

#region Global
signal init_load
signal load_level
signal process_action

var map_location_to_node: Dictionary
var basic_card_ids: Array = []
var active_level: LevelGD
#endregion

#region Saved Data
var map_nodes_data: Array = []

var active_map_node_data: SavedDataMapNode # Data of the last entered map node
var active_level_data: SavedDataLevel
var encountered_encounter_ids: Array = []
#endregion

#region Helper
func getWorldDifficulty() -> int:
	return info.world.world
	
func getWorld() -> WorldDatastore:
	return info.world

func onFindEmptyMapSpot(progress: int, lane: int) -> EmptyMapNode:
	for empty_map_spot in empty_spots:
		if empty_map_spot.progress == progress and empty_map_spot.lane == lane: return empty_map_spot
	return null
	
func getProgress() -> int:
	var data: Array = get_tree().get_nodes_in_group("MapNodesGD")
	if data.is_empty(): data = map_nodes_data
	return data.filter(func(x: Variant): return x.is_entered).map(func(x: Variant): return x.map_location.progress).max()
#endregion

#region Save / Load
func onSave() -> SavedDataArea:
	var save_map_nodes_data: Array = map_nodes_data.duplicate()
	if map_nodes_data.is_empty(): # If not loaded into a level get the most recent patch
		save_map_nodes_data = SavedData.onSaveGroup(get_tree().get_nodes_in_group("MapNodesGD"))
	
	active_level_data = active_level.onSave() if active_level != null else null
	return SavedDataArea.new(info.id, false, public_id, save_map_nodes_data, active_level_data, encountered_encounter_ids, active_map_node_data)
	
func onLoadData(data: SavedData) -> void:
	super(data)
	Game.area = self
	add_to_group("AreasGD")
	basic_card_ids = info.card_ids.filter(func(x: int): \
		return Game.isBasicRarity(Helper.getFofInfoID(CardInfo, x).rarity))
		
	map_nodes_data = data.map_nodes_data
	active_level_data = data.level_data
	encountered_encounter_ids = data.encountered_encounter_ids
	
var is_init: bool = false
func onFofInit(Card: CardGD) -> void:
	is_init = true
	empty_spots = onGenerateEmptyMapSpots()
	onGenerateMapLinks()
	var unique_node_ids: Array = Card.info.unique_nodes_id
	
	setEmptySpotsIDS(unique_node_ids)
	setEliteFights()
	onCreateMapNodes()
	
func onLoadMap() -> void:
	for tile_object_data in info.overworld_decoration.data:
		SavedData.onLoadModel(tile_object_data, self)
		
	for map_node_data in map_nodes_data:
		onCreateMapNode(map_node_data)
		
	map_nodes_data = [] # Empty map nodes data to get most recent versions
		
func onLoadMapAfterScenes() -> void:
	if is_init:
		init_load.emit()
		is_init = false
		
	var map_node: MapNodeGD = getEnteredMapNode()
	if map_node.is_entered and !map_node.is_finished:
		map_node.onEntered()
		
	elif map_node.is_entered and map_node.is_finished:
		map_node.onEnteredVisual(true)
	
#endregion
	
#region Create Map Nodes
var empty_spots: Array[EmptyMapNode] = []
#region Generators
func onGenerateEmptyMapSpots() -> Array[EmptyMapNode]:
	if getWorldDifficulty() == 1: empty_spots.append(EmptyMapNode.new(-1, 0))
	empty_spots.append(EmptyMapNode.new(0, 0))
	
	for i in range(1, 11):
		match i:
			5: empty_spots.append(EmptyMapNode.new(i, 0))
			10:
				if Game.isDivinus(): empty_spots.append(EmptyMapNode.new(11, 0))
				empty_spots.append(EmptyMapNode.new(10, 0))
			_:
				for j in range(-1, 2): # Create on -1 and 1
					if j != 0: empty_spots.append(EmptyMapNode.new(i, j))
	return empty_spots
	
func onGenerateMapLinks() -> void:
	var empty_spots_by_progress: Dictionary[int, Array] = onGenerateEmptySpotsByProgress()
	onCreateMapLinks(empty_spots_by_progress)
	setHolyPath()
			
func onGenerateEmptySpotsByProgress() -> Dictionary:
	var empty_spots_by_progress: Dictionary[int, Array] = {}
	for empty_spot: EmptyMapNode in empty_spots:
		if empty_spots_by_progress.has(empty_spot.progress):
			empty_spots_by_progress[empty_spot.progress].append(empty_spot)
		else: empty_spots_by_progress[empty_spot.progress] = [empty_spot]
	return empty_spots_by_progress
	
func onGenerateMapNodeOddsRollable(map_node_odds: Dictionary) -> Dictionary:
	var map_node_odds_rollable: Dictionary = {}
	for key in map_node_odds:
		map_node_odds_rollable[key] = {"fight": map_node_odds[key].regular_fight / 100,\
		"encounter": map_node_odds[key].encounter / 100}
	return map_node_odds_rollable
#endregion

#region Link-related
func onCreateMapLinks(empty_spots_by_progress: Dictionary[int, Array]) -> void:
	var section_one_batch: Dictionary[int, Array] = {}
	var section_two_batch: Dictionary[int, Array] = {} 
	for key: int in empty_spots_by_progress:
		if (key == 10 and !Game.isDivinus()) or key == 11: continue
		
		var batch: Array = empty_spots_by_progress[key]
		var next_batch: Array = empty_spots_by_progress[key + 1]
		
		if key >= 1 and key <= 3: section_one_batch[key] = batch
		elif key >= 6 and key <= 8: section_two_batch[key] = batch
		
		for empty_spot: EmptyMapNode in batch:
			for next_empty_spot: EmptyMapNode in next_batch:
				if next_empty_spot.lane == empty_spot.lane or key in [0, 4, 5, 9]:
					empty_spot.links.append(EmptyMapNodeLink.new(next_empty_spot))
		
	onGenerateLinksPerSection(section_one_batch, empty_spots_by_progress)
	onGenerateLinksPerSection(section_two_batch, empty_spots_by_progress)
		
func onGenerateLinksPerSection(section_batch: Dictionary[int, Array], empty_spots_by_progress: Dictionary[int, Array]) -> void:
	var section_progresses: Array = section_batch.keys()
	section_progresses.shuffle()
	
	var first_lane_link: int = 0
	var second_lane_link: int = 0
	
	for progress: int in section_progresses:
		if first_lane_link == progress or second_lane_link == progress: continue
		if first_lane_link > 0 and second_lane_link > 0: break 
		
		var empty_map_node: EmptyMapNode
		if first_lane_link == 0 and second_lane_link == 0:
			var index: int = int(Random.getBool())
			empty_map_node = section_batch[progress][index]
		else:
			empty_map_node = section_batch[progress]\
			.filter(func(x: EmptyMapNode): return (x.lane == 1 and first_lane_link > 0) or (x.lane == -1 and second_lane_link > 0))[0]
		
		if empty_map_node.lane == -1: first_lane_link = progress
		elif empty_map_node.lane == 1: second_lane_link = progress
		
		var next_empty_map_node: EmptyMapNode = empty_spots_by_progress[progress + 1].filter(func(x: EmptyMapNode): return x.lane != empty_map_node.lane)[0]
		empty_map_node.links.append(EmptyMapNodeLink.new(next_empty_map_node))
#endregion

#region Set Empty ID
func setEmptySpotsIDS(unique_node_ids: Array) -> void:
	empty_spots.shuffle()
	
	var unique_nodes: Array = unique_node_ids\
		.filter(func(x: int): return x != 10)\
		.map(func(x: int):
		return SegmentNode.new(x, Random.getBool() if getWorldDifficulty() != 1 else false))
	
	for segment_node: SegmentNode in unique_nodes\
		.filter(func(__: SegmentNode): return Random.rollFloat(getWorld().extra_unique_node_odds / 100.0)):
		unique_nodes.append(SegmentNode.new(segment_node.id, !segment_node.segment_one))
		
	var is_divinus: bool = Game.isDivinus()
	var shops: Array = []
	if getWorldDifficulty() == 1: shops = [SegmentNode.new(6, false, is_divinus)]
	elif !is_divinus: shops = [SegmentNode.new(6, false), SegmentNode.new(6, true)]
	elif is_divinus:
		var is_segment_one_shop_holy: int = int(Random.getBool())
		shops = [SegmentNode.new(6, true, is_segment_one_shop_holy),\
			SegmentNode.new(6, false, abs(is_segment_one_shop_holy - 1))]
		
	var segment_one_encounter_limit: int = getWorld().getEncounterAmount()
	var segment_two_encounter_limit: int = getWorld().getEncounterAmount()
	var non_fights_assigned: Array = []
	if getWorldDifficulty() == 1:
		segment_one_encounter_limit -= 1
	
	for empty_spot: EmptyMapNode in empty_spots:
		var is_holy: bool = empty_spot.links.any(func(x: EmptyMapNodeLink): return x.is_holy)
		match empty_spot.progress:
			-1:
				empty_spot.id = 1
				continue
			0:
				empty_spot.id = 1 if getWorldDifficulty() > 1 else (6 if Helper.admin_datastore.spawn_instead_of_shop_id == 0 else Helper.admin_datastore.spawn_instead_of_shop_id)
				continue
			1, 2:
				if getWorldDifficulty() == 1:
					empty_spot.id = 3
					continue
			5:
				empty_spot.id = 7
				continue
			10:
				if is_divinus: empty_spot.id = 10
				else: empty_spot.id = 8
				continue
			11:
				empty_spot.id = 8
				continue
			_:
				if non_fights_assigned.is_empty() or non_fights_assigned.all(func(x: EmptyMapNode): return !x.isLink(empty_spot)):
					if onSelectUniqueNodeGeneration(unique_nodes, empty_spot):
						non_fights_assigned.append(empty_spot)
						continue
					elif onSelectShop(shops, empty_spot, is_holy):
						non_fights_assigned.append(empty_spot)
						continue
		
		if (empty_spot.isSegmentOne() and segment_one_encounter_limit > 0) or (empty_spot.isSegmentTwo() and segment_two_encounter_limit): # Roll an encounter
			if non_fights_assigned.is_empty() or non_fights_assigned.all(func(x: EmptyMapNode): return !x.isLink(empty_spot)):
				non_fights_assigned.append(empty_spot)
				empty_spot.id = 5
				
				if empty_spot.isSegmentOne(): segment_one_encounter_limit -= 1
				else: segment_two_encounter_limit -= 1
				
				continue
		empty_spot.id = 3
		
func onSelectUniqueNodeGeneration(unique_nodes: Array, empty_spot: EmptyMapNode) -> bool:
	for segment_node in unique_nodes.filter(func(x: SegmentNode):\
		return (x.segment_one and empty_spot.progress < 5) or (!x.segment_one and empty_spot.progress > 5)):
		empty_spot.id = segment_node.id
		unique_nodes.erase(segment_node)
		return true
	return false
		
func onSelectShop(shops: Array, empty_spot: EmptyMapNode, is_holy: bool) -> bool:
	for segment_node in shops.filter(func(x: SegmentNode):\
		return (x.segment_one and empty_spot.progress < 5) or (!x.segment_one and empty_spot.progress > 5)\
		and is_holy == x.is_holy):
		empty_spot.id = 6
		shops.erase(segment_node)
		return true
	return false
		
#endregion

#region Elites
func setEliteFights() -> void:
	var max_elite_fight_amount: int = basic_card_ids.map(func(x: int): return Helper.getFofInfoID(CardInfo, x))\
		.filter(func(x: CardInfo): return x.rarity == Game.Rarities.EXALT).size()
	var assigned_elite_fights: Array = []
	for empty_spot: EmptyMapNode in empty_spots.filter(func(x: EmptyMapNode): return x.id == 3):
		if assigned_elite_fights.size() == max_elite_fight_amount: break
		if !assigned_elite_fights.all(func(x: EmptyMapNode): return !x.isLink(empty_spot)): continue
		if getWorldDifficulty() == 1 and empty_spot.progress < 4: continue
		if assigned_elite_fights.size() < getWorld().MIN_ELITE_FIGHTS or Random.rollFloat(getWorld().UPGRADE_REGULAR_FIGHT):
			empty_spot.id = 4
			assigned_elite_fights.append(empty_spot)
#endregion

#region Getters
func getExtraEliteOdds(Card: CardGD) -> float:
	if Card.info.id == 1: return Card.extra_elite_odds
	return 0
#endregion

#region Map Nodes
func onCreateMapNodes() -> void:
	for empty_spot in empty_spots:
		empty_spot.map_location = MapLocation.new(empty_spot.progress, empty_spot.lane, info.id)
		
	var map_locations: Array = empty_spots.map(func(x: EmptyMapNode): return x.map_location)
	for _map_location in map_locations:
		_map_location.position = MapNodeGD.onCalculatePosition(_map_location)
	
	var infos: Array = Helper.getFofInfoArray(MapNodeInfo)
	for empty_spot in empty_spots:
		var links: Array = empty_spot.links.map(func(x: EmptyMapNodeLink): return MapLink.new(x.empty_map_node.map_location, x.is_holy))
		var map_node_info: MapNodeInfo = infos.filter(func(x: MapNodeInfo): return x.id == empty_spot.id)[0]
		onCreateMapNode(map_node_info.saved_data.new(empty_spot.id, true, 0, empty_spot.map_location, links))
	
func onCreateMapNode(data: SavedDataMapNode) -> void:
	var map_node: MapNodeGD = SavedData.onLoadModel(data, self)
	map_location_to_node[map_node.map_location] = map_node
	map_node.hovered.connect(onMapNodeHovered)
	map_node.pressed.connect(onMapNodePressed)
	map_node.load_level.connect(onMapNodeLoadLevelInit)
	map_node.entered.connect(onMapNodeEntered)
	map_node.finished.connect(onMapNodeFinished)
	
#endregion
#region Holy Path
func setHolyPath() -> void:
	if Game.isDivinus():
		var empty_map_node: EmptyMapNode = onFindEmptyMapSpot(0, 0) if getWorldDifficulty() > 1 else onFindEmptyMapSpot(-1, 0)
		var lane: int = -1 if Random.getBool() else 1
		while(empty_map_node.progress < 11):
			var link: EmptyMapNodeLink = empty_map_node.links.filter(func(x: EmptyMapNodeLink): return x.empty_map_node.lane in [0, lane])[0]
			link.is_holy = true
			empty_map_node = link.empty_map_node
			
			if empty_map_node.progress == 5: lane = -1 if Random.getBool() else 1
			

#endregion
#endregion	

#region Map Nodes
func getEnteredMapNode() -> MapNodeGD:
	var map_nodes: Array = get_tree().get_nodes_in_group("MapNodesGD").filter(func(x: MapNodeGD): return x.is_entered)
	map_nodes.sort_custom(func(x: MapNodeGD, y: MapNodeGD): return x.progress > y.progress)
	return map_nodes[0]
	
func onMapNodeHovered(map_node: MapNodeGD, state: bool, _HoverUI: Variant = null) -> void:
	var EnteredMapNode: MapNodeGD = getEnteredMapNode()
	var is_walkable: bool = EnteredMapNode.isMapNodeLink(map_node)
	map_node.onStaticBodyHovered(is_walkable, state)
	
func onMapNodePressed(map_node: MapNodeGD) -> void:
	var EnteredMapNode: MapNodeGD = getEnteredMapNode()
	if !(EnteredMapNode.isMapNodeLink(map_node) and EnteredMapNode.is_finished): return
	get_tree().call_group("MapNodesGD", "setRayPickableGlobal", false)
	
	EnteredMapNode.onExitedVisual()
	map_node.onEnteredVisual()
	
	await get_tree().create_timer(Game.SELECTED_MAP_NODE_TRAVEL_SPEED).timeout
	EnteredMapNode.onExited()
	map_node.onEntered()
			
func onMapNodeEntered(map_node: MapNodeGD) -> void:
	active_map_node_data = map_node.onSave()
			
func onMapNodeFinished(map_node: MapNodeGD) -> void:
	get_tree().call_group("MapNodesGD", "setRayPickableGlobal", true)
	get_tree().call_group("MapNodesGD", "onOtherMapNodeFinished", map_node)
	
func onMapNodeLoadLevelInit(_active_level_data: SavedDataLevel) -> void:
	if active_level_data != null: return # If level already loaded
	
	active_level_data = _active_level_data
	active_level_data.max_energy = info.world.getMaxEnergy()
	active_level_data.energy = active_level_data.max_energy
	onMapNodeLoadLevel()
		
func onMapNodeLoadLevel() -> void:
	load_level.emit(active_level_data)
#endregion

#region Getters
func isAfterMiniboss() -> bool:
	return getEnteredMapNode().map_location.isAfterMiniboss()

func getBossMapNode() -> MapNodeGD:
	return getNodeByID(8)
	
func getStartMapNode() -> MapNodeGD:
	return getNodeByID(1)
	
func getNodeByID(id: int) -> MapNodeGD:
	for map_node in get_tree().get_nodes_in_group("MapNodesGD"):
		if map_node.info.id == id: return map_node
	return null
#endregion

#region Active Level
func onLoadActiveLevel(level_data: SavedDataLevel) -> LevelGD:
	if map_nodes_data.is_empty():
		map_nodes_data = SavedData.onSaveGroup(get_tree().get_nodes_in_group("MapNodesGD")) # Save map nodes data
	get_tree().call_group("TileObjectsGD", "free")
	get_tree().call_group("MapNodesGD", "onClear")
	get_tree().call_group("CardsGD", "onRemoveModel")
	
	active_level = SavedData.onLoadModel(level_data, self)
	active_level.set_rewards.connect(setRewards)
	active_level.rewards_finished.connect(onRewardsFinished)
	return active_level
#endregion
	
#region Rewards
func setRewards(is_win: bool) -> void:
	active_level.is_ended = true
	if is_win:
		var items: Array = []
		var fight_type: Game.FightTypes = active_level.fight_type
		var is_elite: bool = fight_type == Game.FightTypes.ELITE
		var is_epic: bool = fight_type in [Game.FightTypes.MINIBOSS, Game.FightTypes.BOSS]
		
		var fight_rewards_datastore: FightRewardsDatastore = \
			getWorld().elite_fight_rewards if is_epic or is_elite else getWorld().fight_rewards
		
		var enemy_cards: Array = active_level.enemy_cards.duplicate()
		if is_elite:
			items.append(SavedData.onLoadModel(enemy_cards.pop_back(), active_level))
			
		enemy_cards = enemy_cards.filter(func(x: SavedDataCard): return Helper.getFofInfoID(CardInfo, x.id).rarity != Game.Rarities.CHAMPION)
		
		var reward_amount: int = Game.CARD_REWARD_DEFAULT_AMOUNT
		enemy_cards.resize(reward_amount)
		enemy_cards = enemy_cards.filter(func(x: SavedDataCard): return x != null)
		
		items.append(enemy_cards.map(func(x: SavedDataCard):\
			return SavedData.onLoadModel(x.duplicate(), active_level)))
			
		var shillings: int = randi_range(fight_rewards_datastore.shillings_min, fight_rewards_datastore.shillings_max)
		var change_shillings_wrapper: ActionWrapper = SavedData.onLoadModel(SavedDataActionWrapper.new(), active_level)
		change_shillings_wrapper.setActions(ChangeShillingsAction.new(shillings))
		
		items.append(change_shillings_wrapper)
			
		var add_tool: bool
		var add_boon: bool
		
		if !is_elite and !is_epic:
			add_tool = Random.rollFloat(fight_rewards_datastore.tool_odds / 100.0)
			add_boon = Random.rollFloat(getDivinusBoonOdds(fight_rewards_datastore.boon_odds) / 100.0)
		else: # 50 / 50 chance if divinus, otherwise 66% 33% chance
			add_tool = Random.rollFloat((fight_rewards_datastore.tool_odds / 100.0) if !Game.isDivinus() else 0.5)
			if !add_tool: add_boon = true
				
			if Random.rollFloat(getWorld().elite_fight_rewards_second_item_odds):
				add_tool = true
				add_boon = true
			
		if add_tool:
			items.append(SavedData.onLoadModel(Random.getRandomFofByOdds(ToolInfo), active_level))
			
		if add_boon:
			var boon_data: SavedDataBoon = Random.getRandomFofByOdds(BoonInfo)
			if boon_data != null: items.append(SavedData.onLoadModel(boon_data, active_level))
		
		var rewards := Rewards.new(items)
		if is_epic:
			rewards.epic_items = getEpicFightRewards()
		
		rewards.setInfo(active_level)
		active_level.rewards = rewards
	active_level.onGameEnded()
	
func getEpicFightRewards() -> Array:
	var boss_card: BossCardGD = active_level.getBoss()
	
	var card_info: CardInfo = Helper.getFofInfoID(CardInfo, boss_card.info.card_id)
	var card_data := SavedDataCard.new(card_info.id, true)
	card_data.team = 1
	Game.setCardDataFromInfo(card_data, card_info)
	
	var boon_data := SavedDataBoon.new(boss_card.info.boon_id, true)
	var tool_data := SavedDataTool.new(boss_card.info.tool_id, true)
	
	var Card: CardGD = SavedData.onLoadModel(card_data, active_level)
	var Boon: BoonGD = SavedData.onLoadModel(boon_data, active_level)
	var Tool: ToolGD = SavedData.onLoadModel(tool_data, active_level)
	
	return [Card, Boon, Tool]
#endregion

#region Random Enemy
func onCreateCardByEnergy(_cards: Array, energy: int, spawn: SavedDataSpawn, progress: int, is_elite: bool) -> SavedDataCard:
	var original_cards: Array = _cards.filter(func(x: CardInfo): return x.energy == energy)
	var cards: Array = getCardsByRarity(original_cards)
	
	var card_info: CardInfo = cards.pick_random()
	var card_data: SavedDataCard = card_info.saved_data.new(card_info.id, true)
	card_data.team = 1
	card_data.coords = spawn.coords
	
	if progress < 3:
		Game.setCardDataFromInfo(card_data, card_info)
		return card_data
		
	if card_info.rarity != Game.Rarities.EXALT:
		var ascended_rate: float = getWorld().enemy_ascended_rate if !is_elite else getWorld().elite_enemy_ascended_rate
		var ascend_card: bool = Random.rollFloat(ascended_rate / 100.0)
		if ascend_card: card_data.ascended = true
	
	var add_tool: bool = Random.rollFloat(info.world.tool_enemy_spawn_rate / 100.0)
	if !add_tool:
		Game.setCardDataFromInfo(card_data, card_info)
		return card_data
	
	card_data.tool_data = Random.getRandomFofByOdds(ToolInfo, getWorld().tool_enemy_spawn_rarity_odds.getDictionary())
	Game.setCardDataFromInfo(card_data, card_info)
	return card_data
	
func getCardsByRarity(original_cards: Array) -> Array:
	@warning_ignore("int_as_enum_without_cast")
	var rarity: Game.Rarities = int(Random.getRandomKey(Random.onConvertPercentOdds(getWorld().enemy_spawn_rarity_odds.getDictionary())))
	var cards: Array = original_cards.filter(func(x: CardInfo): return x.rarity == rarity)
	if cards.is_empty(): return getCardsByRarity(original_cards)
	return cards
	
func setEnemySpawnsFromBudget(budget: int, enemy_spawn_amount: int, spawns: Array, progress: int, is_elite: bool) -> Array:
	var cards: Array = Helper.getFofInfoArray(CardInfo).filter(func(x: CardInfo): return x.id in basic_card_ids)
	
	if progress == 1 and info.id == 1: # Remove charmer
		cards = cards.filter(func(x: CardInfo): return x.id != 16)
	
	var energies: Array = cards.map(func(x: CardInfo): return x.energy)
	var highest_cost: int = energies.max()
	var lowest_cost: int = energies.min()
	
	var original_energy_combinations: Array = onGenerateCombinations(lowest_cost, highest_cost, enemy_spawn_amount)
	#print("Enemy Spawn Amount: " + str(enemy_spawn_amount))
	#print("Budget: " + str(budget))
	#print("Original Combainations: " + str(original_energy_combinations))
	
	var energy_combinations: Array = original_energy_combinations.filter(func(x: Array): return x.reduce(sum, 0) == budget)
	
	
	#print("End Combinations: " + str(energy_combinations))
	#print()
	
	var energy_combination: Array = []
	if !energy_combinations.is_empty(): # Remove later
		energy_combination = energy_combinations.pick_random()
	else: energy_combination = original_energy_combinations.pick_random(); print("USED ILLEGAL COMBINATION!")
	
	var other_enemies_ids: Array = get_tree().get_nodes_in_group("FightMapNodesGD")\
		.filter(func(x: MapNodeGD): return x.map_location.progress == progress)\
		.map(func(y: MapNodeGD): return y.enemy_cards.map(func(z: SavedDataCard): return z.id))
		
	while(true):
		var enemies: Array = []
		for i in range(energy_combination.size()):
			var card_data: SavedDataCard = onCreateCardByEnergy(cards, energy_combination[i], spawns[i], progress, is_elite)
			enemies.append(card_data)
		
		var enemies_ids: Array = enemies.map(func(x: SavedDataCard): return x.id)
		if !other_enemies_ids.is_empty() and other_enemies_ids.any(func(x: Array): return x == enemies_ids):
			continue
			
		#if info.id == 1 and progress > 1 and !enemies.any(func(x: SavedDataCard): return Helper.getFofInfoID(CardInfo, x.id).archetype.id in [3, 4, 5]): # Reroll if doesn't have at least one tactician, warden or brute
			#continue
			
		return enemies
	return []
	
func getBudget(progress: int, offset: int, is_unholy: bool = false) -> int:
	var unholy_offset: int = 1 if is_unholy else 0
	return getWorld().budget_for_fights[min(progress, 10)] + offset + (unholy_offset * getWorldDifficulty())
	
func sum(accum: int, number: int) -> int:
	return accum + number
	
func onGenerateCombinations(x: int, y: int, n: int) -> Array: # Gpt assist
	var combination_range = range(x, y + 1) # Inclusive range from x to y
	var result = []
	onCombineRecursive(combination_range, n, [], result)
	return result

func onCombineRecursive(arr: Array, n: int, current: Array, result: Array) -> void: # Gpt assist
	if n == 0:
		result.append(current.duplicate())
		return
	
	for i in range(len(arr)):
		onCombineRecursive(arr.slice(i, len(arr)), n - 1, current + [arr[i]], result)
#endregion

#region Champion
func getDivinusBoonOdds(odds: float) -> float:
	return odds * 2 if Game.isDivinus() else odds
#endregion

#region Exit Level
func onRewardsFinished(save_file: SaveFileGD) -> void:
	if active_level.fight_type in [Game.FightTypes.MINIBOSS, Game.FightTypes.BOSS]:
		Game.save_file.onUpgradeChampion()
	
	active_level.onClear()
	active_level = null
	active_level_data = null
	
	#var progress: int = getEnteredMapNode().map_location.progress
	#if progress >= 10:
		#save_file.onLoadArea
		#return
	save_file.onLoadMap()
	
func onLossFinished() -> void:
	pass
#endregion

#region Encounters
func onAppendToEncouteredEncounterIds(id: int) -> void:
	encountered_encounter_ids.append(id)
#endregion

#region Actions
func onProcessAction(action: Action) -> void:
	super(action)
	process_action.emit(action)
#endregion
