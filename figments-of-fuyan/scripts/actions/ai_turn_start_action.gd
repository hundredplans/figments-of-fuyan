class_name AITurnStartAction extends Action

var team: int

func _init(_team: int = 0) -> void:
	super()
	team = _team
	
func onPostAction() -> void:
	var Card: CardGD = Game.getNextInactiveCard(team)
	onAppendAction(AITurnAction.new(Card, true) if Card != null else ChangePhaseAction.new(Game.Phases.NEUTRAL if team == 1 else Game.Phases.HAND))
