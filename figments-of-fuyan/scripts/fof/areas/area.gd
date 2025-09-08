class_name AreaGD extends FofGD

#region Global
signal init_load
signal process_action

const WORLD_ONE_DATASTORE_PATH: String = "res://resources/datastore/world/world_one.tres"
const WORLD_TWO_DATASTORE_PATH: String = "res://resources/datastore/world/world_two.tres"
const WORLD_THREE_DATASTORE_PATH: String = "res://resources/datastore/world/world_three.tres"

var map_location_to_node: Dictionary
var basic_card_ids: Array = []
var active_level: LevelGD

const JUNK_MAN_ID: int = 12
const EPIC_CARD_REWARDS_CARD_AMOUNT: int = 3
const MIRROR_CARD_REWARD_AMOUNT: int = 3
#endregion

#region Saved Data
var map_nodes_data: Array = []

var active_map_node_data: SavedDataMapNode # Data of the last entered map node
var active_level_data: SavedDataLevel
var encountered_encounter_ids: Array = []
#endregion

#region Helper
func getWorldDifficulty() -> int:
	return world.world
	
func getWorld() -> WorldDatastore:
	return world

func onFindEmptyMapSpot(progress: int, lane: int) -> EmptyMapNode:
	for empty_map_spot in empty_spots:
		if empty_map_spot.progress == progress and empty_map_spot.lane == lane: return empty_map_spot
	return null
	
func getProgress() -> int:
	var data: Array = get_tree().get_nodes_in_group("MapNodesGD")
	if data.is_empty(): data = map_nodes_data
	data = data.filter(func(x: Variant): return x.is_entered)
	if data.is_empty(): return 0
	return data.map(func(x: Variant): return x.map_location.progress).max()
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
	onLoadWorldDatastore()
	
func onLoadWorldDatastore() -> void:
	match Game.getSaveFile().getWorldDifficulty():
		1: world = load(WORLD_ONE_DATASTORE_PATH)
		2: world = load(WORLD_TWO_DATASTORE_PATH)
		3: world = load(WORLD_THREE_DATASTORE_PATH)
	
var is_init: bool = false
var world: WorldDatastore
func onFofInit() -> void:
	is_init = true
	empty_spots = onGenerateEmptyMapSpots()
	onGenerateMapLinks()
	
	setEmptySpotsIDS()
	setEliteFights()
	onCreateMapNodes()
	
func onLoadMap(parent: Node3D = self) -> void:
	for tile_object_data in info.overworld_decoration.data:
		SavedData.onLoadModel(tile_object_data, parent)
		
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
	empty_spots.append(EmptyMapNode.new(0, 0))
	
	for i in range(1, 12):
		if i == 1 and getWorldDifficulty() == 1: # To create shop at 1 - 1
			empty_spots.append(EmptyMapNode.new(i, 0))
			continue
			
		match i:
			5, 10: empty_spots.append(EmptyMapNode.new(i, 0))
			11:
				if Game.isDivinus(): empty_spots.append(EmptyMapNode.new(12, 0))
				empty_spots.append(EmptyMapNode.new(11, 0))
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
#endregion

#region Link-related
func onCreateMapLinks(empty_spots_by_progress: Dictionary[int, Array]) -> void:
	var section_one_batch: Dictionary[int, Array] = {}
	var section_two_batch: Dictionary[int, Array] = {}
	var is_divinus: bool = Game.isDivinus()
	var autolinks: Array = [0, 1, 4, 5, 9] if getWorldDifficulty() == 1 else [0, 4, 5, 9]
	for key: int in empty_spots_by_progress:
		if (key == 11 and !is_divinus) or key == 12: continue
		
		var batch: Array = empty_spots_by_progress[key]
		var next_batch: Array = empty_spots_by_progress[key + 1]
		
		if key >= 1 and key <= 3: section_one_batch[key] = batch
		elif key >= 6 and key <= 8: section_two_batch[key] = batch
		
		for empty_spot: EmptyMapNode in batch:
			for next_empty_spot: EmptyMapNode in next_batch:
				if next_empty_spot.lane == empty_spot.lane or key in autolinks:
					empty_spot.links.append(EmptyMapNodeLink.new(next_empty_spot))
		
	if !is_divinus:
		onGenerateLinksPerSection(section_one_batch, empty_spots_by_progress)
		onGenerateLinksPerSection(section_two_batch, empty_spots_by_progress)
		
func onGenerateLinksPerSection(section_batch: Dictionary[int, Array], empty_spots_by_progress: Dictionary[int, Array]) -> void:
	var section_progresses: Array = section_batch.keys()
	section_progresses.shuffle()
	
	var first_lane_link: int = 0
	var second_lane_link: int = 0
	
	for progress: int in section_progresses:
		if progress == 1 and getWorldDifficulty() == 1: continue
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
func setEmptySpotsIDS() -> void:
	empty_spots.shuffle()
		
	var unique_nodes: Array = Game.getSaveFile().getChampionCard().info.unique_nodes_id
	var used_ids: Array = []
	var encounter_progresses: Array = []
	var segment_two_encounter_pairs: Array = [[6, 9], [7, 9], [6, 8], [7, 8]].pick_random()
	encounter_progresses += segment_two_encounter_pairs
	
	if getWorldDifficulty() == 1:
		encounter_progresses.append([3, 4].pick_random())
	else:
		var segment_one_encounter_pairs: Array = [[1, 4], [2, 4], [1, 3], [2, 3]].pick_random()
		encounter_progresses += segment_one_encounter_pairs
		
	var segment_one_encounter_lane: int 
	var segment_one_encounter_progress: int
	var segment_two_encounter_lane: int
	var segment_two_encounter_progress: int
	var is_divinus: bool = Game.isDivinus()
	
	for empty_spot: EmptyMapNode in empty_spots:
		#var is_holy: bool = empty_spot.links.any(func(x: EmptyMapNodeLink): return x.is_holy)
		match empty_spot.progress:
			0: empty_spot.id = 1
			5: empty_spot.id = 7
			10:
				if is_divinus: empty_spot.id = 10
				else: empty_spot.id = 8
			11:
				if is_divinus: empty_spot.id = 8
				else: empty_spot.id = 2
			12: empty_spot.id = 2
			_:
				if empty_spot.progress == 1 and getWorldDifficulty() == 1:
					empty_spot.id = (6 if Helper.admin_datastore.spawn_instead_of_shop_id == 0 else Helper.admin_datastore.spawn_instead_of_shop_id)
				elif empty_spot.progress == 2 and getWorldDifficulty() == 1: empty_spot.id = 3
				elif empty_spot.progress in encounter_progresses:
					if empty_spot.progress < 5 and getWorldDifficulty() == 1: # First half of world one is two encounters
						setRandomEncounterId(empty_spot, used_ids, unique_nodes)
					elif empty_spot.isSegmentOne() and segment_one_encounter_lane == 0:
						segment_one_encounter_lane = empty_spot.lane
						segment_one_encounter_progress = empty_spot.progress
						setRandomEncounterId(empty_spot, used_ids, unique_nodes)
					elif empty_spot.isSegmentTwo() and segment_two_encounter_lane == 0:
						segment_two_encounter_lane = empty_spot.lane
						segment_two_encounter_progress = empty_spot.progress
						setRandomEncounterId(empty_spot, used_ids, unique_nodes)
					elif empty_spot.isSegmentOne():
						setSegmentEncounterShopId(empty_spot, segment_one_encounter_progress, segment_one_encounter_lane, used_ids, unique_nodes)
					elif empty_spot.isSegmentTwo():
						setSegmentEncounterShopId(empty_spot, segment_two_encounter_progress, segment_two_encounter_lane, used_ids, unique_nodes)
				else: empty_spot.id = 3
				
func setSegmentEncounterShopId(empty_spot: EmptyMapNode, segment_progress: int, segment_lane: int, used_ids: Array, unique_nodes: Array) -> void:
	if empty_spot.lane != segment_lane and empty_spot.progress == segment_progress:
		setRandomShopId(empty_spot, used_ids)
	elif empty_spot.lane != segment_lane and empty_spot.progress != segment_progress:
		setRandomEncounterId(empty_spot, used_ids, unique_nodes)
	elif empty_spot.lane == segment_lane and empty_spot.progress != segment_progress:
		setRandomShopId(empty_spot, used_ids)
				
func setRandomShopId(empty_spot: EmptyMapNode, used_ids: Array) -> void:
	empty_spot.id = Helper.getFofInfoArray(MapNodeInfo).filter(func(x: MapNodeInfo):\
		return x.is_shop and !x.is_unique and x.id not in used_ids).pick_random().id
	used_ids.append(empty_spot.id)
	
func setRandomEncounterId(empty_spot: EmptyMapNode, used_ids: Array, unique_nodes: Array) -> void:
	if unique_nodes.any(func(x: int): return x == 9) and empty_spot.progress >= 8: # Bounty Board
		empty_spot.id = 9
		unique_nodes.erase(9)
		return
		
	if JUNK_MAN_ID not in used_ids and getWorldDifficulty() == 1 and empty_spot.isSegmentTwo():
		empty_spot.id = JUNK_MAN_ID
	else:
		empty_spot.id = Helper.getFofInfoArray(MapNodeInfo).filter(func(x: MapNodeInfo):\
			return x.is_encounter and !x.is_shop and !x.is_unique and x.id not in used_ids).pick_random().id
		
	used_ids.append(empty_spot.id)
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
#endregion
#region Holy Path
func setHolyPath() -> void:
	if Game.isDivinus():
		var empty_map_node: EmptyMapNode = onFindEmptyMapSpot(0, 0)
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
	if map_node.isHoly(): Game.onIncrementHolyTravelledAmount()
	onPushAction(MapNodeEnteredAction.new(map_node))
			
func onMapNodeEntered(map_node: MapNodeGD) -> void:
	active_map_node_data = map_node.onSave()
			
func onMapNodeFinished(map_node: MapNodeGD) -> void:
	get_tree().call_group("MapNodesGD", "setRayPickableGlobal", true)
	get_tree().call_group("MapNodesGD", "onOtherMapNodeFinished", map_node)
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
	onClearMapNodes()
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
		var is_elite: bool = active_level.isElite()
		var is_epic: bool = active_level.isEpic()
		
		var is_curse_fight: bool = active_level.isCurseFight()
		var is_advanced_fight: bool = active_level.isAdvancedFight()
		
		var fight_rewards_datastore: FightRewardsDatastore = \
			getWorld().elite_fight_rewards if (is_epic or is_elite or is_curse_fight or is_advanced_fight) else getWorld().fight_rewards
		var level_preview: LevelPreview = active_level.level_preview
		var add_array: Array = getAddBoonAddTool(fight_rewards_datastore, is_elite, is_epic)
		var add_boon: bool = add_array[0]
		var add_tool: bool = add_array[1]
		
		if is_epic: items.append(onAddEpicReward(fight_type))
		items.append(onAddShillingReward(fight_rewards_datastore))
		if add_boon: items.append(onAddBoonReward())
		
		var card_reward: ActionWrapper = onAddCardRewards()
		if card_reward != null:
			items.append(card_reward)
		
		if add_tool: items.append(onAddToolReward())
		var rewards := Rewards.new(items.map(func(x: FofGD): return Reward.new(x)))
		rewards.setInfo(active_level)
		active_level.rewards = rewards
	active_level.onGameEnded()
	
func onAddEpicReward(fight_type: Game.FightTypes) -> ActionWrapper:
	var epic_rewards_wrapper: ActionWrapper = SavedData.onLoadModel(SavedDataActionWrapper.new(), active_level)
	var reward_type := ChooseRewardAction.RewardType.BOSS if fight_type == Game.FightTypes.BOSS else ChooseRewardAction.RewardType.MINIBOSS
	epic_rewards_wrapper.setActions(ChooseRewardAction.new(getEpicFightRewards(), reward_type))
	return epic_rewards_wrapper
	
func getAddBoonAddTool(fight_rewards_datastore: FightRewardsDatastore, is_elite: bool, is_epic: bool) -> Array:
	var add_tool: bool
	var add_boon: bool
	
	if !is_elite and !is_epic:
		add_tool = Random.rollFloat(fight_rewards_datastore.tool_odds)
		add_boon = Random.rollFloat(getDivinusBoonOdds(fight_rewards_datastore.boon_odds))
	else: # 50 / 50 chance if divinus, otherwise 66% 33% chance
		add_tool = Random.rollFloat((fight_rewards_datastore.tool_odds) if !Game.isDivinus() else 0.5)
		if !add_tool: add_boon = true
			
		if Random.rollFloat(getWorld().elite_fight_rewards_second_item_odds):
			add_tool = true
			add_boon = true
	return [add_boon, add_tool]
	
func onAddToolReward() -> ToolGD:
	var is_elite: bool = active_level.isEliteOrEpic()
	var tool_data: SavedDataTool = Random.getRandomToolData(getWorld().getToolRewardRarityOdds(is_elite), getWorld().getToolRewardTierUpOdds(is_elite))
	var Tool: ToolGD = SavedData.onLoadModel(tool_data, active_level)
	return Tool
	
func onAddBoonReward() -> BoonGD:
	var is_elite: bool = active_level.isEliteOrEpic()
	var boon_data: SavedDataBoon = Random.getRandomBoonData(getWorld().getBoonRewardRarityOdds(is_elite), getWorld().getBoonRewardTierUpOdds(is_elite))
	if boon_data != null:
		var Boon: BoonGD = SavedData.onLoadModel(boon_data, active_level)
		return Boon
	return null
	
func onAddCardRewards() -> ActionWrapper:
	var enemy_cards: Array = active_level.enemy_cards.duplicate()
	var level_preview: LevelPreview = active_level.getLevelPreview()
	var elite_exalt_id: int = level_preview.getEliteExaltId() if level_preview != null else 0
	var is_epic: bool = active_level.isEpic()
	var is_elite: bool = active_level.isElite()
	var is_mirror: bool = active_level.isMirrorFight()
	var is_foreign: bool = active_level.isForeignFight()
	
	if is_mirror: enemy_cards = onRollMirrorCardRewards()
	elif !is_epic: enemy_cards = onRollRegularCardRewards(elite_exalt_id, is_foreign)
	elif is_epic: enemy_cards = onRollEpicCardRewards()
	if is_elite and elite_exalt_id > 0: enemy_cards.append(onRollEliteCardReward(elite_exalt_id))

	if enemy_cards.is_empty(): return null
	var rewards_wrapper: ActionWrapper = SavedData.onLoadModel(SavedDataActionWrapper.new(), active_level)
	rewards_wrapper.setActions(ChooseRewardAction.new(enemy_cards, ChooseRewardAction.RewardType.CARDS))
	return rewards_wrapper
	
func onRollEliteCardReward(elite_exalt_id: int) -> CardGD:
	var fight_rewards_datastore: FightRewardsDatastore = getWorld().getEliteFightRewardsDatastore()
	var card_info: CardInfo = Helper.getFofInfoID(CardInfo, elite_exalt_id)
	
	var base_tier: int = getWorldDifficulty()
	var card_tier_up_odds: float = fight_rewards_datastore.getCardTierUpOdds()
	var tool_odds_datastore: RarityOddsDatastore = fight_rewards_datastore.getToolRarityOdds()
	var tool_odds: float = fight_rewards_datastore.getToolOdds()
	var tool_tier_up_odds: float = fight_rewards_datastore.getToolTierUpOdds()
	
	var card_data: SavedDataCard = Random.getCardDataFromInfo(card_info, base_tier, card_tier_up_odds, tool_odds_datastore, tool_odds, tool_tier_up_odds)
	var Card: CardGD = SavedData.onLoadModel(card_data, Game.getSaveFile())
	return Card
	
func onAddShillingReward(fight_rewards_datastore: FightRewardsDatastore) -> ActionWrapper:
	var shillings: int = randi_range(fight_rewards_datastore.shillings_min, fight_rewards_datastore.shillings_max)
	var change_shillings_wrapper: ActionWrapper = SavedData.onLoadModel(SavedDataActionWrapper.new(), active_level)
	change_shillings_wrapper.setActions(ChangeShillingsAction.new(shillings))
	return change_shillings_wrapper
	
func onRollRegularCardRewards(elite_exalt_id: int = 0, is_foreign: bool = false) -> Array:
	var base_tier: int = getWorldDifficulty()
	
	var card_ids: Array = []
	if !is_foreign: card_ids = basic_card_ids.duplicate()
	else:
		var foreign_area_id: int = active_level.getLevelAreaDatastore().getAreaID()
		var foreign_area_info: AreaInfo = Helper.getFofInfoID(AreaInfo, foreign_area_id)
		card_ids = foreign_area_info.card_ids.filter(func(x: int):\
			return Game.isBasicRarity(Helper.getFofInfoID(CardInfo, x).rarity))
			
	card_ids.erase(elite_exalt_id)
	var card_rewards: Array = []
	var fight_rewards_datastore: FightRewardsDatastore = getWorld().getFightRewardsDatastore()
	var card_rarity_odds: RarityOddsDatastore = fight_rewards_datastore.getCardRarityOdds()
	var tool_rarity_odds: RarityOddsDatastore = fight_rewards_datastore.getCardToolRarityOdds()
	var tool_odds: float = fight_rewards_datastore.getCardToolOdds()
	var tool_tier_up_odds: float = fight_rewards_datastore.getCardToolTierUpOdds()
	var tier_up_odds: float = fight_rewards_datastore.getCardTierUpOdds()
	
	for i in range(Game.CARD_REWARD_DEFAULT_AMOUNT):
		var card_data: SavedDataCard = Random.getRandomCardData(card_ids, card_rarity_odds, tool_rarity_odds,\
			base_tier, tier_up_odds, tool_odds, tool_tier_up_odds)
		card_data.team = 1
		card_ids.erase(card_data.id)
		card_rewards.append(SavedData.onLoadModel(card_data, active_level))
	return card_rewards
	
func onRollMirrorCardRewards() -> Array:
	var level_preview: LevelPreview = active_level.getLevelPreview()
	var card_rewards: Array = []
	var basic_rarities: Array = [Game.Rarities.COMMON, Game.Rarities.RARE, Game.Rarities.EXALT, Game.Rarities.MINIBOSS, Game.Rarities.BOSS]
	var card_datas: Array = level_preview.getCardDatas()\
		.filter(func(x: SavedDataCard): return Helper.getFofInfoID(CardInfo, x.id).rarity in basic_rarities)
		
	card_datas.resize(MIRROR_CARD_REWARD_AMOUNT)
	card_datas = card_datas.filter(func(x: SavedDataCard): return x != null)
	if card_datas.is_empty(): return []
	for card_data: SavedDataCard in card_datas:
		var dupe_card_data: SavedDataCard = Game.getDuplicateCardData(card_data)
		dupe_card_data.tool_data = null
		dupe_card_data.team = 1
		card_rewards.append(SavedData.onLoadModel(dupe_card_data, active_level))
	return card_rewards
	
func onRollEpicCardRewards() -> Array:
	var is_boss: bool = active_level.isBoss()
	var base_tier: int = getWorldDifficulty() + (1 if is_boss else 0)
	var card_rewards: Array = []
	var card_ids: Array = basic_card_ids.duplicate() 
	
	if is_boss:
		var new_area_id: int = Game.getSaveFile().getAreaIds()[min(getWorldDifficulty(), 2)]
		var new_area_info: AreaInfo = Helper.getFofInfoID(AreaInfo, new_area_id)
		card_ids = new_area_info.card_ids.filter(func(x: int): \
			return Game.isBasicRarity(Helper.getFofInfoID(CardInfo, x).rarity))
		
	var elite_fight_rewards_datastore: FightRewardsDatastore = getWorld().getEliteFightRewardsDatastore()
	var card_rarity_odds: RarityOddsDatastore = elite_fight_rewards_datastore.getCardRarityOdds()
	var tool_rarity_odds: RarityOddsDatastore = elite_fight_rewards_datastore.getCardToolRarityOdds()
	var tool_odds: float = elite_fight_rewards_datastore.getCardToolOdds()
	var tool_tier_up_odds: float = elite_fight_rewards_datastore.getCardToolTierUpOdds()
	var tier_up_odds: float = elite_fight_rewards_datastore.getCardTierUpOdds()
	
	for i in range(EPIC_CARD_REWARDS_CARD_AMOUNT):
		var card_data: SavedDataCard = Random.getRandomCardData(card_ids, card_rarity_odds, tool_rarity_odds,\
			base_tier, tier_up_odds, tool_odds, tool_tier_up_odds)
		
		card_data.team = 1
		card_ids.erase(card_data.id)
		card_rewards.append(SavedData.onLoadModel(card_data, active_level))
	return card_rewards
	
func getEpicFightRewards() -> Array:
	var boss_card: EpicCardGD = active_level.getBoss()
	
	var card_info: CardInfo = Helper.getFofInfoID(CardInfo, boss_card.info.card_id)
	var card_data := SavedDataCard.new(card_info.id, true)
	card_data.team = 1
	Game.setCardDataFromInfo(card_data, card_info)
	
	var boon_data := SavedDataBoon.new(boss_card.info.boon_id, true)
	var tool_data := SavedDataTool.new(boss_card.info.tool_id, true)
	
	var world_difficulty: int = getWorldDifficulty()
	boon_data.tier = world_difficulty
	tool_data.tier = world_difficulty
	card_data.tier = world_difficulty
	
	var Card: CardGD = SavedData.onLoadModel(card_data, active_level)
	var Boon: BoonGD = SavedData.onLoadModel(boon_data, active_level)
	var Tool: ToolGD = SavedData.onLoadModel(tool_data, active_level)
	
	return [Boon, Tool, Card]
#endregion

#region Random Enemy
func onCreateCardByEnergy(_cards: Array, energy: int, spawn: SavedDataSpawn, progress: int, is_elite: bool, tier: int) -> SavedDataCard:
	var world_difficulty: int = getWorldDifficulty()
	var original_cards: Array = _cards.filter(func(x: CardInfo):\
		return x.getTierDatastore(world_difficulty).getEnergy() == energy)
	var cards: Array = getCardsByRarity(original_cards)
	return onCreateEnemyCard(cards.pick_random(), tier, spawn.coords, progress, is_elite)

	
func onCreateEnemyCard(card_info: CardInfo, tier: int, coords: Vector4i, progress: int, is_elite: bool) -> SavedDataCard:
	var card_data: SavedDataCard = card_info.saved_data.new(card_info.id, true)
	card_data.tier = tier
	card_data.team = 1
	card_data.coords = coords
	
	if progress < 3:
		Game.setCardDataFromInfo(card_data, card_info)
		return card_data
		
	var tier_up_rate: float = getWorld().enemy_tier_up_rate if !is_elite else getWorld().elite_enemy_tier_up_rate
	var tier_up_card: bool = Random.rollFloat(tier_up_rate)
	if tier_up_card: card_data.onTierUp()
	
	var tool_spawn_rate: float = getWorld().tool_enemy_spawn_rate
	var add_tool: bool = Random.rollFloat(tool_spawn_rate)
	if !add_tool:
		Game.setCardDataFromInfo(card_data, card_info)
		return card_data
	
	card_data.tool_data = Random.getRandomToolData(getWorld().getToolEnemySpawnRarityOdds(), getWorld().getToolEnemySpawnTierOdds())
	Game.setCardDataFromInfo(card_data, card_info)
	return card_data
	
func getCardsByRarity(original_cards: Array) -> Array:
	@warning_ignore("int_as_enum_without_cast")
	var rarity: Game.Rarities = int(Random.getRandomKey(getWorld().getEnemySpawnRarityOdds().getDictionary()))
	var cards: Array = original_cards.filter(func(x: CardInfo): return x.rarity == rarity)
	if cards.is_empty(): return getCardsByRarity(original_cards)
	return cards
	
func setEnemySpawnsFromBudget(budget: int, spawns: Array, progress: int, elite_exalt_id: int = 0, area_id_override: int = 0) -> Array:
	var is_elite: bool = elite_exalt_id > 0
	var min_spawn_amount: int = getMinSpawnAmount(budget)
	var max_spawn_amount: int = getMaxSpawnAmount(budget, spawns.size())
	
	var _basic_card_ids: Array = basic_card_ids if area_id_override == 0 else\
		Helper.getFofInfoID(AreaInfo, area_id_override).card_ids.filter(func(x: int):\
		return Game.isBasicRarity(Helper.getFofInfoID(CardInfo, x).rarity))
		
	var cards: Array = Helper.getFofInfoArray(CardInfo).filter(func(x: CardInfo): return x.id in _basic_card_ids)
	
	var world_difficulty: int = getWorldDifficulty()
	var energies: Array = cards.map(func(x: CardInfo): return x.getTierDatastore(world_difficulty).getEnergy())
	var highest_cost: int = energies.max()
	var lowest_cost: int = energies.min()
	
	var spawn_amount: int = getSpawnAmountFromMinMax(min_spawn_amount, max_spawn_amount)
	var energy_combination: Array = getRandomEnergyCombination(budget, spawn_amount, lowest_cost, highest_cost)\
		if budget > 6 else getEnergyCombinationFromBudget(budget, lowest_cost, highest_cost, min_spawn_amount, max_spawn_amount)
		
	var other_enemies_ids: Array = get_tree().get_nodes_in_group("FightMapNodesGD")\
		.filter(func(x: MapNodeGD): return x.map_location.progress == progress)\
		.map(func(y: MapNodeGD): return y.enemy_cards.map(func(z: SavedDataCard): return z.id))
		
	while(true):
		var enemies: Array = [] if elite_exalt_id == 0\
			else [onCreateEnemyCard(Helper.getFofInfoID(CardInfo, elite_exalt_id), getWorldDifficulty(), spawns[spawns.size() - 1].coords, progress, is_elite)]
			
		for i in range(energy_combination.size() - enemies.size()):
			var card_data: SavedDataCard = onCreateCardByEnergy(cards, energy_combination[i], spawns[i], progress, is_elite, world_difficulty)
			enemies.append(card_data)
		
		var enemies_ids: Array = enemies.map(func(x: SavedDataCard): return x.id)
		if !other_enemies_ids.is_empty() and other_enemies_ids.any(func(x: Array): return x == enemies_ids):
			continue
		
		return enemies
	return []
	
func getSpawnAmount(budget: int, spawn_size: int) -> int:
	var min_spawn_amount: int = getMinSpawnAmount(budget)
	var max_spawn_amount: int = getMaxSpawnAmount(budget, spawn_size)
	return getSpawnAmountFromMinMax(min_spawn_amount, max_spawn_amount)
	
func getSpawnAmountFromMinMax(s_min: int, s_max: int) -> int:
	if s_min == s_max:
		return s_min

	var low: int = min(s_min, s_max)
	var high: int = max(s_min, s_max)
	
	var r1: int = randi_range(low, high)
	var r2: int = randi_range(low, high)
	return int(round((r1 + r2) / 2.0))
	
func getMinSpawnAmount(budget: int) -> int:
	return ceil(float(budget) / 4.0)
	
func getMaxSpawnAmount(budget: int, spawn_size: int) -> int:
	return min(ceil(float(budget) / 2.0), spawn_size) if budget > 4 else 3
	
const PREVIEW_RARITY_VALUE: Dictionary[Game.Rarities, int] = {
	Game.Rarities.COMMON: 1,
	Game.Rarities.RARE: 2,
	Game.Rarities.EXALT: 4,
	Game.Rarities.CHAMPION: 8,
}
	
func getLevelPreview(enemy_cards: Array, elite_exalt_id: int = 0, curse_id: int = 0) -> LevelPreview:
	enemy_cards = enemy_cards.duplicate()
	var total_amount: int = enemy_cards.size()
	var enemy_card_to_preview_value: Dictionary[SavedDataCard, float] = {}
	
	if elite_exalt_id > 0:
		for card_data: SavedDataCard in enemy_cards:
			if card_data.id == elite_exalt_id: # Only first is removed
				enemy_cards.erase(card_data)
				break
	
	for card_data: SavedDataCard in enemy_cards:
		var card_info: CardInfo = Helper.getFofInfoID(CardInfo, card_data.id)
		var rarity_value: int = PREVIEW_RARITY_VALUE[card_info.rarity]
		var tool_value: float = 0.5 if (card_data.tool_data != null) else 0.0
		var total_value: float = rarity_value + card_data.energy + tool_value + card_data.tier
		enemy_card_to_preview_value[card_data] = total_value
		
	enemy_cards.sort_custom(func(x: SavedDataCard, y: SavedDataCard):\
		return enemy_card_to_preview_value[x] > enemy_card_to_preview_value[y])
	enemy_cards.resize(Game.CARD_REWARD_DEFAULT_AMOUNT)
	enemy_cards = enemy_cards.filter(func(x: SavedDataCard): return x != null)
	return LevelPreview.new(enemy_cards, total_amount, elite_exalt_id, curse_id)
	
const BUDGET_TO_COMBINATION_ODDS: Dictionary[int, Dictionary] = {
	1: {
		[1]: 1.0,
	},
	2: {
		[1, 1]: 0.5,
		[2]: 0.5,
	},
	3: {
		[1, 1, 1]: 0.3,
		[1, 2]: 0.4,
		[3]: 0.3
	},
	4: {
		[1, 1, 1, 1]: 0.05,
		[1, 1, 2]: 0.3,
		[2, 2]: 0.3,
		[1, 3]: 0.3,
		[4]: 0.05,
	},
	5: {
		[1, 1, 1, 1, 1]: 0.01,
		[1, 1, 1, 2]: 0.15,
		[1, 1, 3]: 0.25,
		[1, 2, 2]: 0.25,
		[1, 4]: 0.08,
		[2, 3]: 0.25,
		[5]: 0.01,
	},
	6: {
		[1, 1, 1, 1, 1, 1]: 0.005,
		[1, 1, 1, 1, 2]: 0.01,
		[1, 1, 2, 2]: 0.14,
		[1, 1, 1, 3]: 0.14,
		[1, 2, 3]: 0.14,
		[1, 1, 4]: 0.14,
		[2, 2, 2]: 0.14,
		[2, 4]: 0.14,
		[3, 3]: 0.14,
		[1, 5]: 0.05,
	}
}
	
func getEnergyCombinationFromBudget(budget: int, lowest_cost: int, highest_cost: int, min_spawn_amount: int, max_spawn_amount: int) -> Array:
	var budget_odds_dictionary: Dictionary = BUDGET_TO_COMBINATION_ODDS[budget]
	var energy_combination: Array = []
	var max_attempts: int = 128
	var i: int = 0
	
	while(i < max_attempts):
		energy_combination = Random.getRandomKeyVariant(budget_odds_dictionary)
		if energy_combination.size() >= min_spawn_amount and energy_combination.size() <= max_spawn_amount\
			and energy_combination.all(func(x: int): return x >= lowest_cost and x <= highest_cost):
			return energy_combination
		i += 1
	push_warning("No valid budget found")
	return []
	
func getRandomEnergyCombination(budget: int, enemy_spawn_amount: int, lowest_cost: int, highest_cost: int) -> Array:
	var original_energy_combinations: Array = onGenerateCombinations(lowest_cost, highest_cost, enemy_spawn_amount)
	var energy_combinations: Array = original_energy_combinations.filter(func(x: Array): return x.reduce(sum, 0) == budget)
	var energy_combination: Array = []
	if !energy_combinations.is_empty(): # Remove later
		energy_combination = energy_combinations.pick_random()
	else: energy_combination = original_energy_combinations.pick_random(); print("USED ILLEGAL COMBINATION!")
	return energy_combination
	
func getBudget(progress: int, offset: int = 0) -> int:
	return getWorld().budget_for_fights[min(progress, 10)] + offset
	
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
	var fight_type: Game.FightTypes = active_level.fight_type
	var _active_level_data: SavedDataLevel = active_level.onSave()
	
	active_level.onClear()
	active_level = null
	active_level_data = null
	
	var actions: Array = [CreateMapAction.new(), LevelRewardsFinishedAction.new(_active_level_data)]
	if fight_type in [Game.FightTypes.MINIBOSS, Game.FightTypes.BOSS]:
		var old_deck_limit: int = Game.getSaveFile().getDeckLimit()
		var old_energy_limit: int = Game.getSaveFile().getEnergyLimit()
		var old_max_energy: int = Game.getSaveFile().getMaxEnergy()
		actions += [ChampionUpgradeAction.new(old_deck_limit, old_energy_limit, old_max_energy),\
			Game.getSaveFile().getPlayerDeckUpgradeAction(getWorldDifficulty(), fight_type)]
	onPushAction(actions)
	
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
	
	if action.post:
		if action is MapNodeEnteredAction:
			onMapNodeEntered(action.map_node)
		elif action is MapNodeFinishedAction:
			onMapNodeFinished(action.map_node)
		elif action is CreateLevelAction:
			active_level_data = action.getLevelData()
#endregion

func getEnvironmentFromInfo(is_elite: bool) -> Environment:
	return info.base_environment if !is_elite else info.elite_environment

func onClearMapNodes() -> void:
	if map_nodes_data.is_empty():
		map_nodes_data = SavedData.onSaveGroup(get_tree().get_nodes_in_group("MapNodesGD")) # Save map nodes data
	get_tree().call_group("MapNodesGD", "onClear")

func getBasicCardIds() -> Array:
	return basic_card_ids.duplicate()

func getLevelInfoForProgress(progress: int) -> LevelInfo:
	var level_script: GDScript = Game.getArea().info.base_level_script
	var existing_level_ids: Array = get_tree().get_nodes_in_group("FightMapNodesGD")\
		.filter(func(x: MapNodeGD): return x.map_location.progress == progress and x != self)\
		.map(func(y: MapNodeGD): return y.level_info.id if y.level_info != null else 0)\
		.filter(func(z: int): return z != 0)
	var budget: int = Game.getArea().getBudget(progress, 0)
	var levels: Array = Helper.getFofInfoArray(LevelInfo)
	levels = levels.filter(func(x: LevelInfo): return x.gdscript == level_script)
	levels = levels.filter(func(x: LevelInfo): return budget >= x.budget_min and budget <= x.budget_max)
	
	if levels.size() > existing_level_ids.size():
		levels = levels.filter(func(x: LevelInfo): return x.id not in existing_level_ids)
	return levels.pick_random()

func getAreaColor() -> Color: return info.getAreaColor()
func getSecondAreaColor() -> Color: return info.getSecondAreaColor()
func getThirdAreaColor() -> Color: return info.getThirdAreaColor()

func getInfo() -> AreaInfo: return info
