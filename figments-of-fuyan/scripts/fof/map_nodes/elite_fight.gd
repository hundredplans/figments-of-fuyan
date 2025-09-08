class_name EliteFightNodeGD extends FightNodeGD

var curse_id: int
const MAX_RESTART_AMOUNT: int = 16

var EXALT_ID_TO_CURSE_ID: Dictionary = {
	71: 28, # Axel
	18: 29, # Palmfessor
	19: 30, # Hocus 
	17: 31, # Angrus
	72: 32, # Jibben
	73: 33 # Havel
}

func onFofInit() -> void:
	setRandomCurseID()
	super()
	
func onCreateLevelPreview(enemy_cards: Array) -> void:
	level_preview = Game.getArea().getLevelPreview(enemy_cards, getEliteExaltId(), curse_id)
	
func getEliteExaltId() -> int:
	for key: int in EXALT_ID_TO_CURSE_ID.keys():
		var value: int = EXALT_ID_TO_CURSE_ID[key]
		if value == curse_id: return key
	return 0
	
func onSave() -> SavedDataMapNode:
	return SavedDataEliteFight.new(info.id, false, public_id, map_location, links, is_entered, is_finished, rotation.y, ability_save, level_info,\
		spawn_group, enemy_cards, level_preview, level_public_id, curse_id)
	
func onLoadData(data: SavedData) -> void:
	super(data)
	curse_id = data.curse_id
	add_to_group("EliteFightMapNodesGD")
	
func onEntered() -> void:
	super()
	
func setRandomCurseID() -> void:
	if Helper.admin_datastore.force_elite_fight_curse_id == 0:
		var existing_curse_ids: Array = get_tree().get_nodes_in_group("EliteFightMapNodesGD").map(func(x: MapNodeGD): return x.getCurseId())
		var exalts: Array = EXALT_ID_TO_CURSE_ID.keys()
		var keep_ids: Array = Game.getArea().getBasicCardIds()
		exalts = exalts.filter(func(x: int): return x in keep_ids)
		
		var curse_ids: Array = exalts.map(func(x: int): return EXALT_ID_TO_CURSE_ID[x])
		curse_ids = curse_ids.filter(func(x: int): return x not in existing_curse_ids)
		curse_id = curse_ids.pick_random()
	else: curse_id =  Helper.admin_datastore.force_elite_fight_curse_id
	
func onEnteredInit() -> void:
	super()
	var new_level_data: SavedDataLevel = level_info.saved_data.new(level_info.id, true, 0, level_info.data.duplicate())
	new_level_data.spawn_group = spawn_group
	new_level_data.level_preview = level_preview
	new_level_data.enemy_cards = enemy_cards
	new_level_data.fight_type = Game.FightTypes.ELITE
	new_level_data.curse_id = curse_id
	level_public_id = Game.onIncrementPublicID()
	new_level_data.public_id = level_public_id
	onPushLoadingScreenAction(new_level_data)

func getBudget() -> int:
	return Game.area.getBudget(map_location.progress, Game.getArea().getWorldDifficulty())
	
func getCurseId() -> int: return curse_id
