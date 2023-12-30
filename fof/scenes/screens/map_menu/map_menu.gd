extends Control

signal equip_sky
signal load_world
var GameState: Node

func _ready() -> void:
	$SeedLabel.text = str(GameState.gseed)
	$ShillingCounter.set_shilling_count(GameState.shillings)
	
	if !Helper.settings_loaded:
		load_world.emit(load("res://assets/base_game/areas/" + GameState.area_info.bgfn + "/area_map.tscn").instantiate())
		equip_sky.emit(GameState.area_info.id, false)
	
func _queue_free() -> void: 
	if GameState.level_info.id == 0 and !Helper.settings_loaded:
		GameState._queue_free()
		load_world.emit(null)
