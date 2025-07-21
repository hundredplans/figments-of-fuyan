extends EncounterGD	

func canShowUp() -> bool:
	return true
	
func isRequirementMet(option: EncounterOptionDatastore) -> bool:
	match option.name:
		_: pass
	return true
	
func onOptionPressed(option: EncounterOptionDatastore, _screen: Control) -> void:
	match option.name:
		"Fight": onStartFight(); return
	onContinueToNextPage(option)

func onStartFight() -> void:
	var progress: int = Game.area.getProgress()
	var level_infos: Array = Helper.getFofInfoArray(LevelInfo)\
		.filter(func(x: LevelInfo): return progress >= x.progress_min and progress <= x.progress_max)
	var level_info: LevelInfo = level_infos.pick_random()
	
	var spawn_group: int = level_info.getRandomSpawnGroup()
	var enemy_spawns: Array = level_info.getEnemySpawnsInGroup(spawn_group) # Array[SavedDataSpawn]
	enemy_spawns.shuffle()
	
	var budget: int = Game.area.getBudget(progress, level_info.enemy_budget_offset)
	var enemy_cards: Array = Game.area.setEnemySpawnsFromBudget(budget, level_info.enemy_min_spawn_amount, level_info.enemy_max_spawn_amount, enemy_spawns, progress, false)
	
	var level_data: SavedDataLevel = level_info.saved_data.new(level_info.id, true, 0, level_info.data.duplicate())
	
	level_data.enemy_cards = enemy_cards
	level_data.level_preview = Game.getArea().getLevelPreview(enemy_cards)
	level_data.spawn_group = spawn_group
	
	load_level.emit(level_data)
