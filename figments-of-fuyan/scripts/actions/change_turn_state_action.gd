class_name ChangeTurnStateAction extends Action

var Card: CardGD
var turn_state: Game.TurnStates
var is_start_of_phase: bool
var instant: bool

func _init(_Card: CardGD = null, _turn_state := Game.TurnStates.PASSED, _is_start_of_phase: bool = false, _instant: bool = false) -> void:
	super()
	Card = _Card
	turn_state = _turn_state
	is_start_of_phase = _is_start_of_phase
	instant = _instant
	
func onCheckFail() -> void:
	if turn_state == Card.turn_state or Card.isDead():
		onFailAction()
		
func onPreAction() -> void:
	onCheckFail()
	
func onPostAction() -> void:
	if turn_state != Card.turn_state:
		Card.setTurnState(turn_state, instant)
		if turn_state == Game.TurnStates.INACTIVE:
			var actions: Array = [ChangeAttacksAction.new(Card, Card.getMaxAttacks()), StatAction.new(StatInfo.new(Card, Game.Stats.SPEED, Card.max_speed, 0, false, false, true))]
			onPushAction(actions)

func getLogInfo() -> Array:
	return ["Card: " + Card.info.name, "TurnState: " + Game.TURN_STATES_TO_STRING[turn_state],\
	"OriginalTurnState: " + Game.TURN_STATES_TO_STRING[Card.turn_state]]
