class_name RegularLevelInfo extends LevelInfo

@export var trinket_amount: int 
@export var enemy_spawn_amount: int
@export var enemy_max_spawn_amount: int
@export var ally_spawn_amount: int
@export var progress_min: int
@export var progress_max: int
@export_range(0, 10000, 60) var timeout: int = 1200

func setSpawnPropertiesAutoValues(tile_objects: Array) -> void:
	ally_spawn_amount  = tile_objects.filter(func(x: TileObjectGD): return x.isIDVariation(2, 0)).size()
	enemy_spawn_amount = tile_objects.filter(func(x: TileObjectGD): return x.isIDVariation(2, 1)).size()
	enemy_max_spawn_amount = enemy_spawn_amount
	trinket_amount = tile_objects.filter(func(x: TileObjectGD): return x.isIDVariation(2, 3)).size()
