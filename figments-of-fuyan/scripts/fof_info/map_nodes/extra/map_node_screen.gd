class_name MapNodeScreen extends Control

@warning_ignore("Unused_signal")
signal finished

var World: Node3D
var UI: Control
var save_file: SaveFileGD

func setInfo(_save_file: SaveFileGD, _area: AreaGD, _World: Node3D, _UI: Control, _map_node: MapNodeGD) -> void:
	World = _World
	UI = _UI
	save_file = _save_file

func onDimBackground() -> bool:
	return false
