class_name DiscoverAction extends Action

var Card: CardGD
var Discoverer: GameObjectGD
var state: bool

func _init(_Card: CardGD = null, _Discoverer: GameObjectGD = null, _state: bool = false) -> void:
	super()
	Card = _Card
	Discoverer = _Discoverer
	state = _state

func onPostAction() -> void:
	if Discoverer != null and Discoverer.isAlly(0) and state: onRemoveAction(filterMethod)

func filterMethod(action: Action) -> bool:
	var move_predicate: bool = action is MoveToTileAction and action.Card == Discoverer
	var attack_predicate: bool = action is AttackAction and action.Attacker == Discoverer
	return !(move_predicate or attack_predicate)
