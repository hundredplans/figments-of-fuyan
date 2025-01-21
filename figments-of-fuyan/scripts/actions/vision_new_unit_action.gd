class_name VisionNewUnitAction extends Action

var Discoverer: CardGD
var Discovered: CardGD
var enter_vision: bool

func _init(_Discoverer: CardGD = null, _Discovered: CardGD = null, _enter_vision: bool = false) -> void:
	super()
	Discoverer = _Discoverer
	Discovered = _Discovered
	enter_vision = _enter_vision
	
func onPreAction() -> void:
	pass
	
func onPostAction() -> void:
	if Discoverer.isAlly(0) and owner is VisionAction and owner.owner is OccupyAction and enter_vision\
	and Discovered not in Game.get_tree().get_nodes_in_group("LevelsGD")[0].old_player_vision:
		onRemoveMoveAndAttackActions(Discoverer)

func getLogInfo() -> Array:
	return ["Discoverer: " + Discoverer.info.name, "Discovered: " + Discovered.info.name, "State: " + str(enter_vision)]
