class_name GameStateGD
extends Node

var admin: bool = true
var save_info: SaveInfoGD
	
func _queue_free() -> void:
	onSave()
	queue_free()
	
func onCreateSaveInfo(hid: int, gseed: int) -> void:
	for i in range(1, 6):
		if !FileAccess.file_exists("user://save/save_files/" + str(i) + ".tres"):
			save_info = SaveInfoGD.new(i, hid, gseed)
			save_info.resource_path = "user://save/save_files/" + str(i) + ".tres"
			onSave()
			onCreateArea()
			break
	
func onSave() -> void:
	if save_info != null: ResourceSaver.save(save_info)
		
func onCreateArea() -> void:
	var areas: Array = [Helper.getFofInfo(1, "area")]
	save_info.area_info = areas[0] # this is supposed to be randomised but will pick palms for now
	onCreateMap()
	onAdminLoadCards()
	
func onAdminLoadCards() -> void:
	save_info.deck.append({"id": 1, "tool_id": 0, "effects": []})
	for i in range(6):
		var random_unit_id: int = randi_range(7, 24)
		save_info.deck.append({"id": random_unit_id, "tool_id": 0, "effects": []})
	
func onCreateMap() -> void:
	var maps: Array = Helper.on_item_dicts("Map").filter(func(x: Dictionary): return x.world == save_info.area_info.world_id)
	save_info.map_progress = Vector2(1, 10)
	save_info.map_info = maps[randi() % maps.size()]

func on_add_card_to_player_deck(id: int, tool_id: int = 0, effects: Array = []) -> void:
	save_info.deck.append({"id": id, "tool_id": tool_id, "effects": effects})
