class_name EncounterSubscreen extends Control

signal mouse_in_ui
signal create_stash_screen
signal fade_background_black

var in_stash_screen: bool
var map_node: MapNodeGD
func setInfo(_map_node: MapNodeGD) -> void: map_node = _map_node
func getMinimapFadeNodes() -> Array: return []
func getStashFadeNodes() -> Array: return []
func getFadeBackgroundColor() -> Color: return map_node.getEncounterDatastore().getBackgroundMainColor()
func onStashScreenStart() -> void: in_stash_screen = true
func onStashScreenExitStart() -> void: in_stash_screen = false
func onFinished() -> void: pass
func onFadeBackgroundBlack() -> void: fade_background_black.emit()
