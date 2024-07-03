class_name SaveInfoGD
extends Resource

var id: int
var area_id: int
var map_id: int
var level_id: int # null if 0
var map_progress: Vector2
var shillings: int
var hero_level: int
var hero_id: int
var gseed: int
var player_deck: Array

func _init(_id: int = 0, _area_id: int = 0, _map_id: int = 0, _level_id: int = 0, _map_progress := Vector2.ZERO, \
_shillings: int = 0, _hero_level: int = 0, _hero_id: int = 0, _gseed: int = 0, _player_deck: Array = []):
	id = _id
	area_id = _area_id
	map_id = _map_id
	level_id = _level_id
	map_progress = _map_progress
	shillings = _shillings
	hero_level = _hero_level
	hero_id = _hero_id
	gseed = _gseed
	player_deck = _player_deck

