extends Control

signal screen_change_sig
signal load_world
signal equip_sky

var GameState: Node

var GeneralMap: Node3D
var _GeneralMap: PackedScene = preload("res://assets/env/area_map/general_map.tscn")

const NodeSelectVariations: Array = [
	[873],
	[600, 1000],
	[465, 873, 1275]
]

var _NodeSelectorBox: PackedScene = preload("res://scenes/screens/map_menu/node_select_box.tscn")
func _ready() -> void:
	$MiniMap.on_load_minimap(GameState)
	$SeedLabel.text = str(GameState.gseed)
	$ShillingCounter.set_shilling_count(GameState.shillings)
	
	if !Helper.settings_loaded:
		GeneralMap = _GeneralMap.instantiate()
		GeneralMap.champion_arrived.connect(on_champion_arrived)
		GeneralMap.GameState = GameState
		load_world.emit(GeneralMap)
		equip_sky.emit(GameState.area_info.id, false)
	else: GeneralMap = get_tree().get_root().get_node("Main/World/Scene").get_child(0)
		
	for i in range(GeneralMap.node_amount):
		var NodeSelectorBox: Control = _NodeSelectorBox.instantiate()
		NodeSelectorBox.position.x = NodeSelectVariations[GeneralMap.node_amount - 1][i]
		NodeSelectorBox.id = GeneralMap.row_nodes[i][1]
		on_connect_node(NodeSelectorBox)
		$NodeSelect.add_child(NodeSelectorBox)
			
func on_connect_node(NodeSelector: Control) -> void:
	NodeSelector.pressed.connect(on_node_selected)
	NodeSelector.node_hovered.connect(on_node_hovered)
	
func _queue_free(screen_name: String) -> void: 
	if !Helper.settings_loaded and screen_name not in ["LevelUI"]:
		GameState._queue_free()
		load_world.emit(null)

func on_node_selected(id: int, index: int) -> void: # here in case i need more stuff here
	GeneralMap.on_node_selected(id, index)
	$NodeSelect.visible = false
	
func on_node_hovered(state: bool, id: int) -> void:
	GeneralMap.on_node_hovered(state, id)

const INDEX_TO_SCREEN: Dictionary = {
	1: "res://scenes/screens/level_ui/level_ui.tscn"
}

func on_champion_arrived(index: int) -> void:
	if index == 1:
		#var levels: Array = Helper.on_item_dicts("Level").filter(on_is_level_valid)
		#GameState.level_info = levels[randi() % levels.size()]
			GameState.level_info = Helper.getFofInfo(3, "level")
	screen_change_sig.emit(INDEX_TO_SCREEN[index])

func on_is_level_valid(level_info: Dictionary) -> bool:
	return level_info.area == GameState.area_info.id and level_info.difficulty == abs(GameState.map_progress.y - GameState.map_info.map_size)
