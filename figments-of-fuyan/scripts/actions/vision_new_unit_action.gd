class_name VisionNewUnitAction extends Action

var Discoverer: CardGD
var Discovered: CardGD
var enter_vision: bool
var old_team_vision: Array

func _init(_Discoverer: CardGD = null, _Discovered: CardGD = null, _enter_vision: bool = false, _old_team_vision: Array = []) -> void:
	super()
	Discoverer = _Discoverer
	Discovered = _Discovered
	enter_vision = _enter_vision
	old_team_vision = _old_team_vision
	
func onPreAction() -> void:
	pass
	
func onPostAction() -> void:
	if Discoverer.isAlly(0) and owner is VisionAction and owner.owner is OccupyAction and enter_vision and Discovered not in old_team_vision:
		onRemoveMoveAndAttackActions(Discoverer)

func getDelay() -> float:
	return super()

func getLogInfo() -> Array:
	return ["Discoverer: " + Discoverer.info.name, "Discovered: " + Discovered.info.name, "State: " + str(enter_vision)]
