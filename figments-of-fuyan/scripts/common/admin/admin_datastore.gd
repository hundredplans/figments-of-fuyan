class_name AdminDatastore extends Resource

@export_group("Main Menu")
@export var skip_main_menu: bool
@export var skip_start_cutscene: bool
@export_group("")

@export_group("Map")
@export var spawn_instead_of_shop_id: int
@export var force_level_spawn_id: int
@export var force_encounter_id: int
@export var skip_map_start_animation: bool
@export_group("")

@export_group("Fight")
@export var force_elite_fight_curse_id: int
@export var skip_level_start_animation: bool
@export var see: bool
@export_group("")
