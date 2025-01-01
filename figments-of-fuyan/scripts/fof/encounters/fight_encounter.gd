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
	
	var empty_spawn_coords: Array = level_info.getEmptySpawnCoords()
	empty_spawn_coords.shuffle()
	
	var enemy_spawn_amount: int = min(randi_range(level_info.enemy_min_spawn_amount, level_info.enemy_max_spawn_amount), empty_spawn_coords.size() - 1)
	var budget: int = Game.area.getBudget(progress, level_info.enemy_budget_offset, Game.isDivinus() and !Game.area.active_map_node_data.isHoly())
	var enemy_spawns: Array = Game.area.setEnemySpawnsFromBudget(budget, enemy_spawn_amount, empty_spawn_coords, progress, false)
	
	var level_data: SavedDataLevel = level_info.saved_data.new(level_info.id, true, 0, level_info.data.duplicate(), enemy_spawns)
	load_level.emit(level_data)
