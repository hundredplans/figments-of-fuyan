class_name AreaGD extends FofGD

#region Global
signal map_node_selected
signal map_nodes_loaded
signal map_node_entered
signal map_node_finished
var map_location_to_node: Dictionary
var map_location: MapLocation
var overworld_level: OverworldLevelGD

#endregion

#region Helper
func onFindMapLocation(progress: int, lane: int) -> MapLocation:
	for _map_location in map_location_to_node:
		if _map_location.progress == progress and _map_location.lane == lane: return _map_location
	return null

#endregion

#region Save / Load
func onSave() -> SavedDataArea:
	var map_nodes_data: Array[SavedDataMapNode] = []
	for map_node in get_tree().get_nodes_in_group("MapNodesGD"):
		map_nodes_data.append(map_node.onSave())
		
	return SavedDataArea.new(info.id, overworld_level.info.id, map_location, map_nodes_data)
	
func onLoadData(data: SavedData) -> void:
	super(data)
	map_location = data.map_location
	
	var overworld_level_id: int
	if !Helper.admin: overworld_level_id = data.overworld_level_id
	else: overworld_level_id = 99999
	
	overworld_level = SavedData.onLoadModel(SavedDataOverworldLevel.new(overworld_level_id), self)
	for map_node_data in data.map_nodes_data: SavedData.onLoadModel(map_node_data, self)
	add_to_group("AreasGD")
#endregion
	
#region Create Map Nodes
func onCreateMapNodes(Card: CardGD) -> void:
	var empty_spots: Array[EmptyMapNode] = generateEmptyMapSpots()
	generateMapLinks(empty_spots)
	var map_node_odds: Dictionary = getMapNodeOdds()
	var unique_node_id: Array = Card.info.unique_nodes_id
	
	setEmptySpotsIDS(empty_spots, unique_node_id, map_node_odds)
	setEliteChiefFights(empty_spots, map_node_odds, Card)
	onLoadMapNodes(empty_spots)

#region Generators
func generateEmptyMapSpots() -> Array[EmptyMapNode]:
	var empty_spots: Array[EmptyMapNode] = []
	if info.world.world == 1: empty_spots.append(EmptyMapNode.new(-1, 0))
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
	
func generateMapLinks(empty_spots: Array) -> void:
	var empty_spots_by_progress: Dictionary = generateEmptySpotsByProgress(empty_spots)
	onCreateAllMapLinks(empty_spots_by_progress)
	onRemoveOverlappingMapLinks(empty_spots_by_progress)
	onRemoveEdgesAtRandom(empty_spots_by_progress)
			
func generateEmptySpotsByProgress(empty_spots: Array) -> Dictionary:
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
		
		if next_batch.size() == 1: for empty_spot in batch: empty_spot.links.append(next_batch[0])
		elif batch.size() == 1: for empty_spot in next_batch: batch[0].links.append(empty_spot)
		else:
			for empty_spot in batch:
				for _empty_spot in next_batch:
					if empty_spot.lane == _empty_spot.lane or empty_spot.lane == _empty_spot.lane + 1\
					or empty_spot.lane == _empty_spot.lane - 1:
						empty_spot.links.append(_empty_spot)
						
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
	for link in empty_spot.links:
		if link.lane == next_empty_spot.lane:
			for _link in next_empty_spot.links:
				if _link.lane == empty_spot.lane:
					return {empty_spot: link, next_empty_spot: _link}
	return {}
	
func onRemoveEdgesAtRandom(empty_spots_by_progress: Dictionary) -> void:
	for key in empty_spots_by_progress:
		if key == 10: break
		var batch: Array = empty_spots_by_progress[key]
		var next_batch: Array = empty_spots_by_progress[key + 1]
		onFilterNextBatchToManyLinks(batch, next_batch)
		batch.shuffle()
		
		for empty_spot in batch.filter(func(x: EmptyMapNode): return x.links.size() > 1):
			var erase_array: Array = []
			for link in empty_spot.links.filter(func(y: EmptyMapNode): return y in next_batch):
				var remove_link: bool = Random.rollFloat(info.world.REMOVE_RANDOM_EDGES)
				if remove_link:
					erase_array.append(link)
					next_batch.erase(link)
			for link in erase_array: empty_spot.links.erase(link)
			
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
func setEmptySpotsIDS(empty_spots: Array, unique_node_ids: Array, map_node_odds: Dictionary) -> void:
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
			0: empty_spot.id = 1 if info.world.world > 1 else 2; continue # Gildred
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
		elif guarantee_unique_node.size() > 0:
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
func setEliteChiefFights(empty_spots: Array, map_node_odds: Dictionary, Card: CardGD) -> void:
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
func onLoadMapNodes(empty_spots: Array) -> void:
	for empty_spot in empty_spots: empty_spot.map_location = MapLocation.new(empty_spot.progress, empty_spot.lane, map_location.area)
	var map_locations: Array = empty_spots.map(func(x: EmptyMapNode): return x.map_location)
	
	for empty_spot in empty_spots:
		var links: Array = empty_spot.links.map(func(x: EmptyMapNode): return MapLink.new(x.map_location, false))
		var saved_data: SavedDataMapNode = MapNodeInfo.getDataFromID(empty_spot.id).new(empty_spot.id, empty_spot.map_location, links)
		var map_node: MapNodeGD = SavedData.onLoadModel(saved_data, self)
		map_node.onCreateModel(map_locations)
		map_node.onFofInit()
		map_location_to_node[map_node.map_location] = map_node
		
	for map_node in get_tree().get_nodes_in_group("MapNodesGD"):
		map_node.onCreateLinks(map_location_to_node)
		map_node.hovered.connect(onMapNodeHovered)
		map_node.pressed.connect(onMapNodePressed)
		map_node.entered.connect(onMapNodeEntered)
	
	map_nodes_loaded.emit()
	onSelectMapNode(onFindMapLocation(map_location.progress, map_location.lane), true)
#endregion
#endregion

#region Map Noodes
const SELECTED_SPEED: float = 1
func getSelectedMapNode() -> MapNodeGD:
	return map_location_to_node[map_location]

func onSelectMapNode(_map_location: MapLocation, is_initial_load_select: bool = false) -> void:
	if !is_initial_load_select:
		var selected_map_node: MapNodeGD = getSelectedMapNode()
		selected_map_node.onDeselected(SELECTED_SPEED)
		
	map_location = _map_location
	var map_node: MapNodeGD = map_location_to_node[map_location]
	map_node.onSelected(SELECTED_SPEED)
	map_node_selected.emit(map_node, SELECTED_SPEED, is_initial_load_select)
	
func onMapNodeHovered(map_node: MapNodeGD, state: bool) -> void:
	var selected_map_node: MapNodeGD = getSelectedMapNode()
	if !state or map_node != selected_map_node:
		var is_walkable: bool = selected_map_node.isMapNodeLink(map_node)
		map_node.onStaticBodyHovered(is_walkable, state)
	
func onMapNodePressed(map_node: MapNodeGD) -> void:
	var selected_map_node: MapNodeGD = getSelectedMapNode()
	if selected_map_node.isMapNodeLink(map_node):
		onSelectMapNode(map_node.map_location)
		
func onMapNodeEntered(map_node: MapNodeGD) -> void:
	if map_node == getSelectedMapNode():
		map_node_entered.emit(map_node)
			
func onMapNodeFinished() -> void:
	var sel: MapNodeGD = getSelectedMapNode()
	map_node_finished.emit(getSelectedMapNode())
#endregion

#region Getters
func getBossMapNode() -> MapNodeGD:
	return getNodeByID(10)
	
func getStartMapNode() -> MapNodeGD:
	return getNodeByID(1)
	
func getNodeByID(id: int) -> MapNodeGD:
	for map_node in get_tree().get_nodes_in_group("MapNodesGD"):
		if map_node.info.id == id: return map_node
	return null
#endregion
