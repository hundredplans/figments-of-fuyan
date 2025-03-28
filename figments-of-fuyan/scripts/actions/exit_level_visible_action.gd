class_name ExitLevelVisibleAction extends Action

const EXIT_LEVEL_VISIBLE_ACTION_DELAY: float = 0.8

var cards: Array
var ignore_delay: bool

func _init(_cards: Array = [], _ignore_delay: bool = false) -> void:
	super()
	cards = _cards
	ignore_delay = _ignore_delay
	
func onPreAction() -> void:
	if (owner is VisionAction and owner.owner != null and owner.owner is OccupyAction and\
	owner.owner.owner != null and owner.owner.owner is MoveToTileAction\
	and owner.owner.owner.Card == owner.ExplorerCard and owner.owner.owner.Card not in cards):
		onFailAction()
	elif !ignore_delay:
		setActionDelay(EXIT_LEVEL_VISIBLE_ACTION_DELAY)
	
func onPostAction() -> void:
	if getDelay() > 0:
		for Card: CardGD in cards:
			Card.onPauseAnimationWithDelay(action_delay)
		
