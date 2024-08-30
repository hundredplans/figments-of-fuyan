class_name WorldDatastore extends Resource

#region Exports
@export var world: int
@export var data: Array[MapNodeOddsDatastore]
@export_range(0, 100, 0.1) var elite_increase_after_shop_or_encounter: float

@export_group("Start of Generation")
@export_range(0, 100, 0.1) var unique_node_segment_one_odds: float
@export_range(0, 100, 0.1)  var unique_node_segment_two_odds: float
@export_group("")

@export_group("Constants across Worlds")
@export var LANE_ODDS: Dictionary = {
	"2": 0.25,
	"3": 0.7,
	"4": 0.05, 
}
@export var REMOVE_RANDOM_EDGES: float = 0.5
#endregion

#region Map Nodes
func onGenerateBaseMapNodes(parent: Node3D, base_map_location: MapLocation, Card: CardGD) -> void:
	var empty_spots: Array[EmptyMapNode] = generateEmptyMapSpots()
	generateMapLinks(empty_spots)
	var map_node_odds: Dictionary = getMapNodeOdds()
	var unique_node_id: Array = Card.info.unique_nodes_id
	
	setEmptySpotsIDS(empty_spots, unique_node_id, map_node_odds)
	setEliteChiefFights(empty_spots, map_node_odds, Card)
	onLoadMapNodes(empty_spots, parent, base_map_location)
	
#endregion
	
#region Generators
func generateEmptyMapSpots() -> Array[EmptyMapNode]:
	var empty_spots: Array[EmptyMapNode] = []
	if world == 1: empty_spots.append(EmptyMapNode.new(-1, 0))
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
	return int(Random.getRandomKey(LANE_ODDS))
	
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
				var remove_link: bool = Random.rollFloat(REMOVE_RANDOM_EDGES)
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
		extra_unique_node_segment_one = Random.rollFloat(unique_node_segment_one_odds / 100)
		extra_unique_node_segment_two = Random.rollFloat(unique_node_segment_two_odds / 100)
		
	for empty_spot in empty_spots:
		match empty_spot.progress:
			-1: empty_spot.id = 1; continue
			0: empty_spot.id = 1 if world > 1 else 2; continue # Gildred
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
	for odds in data: map_node_odds[odds.progress] = odds
	return map_node_odds
	
func getExtraEliteChiefOdds(Card: CardGD) -> float:
	if Card.info.id == 1: return Card.extra_elite_chief_odds
	return 0
#endregion

#region Map Nodes
func onLoadMapNodes(empty_spots: Array, parent: Node3D, base_location: MapLocation) -> void:
	for empty_spot in empty_spots:
		var map_location := MapLocation.new(empty_spot.progress, empty_spot.lane, base_location.world, base_location.area, false)
		var links: Array[MapLocation]
		var _links: Array =  empty_spot.links.map(func(x: EmptyMapNode): return MapLocation.new(x.progress, x.lane, base_location.world, base_location.area))
		links.assign(_links)
		
		var saved_data: SavedDataMapNode = MapNodeInfo.getDataFromID(empty_spot.id).new(empty_spot.id, map_location, links)
		SavedData.onLoadModel(saved_data, parent)
#endregion
