class_name EnterLevelVisibleAction extends Action

var occupy_action: OccupyAction
var move_action: MoveToTileAction

func _init(_occupy_action: OccupyAction) -> void:
	super()
	occupy_action = _occupy_action
	move_action = occupy_action.owner
	
func onPreAction() -> void:
	setActionDelay(move_action.getJumpDelay())
	onForceAction(CameraChangeAction.new(occupy_action.Card))
	
func onPostAction() -> void:
	print(occupy_action.Card.position)
	occupy_action.Card.setPositionToTile(occupy_action.PreviousTile)
	print(occupy_action.Card.position)
	occupy_action.Card.onMoveToTile(move_action, getDelay())
	print(occupy_action.Card.position)
	await Game.get_tree().process_frame
	print(occupy_action.Card.position)
	print()
