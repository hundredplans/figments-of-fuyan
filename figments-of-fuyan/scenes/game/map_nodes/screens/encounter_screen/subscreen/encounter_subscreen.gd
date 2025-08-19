class_name EncounterSubscreen extends Control

signal create_stash_screen

var map_node: MapNodeGD
func setInfo(_map_node: MapNodeGD) -> void: map_node = _map_node
func getMinimapFadeNodes() -> Array: return []
func getStashFadeNodes() -> Array: return []
func getFadeBackgroundColor() -> Color: return map_node.getEncounterDatastore().getBackgroundMainColor()
func onStashScreenExitStart() -> void: pass
func onFinished() -> void: pass
