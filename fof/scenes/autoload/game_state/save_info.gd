class_name SaveInfoGD
extends Resource

@export var id: int

@export var map_info: Dictionary
@export var area_info: AreaInfoGD
@export var level_info: LevelInfoGD

@export var map_progress: Vector2
@export var shillings: int

@export var hero_level: int
@export var hero_id: int
@export var gseed: int

@export var deck: Array
@export var boons: Array

func _init(_id: int = 0, _hero_id: int = 0, _gseed: int = 0) -> void:
	id = _id
	hero_id = _hero_id
	gseed = _gseed

func getLevelID() -> int:
	return level_info.id if level_info != null else 0
