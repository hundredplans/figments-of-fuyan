class_name AITurnStartAction extends Action

var team: int
var Card: CardGD
const START_AI_TURN_DELAY: float = 0.5

func _init(_team: int = 0) -> void:
	super()
	team = _team
	
func onPostAction() -> void:
	onAppendAction(AITurnAction.new(Card, true) if Card != null else ChangePhaseAction.new(Game.Phases.NEUTRAL if team == 1 else Game.Phases.HAND))

func onPreAction() -> void:
	Card = Game.getNextInactiveCard(team)
	var level_visible: bool = Card != null and Card.isLevelVisible()
	if !level_visible: return
	
	onForceAction(CameraChangeAction.new(Card))
	setActionDelay(START_AI_TURN_DELAY)
