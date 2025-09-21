extends DefaultButton

@onready var PassButtonLabel: Label = %PassButtonLabel
var action_lock: bool
var is_ally_spectating: bool
var is_passed_turn: bool
var is_inactive_with_another_active: bool
var is_player_phase: bool
var is_ability_mode: bool
var everyone_passed_turn: bool

func onUpdateDisabled() -> void:
	var player_phase_checks: bool = is_ally_spectating and (!is_passed_turn or everyone_passed_turn) and !is_inactive_with_another_active
	setDisabled(action_lock or (is_player_phase and !player_phase_checks) or is_ability_mode)
	onUpdateModulate()
	
func setActionLock(state: bool) -> void:
	action_lock = state
	onUpdateDisabled()
	
func setAbilityMode(state: bool) -> void:
	is_ability_mode = state
	onUpdateDisabled()

func setAllySpectating(SpectateObject: GameObjectGD) -> void:
	is_ally_spectating = SpectateObject != null and SpectateObject is CardGD and SpectateObject.isAlly(0)
	if is_ally_spectating: # Important so spawn's can't go into the Card func
		setTurnStates(SpectateObject, true)

func setTurnStates(Card: CardGD, override: bool = false) -> void:
	if is_ally_spectating and (Card == Game.getLevel().getAllySpectateObject() or override):
		is_passed_turn = Card.turn_state == Game.TurnStates.PASSED
		is_inactive_with_another_active = Card.turn_state == Game.TurnStates.INACTIVE and\
			Game.getAllyUnits().any(func(x: CardGD): return x != Card and x.turn_state == Game.TurnStates.ACTIVE)
		everyone_passed_turn = Game.getAllyUnits().all(func(x: CardGD): return x.turn_state == Game.TurnStates.PASSED)
	onUpdateDisabled()
	
func setEveryonePassedTurn() -> void:
	everyone_passed_turn = Game.getAllyUnits().all(func(x: CardGD): return x.turn_state == Game.TurnStates.PASSED)
	onUpdateDisabled()

func setPhase(phase: Game.Phases) -> void:
	is_player_phase = phase == Game.Phases.PLAYER
	onUpdateDisabled()

var RotTween: Tween
var LabelScaleTween: Tween
const SIDE_TILT: float = PI / 8.0
const TILT_TIME: float = 0.15
const MAX_SCALE: float = 1.1

func _on_pressed() -> void:
	pivot_offset = size / 2.0
	
	if RotTween: RotTween.kill()
	RotTween = create_tween()
	
	var RotTween := create_tween()
	RotTween.tween_property(PassButtonLabel, "rotation", SIDE_TILT, TILT_TIME)\
		.as_relative().set_trans(Tween.TRANS_SINE)
	RotTween.tween_property(PassButtonLabel, "rotation", -SIDE_TILT * 2, TILT_TIME * 2)
	RotTween.tween_property(PassButtonLabel, "rotation", SIDE_TILT, TILT_TIME)
	
	if LabelScaleTween: LabelScaleTween.kill()
	LabelScaleTween = create_tween()
	var new_scale: float = MAX_SCALE - scale.x
	
	LabelScaleTween.tween_property(PassButtonLabel, "scale", Vector2(new_scale, new_scale), TILT_TIME * 2)\
		.as_relative().set_trans(Tween.TRANS_SINE)
	LabelScaleTween.tween_property(PassButtonLabel, "scale", Vector2(-0.1, -0.1), TILT_TIME * 2)\
		.as_relative().set_trans(Tween.TRANS_SINE)
