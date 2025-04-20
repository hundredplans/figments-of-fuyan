extends EncounterGD

const PROGRESS_ABOVE_WHERE_CAN_SHOW_UP: int = 6
const MAX_SPAWN_AMOUNT: int = 5

func canShowUp() -> bool:
	return anyRequirementMet() and Game.area.getProgress() >= PROGRESS_ABOVE_WHERE_CAN_SHOW_UP
	
func isRequirementMet(option: EncounterOptionDatastore) -> bool:
	match option.name:
		_: pass
	return true
	
func onOptionPressed(option: EncounterOptionDatastore, _screen: Control) -> void:
	match option.name:
		"Fight":
			onStartFight()
			return
			
	onContinueToNextPage(option)

func onStartFight() -> void:
	var progress: int = Game.area.getProgress()
	var level_infos: Array = Helper.getFofInfoArray(LevelInfo)\
		.filter(func(x: LevelInfo): return progress >= x.progress_min and progress <= x.progress_max)
	var level_info: LevelInfo = level_infos.pick_random()
	var spawn_amount: int = min(level_info.enemy_max_spawn_amount, MAX_SPAWN_AMOUNT)
	var cards: Array = []
	cards = get_tree().get_nodes_in_group("DeckCardsGD")
	cards.shuffle()
	cards.resize(spawn_amount)
	cards = cards.filter(func(x: CardGD): return x != null)
	
	var spawn_group: String = level_info.getRandomSpawnGroup()
	var enemy_spawns: Array = level_info.getEnemySpawnsInGroup(spawn_group) # Array[SavedDataSpawn]
	var enemy_cards: Array = []
	
	enemy_spawns.shuffle()
	
	for i in range(cards.size()):
		var Card: CardGD = cards[i]
		var base_stats: StatsDatastore = Card.base_stats
		var OriginalTool: ToolGD = Card.getTool()
		var tool_info: ToolInfo = OriginalTool.info if OriginalTool != null else null
		var tool_data: SavedDataTool
		if tool_info != null:
			tool_data = tool_info.saved_data.new(tool_info.id, true) if tool_info != null else null
			tool_data.ascended = OriginalTool.ascended
		
		var card_data: SavedDataCard = Game.onCreateBaseCard(Card.info.id, Card.ascended, tool_data)
		card_data.setBaseStats(base_stats.duplicate())
		
		card_data.coords = enemy_spawns[i].coords
		card_data.team = 1
		enemy_cards.append(card_data)
	
	var level_data: SavedDataLevel = level_info.saved_data.new(level_info.id, true, 0, level_info.data.duplicate())
	level_data.spawn_group = spawn_group
	level_data.enemy_cards = enemy_cards
	
	var valid_infos: Dictionary[SavedDataCard, CardInfo] = {}
	for saved_data_card: SavedDataCard in enemy_cards:
		valid_infos[saved_data_card] = Helper.getFofInfoID(CardInfo, saved_data_card.id)
		
	level_data.level_rewards = Game.getArea().getLevelRewards(enemy_cards\
		.filter(func(x: SavedDataCard): return valid_infos[x].rarity != Game.Rarities.CHAMPION))
	
	load_level.emit(level_data)
