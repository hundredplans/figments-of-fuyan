extends EncounterGD

const SPECIAL_FIGHT_TYPES: Array = ["Mirror Fight", "Curse Fight", "Advanced Fight"]
const CURSE_IDS: Array = [11, 12, 13, 14, 15]
var special_fight_type: String
var curse_id: int

func onFofInit() -> void:
	super()
	special_fight_type = SPECIAL_FIGHT_TYPES.pick_random()

func onSave() -> SavedDataEncounter:
	ability_save['curse_id'] = curse_id
	ability_save['special_fight_type'] = special_fight_type
	return super()

func getSpecialFightType() -> String:
	return special_fight_type

func isDragZone() -> bool: return false

func onFinished() -> void:
	super()
	
	if curse_id == 0: return
	onPushAction(RemoveBoonAction.new(curse_id))

func onCreateRegularFight() -> void:
	var progress: int = Game.getArea().getProgress()
	var level_info: LevelInfo = Game.getArea().getLevelInfoForProgress(Game.getArea().getProgress())
	var spawn_group: int = level_info.getRandomSpawnGroup()
	var enemy_spawns: Array = level_info.getEnemySpawnsInGroup(spawn_group) # Array[SavedDataSpawn]
	enemy_spawns.shuffle()
	
	var budget: int = Game.getArea().getBudget(progress)
	var enemy_cards: Array = Game.getArea().setEnemySpawnsFromBudget(budget, enemy_spawns, progress)
	var level_data: SavedDataLevel = level_info.saved_data.new(level_info.id, true, 0, level_info.data.duplicate())
	level_data.enemy_cards = enemy_cards
	level_data.spawn_group = spawn_group
	level_data.fight_type = Game.FightTypes.REGULAR
	load_level.emit(level_data)
	
func onCreateSpecialFight() -> void:
	var progress: int = Game.getArea().getProgress()
	var level_info: LevelInfo = Game.getArea().getLevelInfoForProgress(Game.getArea().getProgress())
	var spawn_group: int = level_info.getRandomSpawnGroup()
	var enemy_spawns: Array = level_info.getEnemySpawnsInGroup(spawn_group) # Array[SavedDataSpawn]
	enemy_spawns.shuffle()
	
	match getSpecialFightType():
		"Mirror Fight": onCreateMirrorFight(level_info, enemy_spawns, spawn_group, progress)
		"Curse Fight": onCreateCurseFight(level_info, enemy_spawns, spawn_group, progress)
		"Advanced Fight": onCreateAdvancedFight(level_info, enemy_spawns, spawn_group, progress)

func onCreateAdvancedFight(level_info: LevelInfo, enemy_spawns: Array, spawn_group: int, progress: int) -> void:
	var budget: int = Game.getArea().getBudget(progress)
	var enemy_cards: Array = Game.getArea().setEnemySpawnsFromBudget(budget, enemy_spawns, progress)
	
	for card_data: SavedDataCard in enemy_cards:
		card_data.tier = min(card_data.tier + 1, Game.MAX_CARD_TIER)
		Game.setCardDataFromInfo(card_data, Helper.getFofInfoID(CardInfo, card_data.id))
		
		if card_data.tool_data != null:
			card_data.tool_data.tier = min(card_data.tool_data.tier + 1, Game.MAX_TOOL_TIER)
	
	var level_data: SavedDataLevel = level_info.saved_data.new(level_info.id, true, 0, level_info.data.duplicate())
	level_data.enemy_cards = enemy_cards
	level_data.spawn_group = spawn_group
	level_data.fight_type = Game.FightTypes.COLOSSEUM
	load_level.emit(level_data)

func onCreateCurseFight(level_info: LevelInfo, enemy_spawns: Array, spawn_group: int, progress: int) -> void:
	curse_id = CURSE_IDS.pick_random()
	
	var budget: int = Game.getArea().getBudget(progress)
	var enemy_cards: Array = Game.getArea().setEnemySpawnsFromBudget(budget, enemy_spawns, progress)
	var level_data: SavedDataLevel = level_info.saved_data.new(level_info.id, true, 0, level_info.data.duplicate())
	level_data.enemy_cards = enemy_cards
	level_data.spawn_group = spawn_group
	level_data.fight_type = Game.FightTypes.COLOSSEUM
	onPushAction(AddBoonAction.new(curse_id, Game.getArea().getWorldDifficulty()))
	load_level.emit(level_data)

func onCreateMirrorFight(level_info: LevelInfo, enemy_spawns: Array, spawn_group: int, progress: int) -> void:
	var budget: int = Game.getArea().getBudget(progress)
	var cards: Array = Game.getDeckCards()
	var spawn_amount: int = Game.getArea().getSpawnAmount(budget, enemy_spawns.size())
	cards.shuffle()
	cards.resize(spawn_amount)
	cards = cards.filter(func(x: CardGD): return x != null)
	
	var enemy_cards: Array = []
	for i: int in range(cards.size()):
		var Card: CardGD = cards[i]	
		var tool_data: SavedDataTool
		if Card.getTool() != null:
			var tool_info: ToolInfo = Card.getTool().info
			var tool_tier: int = Card.getTool().getTier()
			tool_data = tool_info.saved_data.new(tool_info.id, true)
			tool_data.tier = tool_tier
		var card_data: SavedDataCard = Game.onCreateBaseCard(Card.info.id, Card.getTier(), tool_data)
		card_data.coords = enemy_spawns[i].coords
		card_data.team = 1
		enemy_cards.append(card_data)
	var level_data: SavedDataLevel = level_info.saved_data.new(level_info.id, true, 0, level_info.data.duplicate())
	level_data.enemy_cards = enemy_cards
	level_data.spawn_group = spawn_group
	level_data.fight_type = Game.FightTypes.COLOSSEUM
	load_level.emit(level_data)
