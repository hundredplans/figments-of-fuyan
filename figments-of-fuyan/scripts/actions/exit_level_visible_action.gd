class_name ExitLevelVisibleAction extends Action

const EXIT_LEVEL_VISIBLE_ACTION_DELAY: float = 0.5

var cards: Array
func _init(_cards: Array = []) -> void:
	super()
	cards = _cards
	
func onPreAction() -> void:
	setActionDelay(0.5)
	
func onPostAction() -> void:
	for Card in cards: Card.onPauseAnimationWithDelay(action_delay)
		
