extends Control

signal equip_sky
signal load_world
var GameState: Node

var GeneralMap: Node3D
var _GeneralMap: PackedScene = preload("res://assets/env/area_map/general_map.tscn")
func _ready() -> void:
	$SeedLabel.text = str(GameState.gseed)
	$ShillingCounter.set_shilling_count(GameState.shillings)
	
	if !Helper.settings_loaded:
		GeneralMap = _GeneralMap.instantiate()
		GeneralMap.GameState = GameState
		load_world.emit(GeneralMap)
		equip_sky.emit(GameState.area_info.id, false)
	
	if !GameState.map_progress == Vector2(1, GameState.map_info.map_size):
		for i in $NodeSelect.get_children():
			for arrow in GameState.map_info.arrows:
				if (GameState.map_progress == Vector2(arrow[0][0], arrow[0][1])\
				and Vector2(i.get_index(), GameState.map_progress.y - 1) == Vector2(arrow[1][0], arrow[1][1])):
					on_connect_node(i)
					break
	else:
		for node_info in GameState.map_info.nodes:
			if node_info[2] == GameState.map_info.map_size - 1:
				on_connect_node($NodeSelect.get_child(node_info[1]))
			
func on_connect_node(i: Control) -> void:
	i.pressed.connect(on_node_selected)
	i.node_hovered.connect(on_node_hovered)
	
func _queue_free() -> void: 
	if GameState.level_info.id == 0 and !Helper.settings_loaded:
		GameState._queue_free()
		load_world.emit(null)

func on_node_selected(i: int) -> void: # here in case i need more stuff here
	GeneralMap.on_node_selected(i)
	$NodeSelect.visible = false

func on_node_hovered(state: bool, i: int) -> void:
	GeneralMap.on_node_hovered(state, i)
