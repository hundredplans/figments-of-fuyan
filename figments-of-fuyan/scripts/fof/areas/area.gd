class_name AreaGD extends FofGD

#region Global
signal map_node_hovered
signal map_node_entered
signal map_node_finished
signal map_node_pressed
signal load_level

var map_location_to_node: Dictionary
var active_level: LevelGD
var map_nodes_data: Array[SavedDataMapNode] = []
var basic_card_ids: Array = []
#endregion

#region Helper

func getWorldDifficulty() -> int:
	return info.world.world

func onFindEmptyMapSpot(progress: int, lane: int) -> EmptyMapNode:
	for empty_map_spot in empty_spots:
		if empty_map_spot.progress == progress and empty_map_spot.lane == lane: return empty_map_spot
	return null

#endregion

#region Save / Load
func onSave() -> SavedDataArea:
	if map_nodes_data.is_empty():
		map_nodes_data.assign(SavedData.onSaveGroup(get_tree().get_nodes_in_group("MapNodesGD")))
	
	var level_data := active_level.onSave() if active_level != null else null
	return SavedDataArea.new(info.id, false, public_id, map_nodes_data, level_data)
	
func onLoadData(data: SavedData) -> void:
	super(data)
	add_to_group("AreasGD")
	basic_card_ids = info.card_ids.filter(func(x: int): \
		return Game.isBasicRarity(Helper.getFofInfoID(CardInfo, x).rarity))
	map_nodes_data = data.map_nodes_data
#endregion
	
#region Create Map Nodes
var empty_spots: Array[EmptyMapNode] = []
func onFofInit(Card: CardGD) -> void:
	empty_spots = generateEmptyMapSpots()
	generateMapLinks(Card)
	var map_node_odds: Dictionary = getMapNodeOdds()
	var unique_node_id: Array = Card.info.unique_nodes_id
	
	setEmptySpotsIDS(unique_node_id, map_node_odds)
	setEliteChiefFights(map_node_odds, Card)
	onCreateMapNodes()

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
	
func generateMapLinks(Card) -> void:
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
		"encounter": map_node_odds[key].encounter / 100, "shop": map_node_odds[key].shop / 100}
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
func setEmptySpotsIDS(unique_node_ids: Array, map_node_odds: Dictionary) -> void:
	empty_spots.shuffle()
	var guarantee_shop: bool = false
	var guarantee_unique_node: Array = []
	var map_node_odds_rollable: Dictionary = generateMapNodeOddsRollable(map_node_odds)
	guarantee_unique_node.resize(unique_node_ids.size())
	guarantee_unique_node.fill(true)
	
	var extra_unique_node_segment_one: bool = false
	var extra_unique_node_segment_two: bool = false
	if !unique_node_ids.is_empty():
		extra_unique_node_segment_one = Random.rollFloat(info.world.unique_node_segment_one_odds / 100)
		extra_unique_node_segment_two = Random.rollFloat(info.world.unique_node_segment_two_odds / 100)
		
	for empty_spot in empty_spots:
		match empty_spot.progress:
			-1: empty_spot.id = 1; continue
			0: empty_spot.id = 1 if getWorldDifficulty() > 1 else 2; continue # Gildred
			5: empty_spot.id = 9; continue
			10: empty_spot.id = 10; continue
			_:
				if extra_unique_node_segment_one and empty_spot.progress < 5:
					extra_unique_node_segment_one = false
					empty_spot.id = unique_node_ids.pick_random()
				elif extra_unique_node_segment_two and empty_spot.progress > 5:
					extra_unique_node_segment_two = false
					empty_spot.id = unique_node_ids.pick_random()
			
		if !guarantee_shop and map_node_odds[empty_spot.progress].shop > 0:
			empty_spot.id = 8
			guarantee_shop = true
			continue
		elif guarantee_unique_node.size() > 0 and empty_spot.progress > 5:
			var index: int = 0
			for state in guarantee_unique_node:
				if state:
					empty_spot.id = unique_node_ids[index]
					guarantee_unique_node[index] = false
					break
				index += 1
			
			var remove_guarantee: bool = guarantee_unique_node.all(func(x: bool): return !x)
			if remove_guarantee: guarantee_unique_node = []
			continue
		
		var roll: String = Random.getRandomKey(map_node_odds_rollable[empty_spot.progress])
		match roll:
			"fight": empty_spot.id = 3; continue
			"shop": empty_spot.id = 8; continue
			"encounter": empty_spot.id = 7; continue
		
#endregion

#region Elites
func setEliteChiefFights(map_node_odds: Dictionary, Card: CardGD) -> void:
	var guarantee_chief: bool = true
	var guarantee_elite: bool = true
	for empty_spot in empty_spots.filter(func(x: EmptyMapNode): return x.id == 3):
		var odds: float = map_node_odds[empty_spot.progress].upgrade_regular_fight
		if odds > 0:
			if guarantee_elite: empty_spot.id = 4; guarantee_elite = false; continue
			elif guarantee_chief: empty_spot.id = 5; guarantee_chief = false; continue
		odds += getExtraEliteChiefOdds(Card)
		var upgrade: bool = Random.rollFloat(odds / 100)
		var upgrade_extra: bool = Random.rollFloat(odds / 100)
		if upgrade and upgrade_extra: empty_spot.id = 6
		elif upgrade:
			var upgrade_to_elite: bool = Random.getBool()
			if upgrade_to_elite: empty_spot.id = 4
			else: empty_spot.id = 5
#endregion

#region Getters
func getMapNodeOdds() -> Dictionary:
	var map_node_odds: Dictionary = {}
	for odds in info.world.data: map_node_odds[odds.progress] = odds
	return map_node_odds
	
func getExtraEliteChiefOdds(Card: CardGD) -> float:
	if Card.info.id == 1: return Card.extra_elite_chief_odds
	return 0
#endregion

#region Map Nodes
func onCreateMapNodes() -> void:
	for empty_spot in empty_spots:
		empty_spot.map_location = MapLocation.new(empty_spot.progress, empty_spot.lane, info.id)
		
	var map_locations: Array = empty_spots.map(func(x: EmptyMapNode): return x.map_location)
	for _map_location in map_locations:
		_map_location.position = MapNodeGD.onCalculatePosition(_map_location, map_locations)
	
	for empty_spot in empty_spots:
		var links: Array = empty_spot.links.map(func(x: EmptyMapNodeLink): return MapLink.new(x.empty_map_node.map_location, x.is_holy))
		onCreateMapNode(MapNodeInfo.getDataFromID(empty_spot.id).\
		new(empty_spot.id, true, 0, empty_spot.map_location, links))
	
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
	for map_node in get_tree().get_nodes_in_group("MapNodesGD"):
		if map_node.is_entered: return map_node
	return null
	
func onMapNodeHovered(map_node: MapNodeGD, state: bool) -> void:
	map_node_hovered.emit(map_node, state)
	var EnteredMapNode: MapNodeGD = getEnteredMapNode()
	var is_walkable: bool = EnteredMapNode.isMapNodeLink(map_node)
	map_node.onStaticBodyHovered(is_walkable, state)
	
func onMapNodePressed(map_node: MapNodeGD) -> void:
	var EnteredMapNode: MapNodeGD = getEnteredMapNode()
	if EnteredMapNode.isMapNodeLink(map_node) and EnteredMapNode.is_finished:
		get_tree().call_group("MapNodesGD", "setRayPickableGlobal", false)
		EnteredMapNode.onExit()
		map_node.onEnter()
		map_node_pressed.emit(map_node)
			
func onMapNodeEntered(map_node: MapNodeGD) -> void:
	get_tree().call_group("MapNodesGD", "setRayPickableGlobal", false)
	map_node_entered.emit(map_node)
			
func onMapNodeFinished(map_node: MapNodeGD) -> void:
	get_tree().call_group("MapNodesGD", "setRayPickableGlobal", true)
	map_node_finished.emit(map_node)
	
func onLoadMap() -> void:
	for tile_object_data in info.overworld_decoration.data:
		SavedData.onLoadModel(tile_object_data, self)
		
	for map_node_data in map_nodes_data:
		onCreateMapNode(map_node_data)
		
	map_nodes_data = []
	var map_node: MapNodeGD = getEnteredMapNode()
	if map_node.is_entered and !map_node.is_finished:
		onMapNodeEntered(map_node)
	
func onMapNodeLoadLevelInit(level_data: SavedDataLevel) -> void:
	level_data.max_energy = info.world.getMaxEnergy()
	level_data.energy = level_data.max_energy
	onMapNodeLoadLevel(level_data)
		
func onMapNodeLoadLevel(level_data: SavedDataLevel) -> void:
	load_level.emit(level_data)
#endregion

#region Getters
func isAfterMiniboss() -> bool:
	return getEnteredMapNode().map_location.isAfterMiniboss()

func getBossMapNode() -> MapNodeGD:
	return getNodeByID(10)
	
func getStartMapNode() -> MapNodeGD:
	return getNodeByID(1)
	
func getNodeByID(id: int) -> MapNodeGD:
	for map_node in get_tree().get_nodes_in_group("MapNodesGD"):
		if map_node.info.id == id: return map_node
	return null
#endregion

#region Active Level
func onLoadActiveLevel(level_data: SavedDataLevel) -> LevelGD:
	map_nodes_data.assign(SavedData.onSaveGroup(get_tree().get_nodes_in_group("MapNodesGD")))
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
			info.world.elite_fights_rewards if active_level.is_elite else info.world.fight_rewards
		
		var enemy_spawns: Array = active_level.enemy_spawns.duplicate()
		enemy_spawns.resize(Game.CARD_REWARD_DEFAULT_AMOUNT)
		enemy_spawns = enemy_spawns.filter(func(x: Variant): return x != null)
		
		items.append(enemy_spawns.map(func(x: SavedDataCard):\
			return SavedData.onLoadModel(x.duplicate(), active_level)))
			
		var shillings: int = randi_range(fight_rewards_datastore.shillings_min, fight_rewards_datastore.shillings_max)
		var shilling_gain: MapEffectGD = Game.onCreateGainShillings(shillings, active_level)
		items.append(shilling_gain)
		
		var add_boon: bool = Random.rollFloat(getDivinusBoonOdds(fight_rewards_datastore.boon_odds) / 100.0)
		var add_tool: bool = Random.rollFloat(fight_rewards_datastore.tool_odds / 100.0)
		
		if add_boon:
			var odds: Dictionary = fight_rewards_datastore.boon_rarity_odds.getDictionary()
			var rarity: Game.Rarities = int(Random.getRandomKey(Random.onConvertPercentOdds(odds)))
			var viable_boons: Array = Helper.getFofInfoArray(BoonInfo).filter(func(x: BoonInfo): return x.rarity == rarity)
			var boon_info: BoonInfo = viable_boons.pick_random()
			var boon_data: SavedDataBoon = boon_info.saved_data.new(boon_info.id, true)
			var ascend_boon: bool = Random.rollFloat(getDivinusBoonAscensionOdds(fight_rewards_datastore.boon_ascension_rate / 100.0))
			boon_data.ascended = ascend_boon
			
			var boon: BoonGD = SavedData.onLoadModel(boon_data, active_level)
			items.append(boon)
		
		elif add_tool:
			var odds: Dictionary = fight_rewards_datastore.tool_rarity_odds.getDictionary()
			var rarity: Game.Rarities = int(Random.getRandomKey(Random.onConvertPercentOdds(odds)))
			var viable_tools: Array = Helper.getFofInfoArray(ToolInfo).filter(func(x: ToolInfo): return x.rarity == rarity)
			var tool_info: ToolInfo = viable_tools.pick_random()
			var tool_data: SavedDataTool = tool_info.saved_data.new(tool_info.id, true)
			var ascend_tool: bool = Random.rollFloat(fight_rewards_datastore.tool_ascension_rate / 100.0)
			tool_data.ascended = ascend_tool
			
			var Tool: ToolGD = SavedData.onLoadModel(tool_data, active_level)
			items.append(Tool)
		
		var rewards := Rewards.new(items)
		rewards.setInfo(active_level)
		active_level.rewards = rewards
	active_level.onGameEnded()

#endregion

#region Random Enemy
func getRandomEnemySpawn(spawn_coords: Vector4i, progress: int) -> SavedDataCard:
	var card_info: CardInfo = Helper.getFofInfoID(CardInfo, basic_card_ids.pick_random())
	var card_data: SavedDataCard = card_info.saved_data.new(card_info.id, true)
	
	card_data.team = 1
	card_data.coords = spawn_coords
	var tool_data: SavedDataTool
	
	var ascend_card: bool = Random.rollFloat(info.world.enemy_ascended_rate / 100.0)
	if ascend_card:
		card_data.ascended = true
	
	if progress >= 3:
		var add_tool: bool = Random.rollFloat(info.world.tool_enemy_spawn_rate / 100.0)
		if add_tool:
			var odds: Dictionary = info.world.tool_enemy_spawn_rarity_odds.getDictionary()
			var rarity: Game.Rarities = int(Random.getRandomKey(Random.onConvertPercentOdds(odds)))
			var tool_info: ToolInfo = Helper.getFofInfoArray(ToolInfo).filter(func(x: ToolInfo): return x.rarity == rarity).pick_random()
			tool_data = tool_info.saved_data.new(tool_info.id, true)
			
			var ascend_tool: bool = Random.rollFloat(info.world.tool_enemy_ascended_rate / 100.0)
			if ascend_tool:
				tool_data.ascended = true
			
			card_data.tool_data = tool_data
			
	return card_data
	
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
	save_file.onLoadMap()
	
func onLossFinished() -> void:
	pass
#endregion
