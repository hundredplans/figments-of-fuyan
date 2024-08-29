class_name RegularLevelInfo extends LevelInfo

@export var trinket_amount: int = -1
@export var enemy_spawn_amount: int = -1
@export var ally_spawn_amount: int = -1
@export var progress_min: int
@export var progress_max: int
@export_range(0, 10000, 60) var timeout: int = 1200

func setSpawnPropertiesAutoValues(tile_objects: Array) -> void:
	if ally_spawn_amount == -1: ally_spawn_amount  = tile_objects.filter(func(x: TileObjectGD): return x.isIDVariation(2, 0)).size()
	if enemy_spawn_amount == -1: enemy_spawn_amount = tile_objects.filter(func(x: TileObjectGD): return x.isIDVariation(2, 1)).size()
	if trinket_amount == -1: trinket_amount = tile_objects.filter(func(x: TileObjectGD): return x.isIDVariation(2, 3)).size()

func setPreviousLevelInfoValues(level_info: LevelInfo) -> void:
	super(level_info)
	timeout = level_info.timeout
	ally_spawn_amount = level_info.ally_spawn_amount
	enemy_spawn_amount = level_info.enemy_spawn_amount
	trinket_amount = level_info.trinket_amount
