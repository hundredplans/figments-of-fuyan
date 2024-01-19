class_name GameStateGD
extends Node

var player_deck: Array = []
var player_boons: Array = []

var admin: bool = true
var save_file: int = 0
var area_info: Dictionary
var map_info: Dictionary
var level_info: Dictionary = {"id": 0}
var map_progress := Vector2(1, 10)
var shillings: int = 0
var hero_level: int = 0
var hero_id: int = 0
var gseed: int = 0

var history: Array = []

func on_set_info(info: Dictionary) -> void:
	save_file = info.save_file
	area_info = Helper.id_to_dict(info.area_id, "Area")
	map_info = Helper.id_to_dict(info.map_id, "Map")
	level_info = {"id": 0} if info.level_id == 0 else Helper.id_to_dict(info.level_id, "Level")
	map_progress = Vector2(info.map_progress[0], info.map_progress[1])
	shillings = info.shillings
	hero_level = info.hero_level
	hero_id = info.hero_id
	gseed = info.gseed
	player_deck = info.player_deck
	
func _queue_free() -> void:
	on_save_game_state()
	queue_free()
	
func on_create_new_save_file() -> void:
	for i in range(1, 6):
		if !FileAccess.file_exists("user://save/save_files/" + str(i) + ".txt"):
			save_file = i
			on_save_game_state()
			break
	
func on_save_game_state() -> void:
	var contents: String = ""
	var array_contents: Array = [
		save_file,
		area_info.id,
		map_info.id,
		level_info.id,
		[map_progress.x, map_progress.y],
		shillings, 
		hero_level, 
		hero_id,
		gseed,
		history,
		player_deck,
		]
		
	for i in range(array_contents.size()):
		contents += str(array_contents[i]) + ("\n" if i != array_contents.size() - 1 else "")
	
	Helper.write_to_file("user://save/save_files/", str(save_file), ".txt", contents, false)

func on_load_new_area(world: int) -> void:
	var areas: Array = Helper.on_item_dicts("Area").filter(func(x: Dictionary): return x.world == world)
	area_info = areas[0] # this is supposed to be randomised but will pick palms for now
	on_load_new_map()
	
func on_load_new_map() -> void:
	var maps: Array = Helper.on_item_dicts("Map").filter(func(x: Dictionary): return x.world == area_info.world)
	map_info = maps[randi() % maps.size()]

func on_add_card_to_player_deck(id: int, tool_id: int = 0, effects: Array = []) -> void:
	player_deck.append({"id": id, "tool_id": tool_id, "effects": effects})
