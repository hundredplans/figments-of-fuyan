class_name VisionNewUnitAction extends Action

var Discoverer: CardGD
var Discovered: CardGD
var enter_vision: bool
var old_player_vision: Array # At the time of the action initting

func _init(_Discoverer: CardGD = null, _Discovered: CardGD = null, _enter_vision: bool = false, _old_player_vision: Array = []) -> void:
	super()
	Discoverer = _Discoverer
	Discovered = _Discovered
	enter_vision = _enter_vision
	old_player_vision = _old_player_vision
	
func onPreAction() -> void:
	pass
	
func onPostAction() -> void:
	pass

func getLogInfo() -> Array:
	return ["Discoverer: " + Discoverer.info.name, "Discovered: " + Discovered.info.name, "State: " + str(enter_vision)]
