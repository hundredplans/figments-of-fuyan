extends EncounterGD

const PROGRESS_ABOVE_WHERE_CAN_SHOW_UP: int = 6
const MAX_SPAWN_AMOUNT: int = 5

func canShowUp() -> bool:
	return anyRequirementMet() and Game.area.getProgress() >= PROGRESS_ABOVE_WHERE_CAN_SHOW_UP
	
func isRequirementMet(option: EncounterOptionDatastore) -> bool:
	match option.name:
		_: pass
	return true
	
func onOptionPressed(option: EncounterOptionDatastore, screen: Control) -> void:
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
	
	var empty_spawn_coords: Array = level_info.getEmptySpawnCoords()
	var enemy_spawns: Array = []
	for i in range(cards.size()):
		var Card: CardGD = cards[i]
		var OriginalTool: ToolGD = Card.getTool()
		var tool_info: ToolInfo = OriginalTool.info if OriginalTool != null else null
		var tool_data: SavedDataTool
		if tool_info != null:
			tool_data = tool_info.saved_data.new(tool_info.id, true) if tool_info != null else null
			tool_data.ascended = OriginalTool.ascended
		
		var card_data: SavedDataCard = Game.onCreateBaseCard(Card.info.id, Card.ascended, tool_data)
		card_data.coords = empty_spawn_coords[i]
		card_data.team = 1
		enemy_spawns.append(card_data)
	
	var level_data: SavedDataLevel = level_info.saved_data.new(level_info.id, true, 0, level_info.data.duplicate(), enemy_spawns)
	load_level.emit(level_data)
