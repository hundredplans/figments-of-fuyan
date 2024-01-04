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
	
	for i in $NodeSelect.get_children():
		i.pressed.connect(on_node_selected)
	
func _queue_free() -> void: 
	if GameState.level_info.id == 0 and !Helper.settings_loaded:
		GameState._queue_free()
		load_world.emit(null)

func on_node_selected(i: int) -> void: # here in case i need more stuff here
	GeneralMap.on_node_selected(i)
	$NodeSelect.visible = false
