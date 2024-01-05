extends Control

signal equip_sky
signal load_world
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
	$SeedLabel.text = str(GameState.gseed)
	$ShillingCounter.set_shilling_count(GameState.shillings)
	
	if !Helper.settings_loaded:
		GeneralMap = _GeneralMap.instantiate()
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
	
func _queue_free() -> void: 
	if GameState.level_info.id == 0 and !Helper.settings_loaded:
		GameState._queue_free()
		load_world.emit(null)

func on_node_selected(id: int, index: int) -> void: # here in case i need more stuff here
	GeneralMap.on_node_selected(id, index)
	$NodeSelect.visible = false

func on_node_hovered(state: bool, id: int) -> void:
	GeneralMap.on_node_hovered(state, id)
