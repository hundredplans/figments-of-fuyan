class_name EndGameAction extends Action

var team: int
var ignore_check: bool
func _init(_team: int = 0, _ignore_check: bool = false) -> void:
	super()
	team = _team
	ignore_check = _ignore_check
	
func onPreAction() -> void:
	if !ignore_check and !Game.get_tree().get_nodes_in_group("FieldCardsGD")\
		.filter(func(x: CardGD): return x.team == team).is_empty():
		onFailAction()
	
func onPostAction() -> void:
	pass

func getDelay() -> float:
	return super()
