class_name AreaGD extends FofGD

#region Global
signal init_load
signal load_level

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
	return getEnteredMapNode().map_location.progress
#endregion

#region Save / Load
func onSave() -> SavedDataArea:
	if map_nodes_data.is_empty(): # If not loaded into a level get the most recent patch
		map_nodes_data = SavedData.onSaveGroup(get_tree().get_nodes_in_group("MapNodesGD"))
	
	active_level_data = active_level.onSave() if active_level != null else null
	return SavedDataArea.new(info.id, false, public_id, map_nodes_data, active_level_data, encountered_encounter_ids, active_map_node_data)
	
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
	empty_spots = generateEmptyMapSpots()
	generateMapLinks(Card)
	var map_node_odds: Dictionary = getMapNodeOdds()
	var unique_node_id: Array = Card.info.unique_nodes_id
	
	setEmptySpotsIDS(unique_node_id, map_node_odds, Card)
	setEliteFights(map_node_odds, Card)
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
		return
		
	var map_node: MapNodeGD = getEnteredMapNode()
	if map_node.is_entered and !map_node.is_finished:
		map_node.onEntered()
#endregion
	
#region Create Map Nodes
var empty_spots: Array[EmptyMapNode] = []
#region Generators
func generateEmptyMapSpots() -> Array[EmptyMapNode]:
	if getWorldDifficulty() == 1: empty_spots.append(EmptyMapNode.new(-1, 0))
	empty_spots.append(EmptyMapNode.new(0, 0))
	
	var last_two_lane_value: int = 0
	for i in range(1, 11):
		match i:
			1:
				for j in range(3): empty_spots.append(EmptyMapNode.new(1, j - 1))
			5, 10: empty_spots.append(EmptyMapNode.new(i, 0))
			_:
				var lane_count: int = onGenerateLaneCount()
				var start_lane: int = 0
				match lane_count:
					2: start_lane = -1 if Random.getBool() else 0; last_two_lane_value = start_lane
					3: start_lane = -1; last_two_lane_value = 1
					4:
						if last_two_lane_value != 1:
							start_lane = -1 if last_two_lane_value == 0 else -2
						else: start_lane = -1 if Random.getBool() else -2
						last_two_lane_value = 1
					
				for _i in range(lane_count):
					empty_spots.append(EmptyMapNode.new(i, start_lane))
					start_lane += 1
	return empty_spots
	
func generateMapLinks(Card: CardGD) -> void:
	var empty_spots_by_progress: Dictionary = generateEmptySpotsByProgress()
	onCreateAllMapLinks(empty_spots_by_progress)
	onRemoveOverlappingMapLinks(empty_spots_by_progress)
	onRemoveEdgesAtRandom(empty_spots_by_progress)
	setHolyPath(Card)
			
func generateEmptySpotsByProgress() -> Dictionary:
	var empty_spots_by_progress: Dictionary = {}
	for empty_spot in empty_spots:
		if empty_spots_by_progress.has(empty_spot.progress):
			empty_spots_by_progress[empty_spot.progress].append(empty_spot)
		else: empty_spots_by_progress[empty_spot.progress] = [empty_spot]
	return empty_spots_by_progress

func onGenerateLaneCount() -> int:
	return int(Random.getRandomKey(info.world.LANE_ODDS))
	
func generateMapNodeOddsRollable(map_node_odds: Dictionary) -> Dictionary:
	var map_node_odds_rollable: Dictionary = {}
	for key in map_node_odds:
		map_node_odds_rollable[key] = {"fight": map_node_odds[key].regular_fight / 100,\
		"encounter": map_node_odds[key].encounter / 100}
	return map_node_odds_rollable
#endregion

#region Link-related
func onCreateAllMapLinks(empty_spots_by_progress: Dictionary) -> void:
	for key in empty_spots_by_progress:
		if key == 10: continue
		var batch: Array = empty_spots_by_progress[key]
		var next_batch: Array = empty_spots_by_progress[key + 1]
		
		if next_batch.size() == 1: for empty_spot in batch: empty_spot.links.append(EmptyMapNodeLink.new(next_batch[0]))
		elif batch.size() == 1: for empty_spot in next_batch: batch[0].links.append(EmptyMapNodeLink.new(empty_spot))
		else:
			for empty_spot in batch:
				for _empty_spot in next_batch:
					if empty_spot.lane == _empty_spot.lane or empty_spot.lane == _empty_spot.lane + 1\
					or empty_spot.lane == _empty_spot.lane - 1:
						empty_spot.links.append(EmptyMapNodeLink.new(_empty_spot))
						
func onRemoveOverlappingMapLinks(empty_spots_by_progress: Dictionary) -> void:
	for key in empty_spots_by_progress:
		var batch: Array = empty_spots_by_progress[key]
		batch.sort_custom(func(x: EmptyMapNode, y: EmptyMapNode): return x.lane < y.lane)
		for i in range(batch.size() - 1):
			var empty_spot: EmptyMapNode = batch[i]
			var next_empty_spot: EmptyMapNode = batch[i + 1]
			var links: Dictionary = onFindNextOverlappingLinks(empty_spot, next_empty_spot)
			if !links.is_empty():
				var remove_first_link: bool = Random.getBool()
				if remove_first_link: empty_spot.links.erase(links[empty_spot])
				else: next_empty_spot.links.erase(links[next_empty_spot])
					
func onFindNextOverlappingLinks(empty_spot: EmptyMapNode, next_empty_spot: EmptyMapNode) -> Dictionary:
	for map_link in empty_spot.links:
		var link: EmptyMapNode = map_link.empty_map_node
		if link.lane == next_empty_spot.lane:
			for _map_link in next_empty_spot.links:
				var _link: EmptyMapNode = _map_link.empty_map_node
				if _link.lane == empty_spot.lane:
					return {empty_spot: map_link, next_empty_spot: _map_link}
	return {}
	
func onRemoveEdgesAtRandom(empty_spots_by_progress: Dictionary) -> void:
	for key in empty_spots_by_progress:
		if key == 10: continue
		
		var batch: Array = empty_spots_by_progress[key]
		for empty_spot in batch:
			var remove_links: Array = []
			var link_size: int = empty_spot.links.size()
			for link in empty_spot.links:
				if link_size > 1 and batch.any(func(x: EmptyMapNode): return x != empty_spot and \
				link.empty_map_node in x.links.map(func(y: EmptyMapNodeLink): return y.empty_map_node))\
				and Random.rollFloat(info.world.REMOVE_RANDOM_EDGES):
					remove_links.append(link)
					link_size -= 1
				
			for link in remove_links: empty_spot.links.erase(link)
			
func onFilterNextBatchToManyLinks(batch: Array, next_batch: Array) -> void:
	var batch_with_links: Dictionary = {}
	for empty_spot in batch:
		for link in empty_spot.links:
			if !batch_with_links.has(link): batch_with_links[link] = 1
			else: batch_with_links[link] += 1
	
	for key in batch_with_links:
		if batch_with_links[key] <= 1: next_batch.erase(key)
#endregion

#region Set Empty ID
func setEmptySpotsIDS(unique_node_ids: Array, map_node_odds: Dictionary, Card: CardGD) -> void:
	empty_spots.shuffle()
	
	var is_divinus: bool = Card.info.id == 2
	var map_node_odds_rollable: Dictionary = generateMapNodeOddsRollable(map_node_odds)
	
	var unique_nodes: Array = unique_node_ids\
		.filter(func(x: int): return x != 10)\
		.map(func(x: int):
		return SegmentNode.new(x, Random.getBool() if getWorldDifficulty() != 1 else false))
	
	for segment_node in unique_nodes\
		.filter(func(__: SegmentNode): return Random.rollFloat(getWorld().extra_unique_node_odds / 100.0)):
		unique_nodes.append(SegmentNode.new(segment_node.id, !segment_node.segment_one))
		
	var shops: Array = []
	if getWorldDifficulty() == 1:
		shops = [SegmentNode.new(6, false, is_divinus)]
	else:
		var is_first_shop_holy: bool = Random.getBool()
		shops = [SegmentNode.new(6, int(is_first_shop_holy)),\
			SegmentNode.new(6, abs(int(is_first_shop_holy) - 1))]
	
	if getWorldDifficulty() > 1 and Random.rollFloat(getWorld().extra_shop_odds / 100.0):
		shops.append(SegmentNode.new(6, Random.getBool(), Random.getBool()))
		
	var encounter_limiter: Array = [0, 0] # Limited to LIMIT_ENCOUNTER_AMOUNT_PER_SEGMENT
	for empty_spot in empty_spots:
		var is_holy: bool = empty_spot.links.any(func(x: EmptyMapNodeLink): return x.is_holy)
		
		if is_divinus and is_holy and empty_spot.progress == 9:
			empty_spot.id = 10
			continue
			
		match empty_spot.progress:
			-1: empty_spot.id = 1; continue
			0:
				empty_spot.id = 1 if getWorldDifficulty() > 1 else (6 if Helper.admin_datastore.spawn_instead_of_shop_id == 0 else Helper.admin_datastore.spawn_instead_of_shop_id)
				continue
			5: empty_spot.id = 7; continue
			10: empty_spot.id = 8; continue
			_:
				if onSelectUniqueNodeGeneration(unique_nodes, empty_spot):
					continue
				elif onSelectShop(shops, empty_spot, is_holy):
					continue
		
		if empty_spots.filter(func(y: EmptyMapNode): return y != empty_spot).all(func(x: EmptyMapNode): return x.id not in [0, 3]):
			empty_spot.id = 3
		else:
			var roll: String = Random.getRandomKey(map_node_odds_rollable[empty_spot.progress])
			match roll:
				"fight": empty_spot.id = 3; continue
				"encounter":
					var segment: int = 1 if empty_spot.progress <= 5 else 2
					if encounter_limiter[segment - 1] < getWorld().LIMIT_ENCOUNTER_AMOUNT_PER_SEGMENT:
						encounter_limiter[segment - 1] += 1
						empty_spot.id = 5
					else: empty_spot.id = 3
					continue
		
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
func setEliteFights(map_node_odds: Dictionary, Card: CardGD) -> void:
	var guarantee_elite: bool = true
	for empty_spot in empty_spots.filter(func(x: EmptyMapNode): return x.id == 3):
		var odds: float = map_node_odds[empty_spot.progress].upgrade_regular_fight
		if odds > 0:
			if guarantee_elite: empty_spot.id = 4; guarantee_elite = false; continue
			
		odds += getExtraEliteOdds(Card)
		var upgrade: bool = Random.rollFloat(odds / 100)
		if upgrade: empty_spot.id = 4
#endregion

#region Getters
func getMapNodeOdds() -> Dictionary:
	var map_node_odds: Dictionary = {}
	for odds in info.world.data: map_node_odds[odds.progress] = odds
	return map_node_odds
	
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
		_map_location.position = MapNodeGD.onCalculatePosition(_map_location, map_locations)
	
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
func setHolyPath(Card: CardGD) -> void:
	if Card.info.id == 2:
		var empty_map_node: EmptyMapNode = onFindEmptyMapSpot(0, 0) if getWorldDifficulty() > 1 else onFindEmptyMapSpot(-1, 0)
		while(empty_map_node.progress < 10):
			var link: EmptyMapNodeLink = empty_map_node.links.pick_random()
			link.is_holy = true
			empty_map_node = link.empty_map_node

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
		var fight_rewards_datastore: FightRewardsDatastore = \
			getWorld().elite_fight_rewards if active_level.is_elite else getWorld().fight_rewards
		
		var enemy_spawns: Array = active_level.enemy_spawns.duplicate()
		if active_level.is_elite:
			items.append(SavedData.onLoadModel(enemy_spawns.pop_back(), active_level))
			
		enemy_spawns = enemy_spawns.filter(func(x: SavedDataCard): return Helper.getFofInfoID(CardInfo, x.id).rarity != Game.Rarities.CHAMPION)
		
		var reward_amount: int = Game.CARD_REWARD_DEFAULT_AMOUNT
		enemy_spawns.resize(reward_amount)
		enemy_spawns = enemy_spawns.filter(func(x: SavedDataCard): return x != null)
		
		items.append(enemy_spawns.map(func(x: SavedDataCard):\
			return SavedData.onLoadModel(x.duplicate(), active_level)))
			
		var shillings: int = randi_range(fight_rewards_datastore.shillings_min, fight_rewards_datastore.shillings_max)
		var shilling_gain: MapEffectGD = Game.onCreateGainShillings(shillings, active_level)
		items.append(shilling_gain)
		
		var add_boon: bool = Random.rollFloat(getDivinusBoonOdds(fight_rewards_datastore.boon_odds) / 100.0)
		if add_boon:
			var boon_data: SavedDataBoon = Random.getRandomFofByOdds(BoonInfo)
			if boon_data != null: items.append(SavedData.onLoadModel(boon_data, active_level))
				
		var add_tool: bool = Random.rollFloat(fight_rewards_datastore.tool_odds / 100.0)
		if add_tool:
			items.append(SavedData.onLoadModel(Random.getRandomFofByOdds(ToolInfo), active_level))
		
		var rewards := Rewards.new(items)
		rewards.setInfo(active_level)
		active_level.rewards = rewards
	active_level.onGameEnded()

#endregion

#region Random Enemy
func onCreateCardByEnergy(_cards: Array, energy: int, spawn_coords: Vector4i, progress: int, is_elite: bool) -> SavedDataCard:
	var original_cards: Array = _cards.filter(func(x: CardInfo): return x.energy == energy)
	var cards: Array = getCardsByRarity(original_cards)
	
	var card_info: CardInfo = cards.pick_random()
	var card_data: SavedDataCard = card_info.saved_data.new(card_info.id, true)
	card_data.team = 1
	card_data.coords = spawn_coords
	
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
	var enemies: Array = []
	var cards: Array = Helper.getFofInfoArray(CardInfo).filter(func(x: CardInfo): return x.id in basic_card_ids)
	var energies: Array = cards.map(func(x: CardInfo): return x.energy)
	var highest_cost: int = energies.max()
	var lowest_cost: int = energies.min()
	
	var original_energy_combinations: Array = onGenerateCombinations(lowest_cost, highest_cost, enemy_spawn_amount)
	print("Enemy Spawn Amount: " + str(enemy_spawn_amount))
	print("Budget: " + str(budget))
	print("Original Combainations: " + str(original_energy_combinations))
	
	var energy_combinations: Array = original_energy_combinations.filter(func(x: Array): return x.reduce(sum, 0) == budget)
	
	
	print("End Combinations: " + str(energy_combinations))
	print()
	
	var energy_combination: Array = []
	if !energy_combinations.is_empty(): # Remove later
		energy_combination = energy_combinations.pick_random()
	else: energy_combination = original_energy_combinations.pick_random(); print("USED ILLEGAL COMBINATION!")
	
	for i in range(energy_combination.size()):
		var card_data: SavedDataCard = onCreateCardByEnergy(cards, energy_combination[i], spawns[i], progress, is_elite)
		enemies.append(card_data)
	return enemies
	
func getBudget(progress: int, offset: int, is_unholy: bool = false) -> int:
	var unholy_offset: int = 1 if is_unholy else 0
	return getWorld().budget_for_fights[progress] + offset + (unholy_offset * getWorldDifficulty())
	
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
	return odds * 2
	
func getDivinusBoonAscensionOdds(odds: float) -> float:
	return odds + 2.5
#endregion

#region Exit Level
func onRewardsFinished(save_file: SaveFileGD) -> void:
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
