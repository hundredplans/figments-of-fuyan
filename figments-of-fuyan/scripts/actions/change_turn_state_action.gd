class_name ChangeTurnStateAction extends Action

var Card: CardGD
var turn_state: Game.TurnStates

func _init(_Card: CardGD = null, _turn_state := Game.TurnStates.PASSED) -> void:
	Card = _Card
	turn_state = _turn_state
	
func onPostAction() -> void:
	Card.setTurnState(turn_state)

func getLogInfo() -> Array:
	return ["Card: " + Card.info.name, "TurnState: " + Game.TURN_STATES_TO_STRING[turn_state],\
	"OriginalTurnState: " + Game.TURN_STATES_TO_STRING[Card.turn_state]]
