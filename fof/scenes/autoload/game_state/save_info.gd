class_name SaveInfoGD
extends Resource

var id: int

var map_info: Dictionary
var area_info: AreaInfoGD
var level_info: LevelInfoGD

var map_progress: Vector2
var shillings: int

var hero_level: int
var hero_id: int
var gseed: int

var deck: Array
var boons: Array

func _init(_id: int = 0, _area_info: AreaInfoGD = null, _map_info: Dictionary = {}, _level_info: LevelInfoGD = null,
 _map_progress := Vector2.ZERO, _shillings: int = 0, _hero_level: int = 0, _hero_id: int = 0, _gseed: int = 0,\
 _deck: Array = [], _boons: Array = []):
	id = _id
	area_info = _area_info
	map_info = _map_info
	level_info = _level_info
	map_progress = _map_progress
	shillings = _shillings
	hero_level = _hero_level
	hero_id = _hero_id
	gseed = _gseed
	deck = _deck
	boons = _boons
