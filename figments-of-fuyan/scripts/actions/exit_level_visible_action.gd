class_name ExitLevelVisibleAction extends Action

const EXIT_LEVEL_VISIBLE_ACTION_DELAY: float = 0.8

var cards: Array

func _init(_cards: Array = []) -> void:
	super()
	cards = _cards
	
func onPreAction() -> void:
	if owner is VisionAction and owner.owner != null and owner.owner is OccupyAction and\
	owner.owner.owner != null and owner.owner.owner is MoveToTileAction\
	and owner.owner.owner.Card.isAlly(0) and owner.owner.owner.Card == owner.ExplorerCard:
		onFailAction()
	else:
		setActionDelay(EXIT_LEVEL_VISIBLE_ACTION_DELAY)
	
func onPostAction() -> void:
	for Card in cards: Card.onPauseAnimationWithDelay(action_delay)
		
