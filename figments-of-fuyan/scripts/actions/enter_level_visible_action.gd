class_name EnterLevelVisibleAction extends Action

var occupy_action: OccupyAction
var move_action: MoveToTileAction

const ENTER_LEVEL_VISIBLE_DELAY: float = 0.8

func _init(_occupy_action: OccupyAction) -> void:
	super()
	occupy_action = _occupy_action
	move_action = occupy_action.owner
	
func onPreAction() -> void:
	setActionDelay(move_action.getJumpDelay() + ENTER_LEVEL_VISIBLE_DELAY)
	onForceAction(CameraChangeAction.new(occupy_action.Card))
	
func onPostAction() -> void:
	occupy_action.Card.onPauseAnimationWithDelay(ENTER_LEVEL_VISIBLE_DELAY)
	occupy_action.Card.setPositionToTile(occupy_action.PreviousTile)
	await Game.get_tree().create_timer(ENTER_LEVEL_VISIBLE_DELAY).timeout
	occupy_action.Card.onMoveToTile(move_action, getDelay() - ENTER_LEVEL_VISIBLE_DELAY)
