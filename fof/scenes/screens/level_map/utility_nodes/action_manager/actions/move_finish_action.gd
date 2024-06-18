class_name MoveFinishActionGD
extends ActionGD

const type: int = ActionManagerGD.MOVE_FINISH
var movement_path: MovementPathGD

func _init(_Unit: UnitGD = null, _movement_path: MovementPathGD = null, _is_visible: bool = true, _delay := DelayGD.new()) -> void:
	Unit = _Unit
	delay = _delay
	is_visible = _is_visible
	movement_path = _movement_path
	super()

func onTrigger() -> void:
	onResumeIdleAnimation()
	onCreateIncentiviseAction()
	Units.onRemoveMovementOutlineTiles()
	
	if Unit.team == 1 and !Unit.is_dead: Units.setUnitStatus(Unit, UnitGD.TURN_USED)
	
func onCreateIncentiviseAction() -> void:
	if Unit.team == 0 and LevelMap.game_phase == "PlayerPhase":
		LevelUI.onIncentivisePassTurn(Unit)

func onResumeIdleAnimation() -> void:
	Unit.Model.on_play_animation("Idle")
	if Unit.Model.current_walk_stream_player != null:
		AudioMaster.on_cutoff_sfx(Unit.Model.current_walk_stream_player)

func onAfterTrigger() -> void:
	if Unit.team == 1:
		AIManager.onMoveNextAIUnit()
