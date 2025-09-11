class_name MapNodeScreen extends Control

@warning_ignore("Unused_signal")

signal create_stash_screen
signal minimap_mode
signal finished
signal fade_loaded # Only triggers when u walk manually, used for camera reset
signal fade_background_black

var World: Node3D
var map_node: MapNodeGD
var UI: Control
var save_file: SaveFileGD

func setInfo(_save_file: SaveFileGD, _area: AreaGD, _World: Node3D, _UI: Control, _map_node: MapNodeGD) -> void:
	World = _World
	UI = _UI
	save_file = _save_file
	map_node = _map_node

func onFadeBackground() -> bool: return false
func onStashScreenStart() -> void: pass
func onStashScreenExitStart() -> void: pass
func onActiveToolAdded(_CardUI: TbcUI) -> void: pass
