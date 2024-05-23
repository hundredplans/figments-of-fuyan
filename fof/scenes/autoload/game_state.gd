class_name GameStateGD
extends Node

var player_deck: Array = [
		{"id": 7,
	"tool_id": 0,
	"effects": []
	},
		{"id": 8,
	"tool_id": 0,
	"effects": []
	},
		{"id": 9,
	"tool_id": 0,
	"effects": []
	},
		{"id": 10,
	"tool_id": 0,
	"effects": []
	},
		{"id": 11,
	"tool_id": 0,
	"effects": []
	},
		{"id": 12,
	"tool_id": 0,
	"effects": []
	},
		{"id": 13,
	"tool_id": 0,
	"effects": []
	},
		{"id": 14,
	"tool_id": 0,
	"effects": []
	},
		{"id": 15,
	"tool_id": 0,
	"effects": []
	},
	
		{"id": 16,
	"tool_id": 0,
	"effects": []
	},
	
		{"id": 17,
	"tool_id": 0,
	"effects": []
	},
	
		{"id": 18,
	"tool_id": 0,
	"effects": []
	},
		{"id": 24,
	"tool_id": 0,
	"effects": []
	},
		{"id": 19,
	"tool_id": 0,
	"effects": []
	},
		{"id": 20,
	"tool_id": 0,
	"effects": []
	},
	
		{"id": 21,
	"tool_id": 0,
	"effects": []
	},
	
		{"id": 22,
	"tool_id": 0,
	"effects": []
	},
]

var player_boons: Array = []
var admin: bool = true
var save_file: int = -1
var area_info: AreaInfoGD
var map_info: Dictionary
var level_info: LevelInfoGD
var map_progress := Vector2(1, 10)
var shillings: int = 0
var hero_level: int = 0
var hero_id: int = 0
var gseed: int = 0

func on_set_info(info: Dictionary) -> void:
	save_file = info.save_file
	area_info = Helper.getFofInfo(info.area_id, "area")
	map_info = Helper.id_to_dict(info.map_id, "Map")
	level_info =  null if info.level_id == 0 else Helper.getFofInfo(info.level_id, "level")
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
	if save_file != -1:
		var contents: String = ""
		var array_contents: Array = [
			save_file,
			area_info.id,
			map_info.id,
			level_info.id if level_info != null else 0,
			[map_progress.x, map_progress.y],
			shillings, 
			hero_level, 
			hero_id,
			gseed,
			player_deck,
			]
			
		for i in range(array_contents.size()):
			contents += str(array_contents[i]) + ("\n" if i != array_contents.size() - 1 else "")
		
		Helper.write_to_file("user://save/save_files/", str(save_file), ".txt", contents, false)

func on_load_new_area(_world: int) -> void:
	var areas: Array = [Helper.getFofInfo(1, "area")]
	area_info = areas[0] # this is supposed to be randomised but will pick palms for now
	on_load_new_map()
	
func on_load_new_map() -> void:
	var maps: Array = Helper.on_item_dicts("Map").filter(func(x: Dictionary): return x.world == area_info.world_id)
	map_info = maps[randi() % maps.size()]

func on_add_card_to_player_deck(id: int, tool_id: int = 0, effects: Array = []) -> void:
	player_deck.append({"id": id, "tool_id": tool_id, "effects": effects})
