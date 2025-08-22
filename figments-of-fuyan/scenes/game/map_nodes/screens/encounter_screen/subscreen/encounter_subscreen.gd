class_name EncounterSubscreen extends Control

signal create_stash_screen

var in_stash_screen: bool
var map_node: MapNodeGD
func setInfo(_map_node: MapNodeGD) -> void: map_node = _map_node
func getMinimapFadeNodes() -> Array: return []
func getStashFadeNodes() -> Array: return []
func getFadeBackgroundColor() -> Color: return map_node.getEncounterDatastore().getBackgroundMainColor()
func onStashScreenStart() -> void: in_stash_screen = true
func onStashScreenExitStart() -> void: in_stash_screen = false
func onFinished() -> void: pass
