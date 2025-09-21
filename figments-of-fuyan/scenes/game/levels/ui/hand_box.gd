extends HBoxContainer

@export var AniPlayer: AnimationPlayer
@export var DrawManager: Control
@export var HandCardUIPacked: PackedScene

const BOTTOM_SCREEN_OFFSET: int = 5
signal mouse_in_ui

const TWEEN_UP_POSITION: int = 670
const TWEEN_DOWN_POSITION: int = 1000
const TWEEN_SPEED: float = 0.25

const DRAW_CARD_FLY_TO_HAND_TIME: float = 0.5
const SHIFT_HANDS_TIME: float = 0.5

var selectable_cards: bool
var pinned: bool = true
var is_down: bool

var is_mouse_in_ui: bool

var energy: int
var phase: Game.Phases

var is_player_phase_no_action: bool

var MainTween: Tween

var CARD_AMOUNT_TO_ROTATION: Dictionary[int, Array] = {
	0: [],
	1: [0],
	2: [-5, 5],
	3: [-5, 0, 5],
	4: [-7.5, -2.5, 2.5, 7.5],
	5: [-10, -5, 0, 5, 10]
}

func onMouseInUI(state: bool) -> void:
	if get_viewport().get_mouse_position().y >= get_viewport().size.y - BOTTOM_SCREEN_OFFSET: return
	is_mouse_in_ui = state
	mouse_in_ui.emit(state)
	
func onUpdatePin(instant: bool = false) -> void:
	var _pinned: bool = isValidPin()
	if _pinned == pinned: return
	pinned = _pinned
	
	onStartTween(instant)

func onStartTween(instant: bool = false) -> void:
	var _is_down: bool = isValidDown()
	if is_down == _is_down: return
	is_down = _is_down
	
	if MainTween: MainTween.kill()
	MainTween = create_tween()
	
	var offset: float = (TWEEN_DOWN_POSITION if is_down else TWEEN_UP_POSITION) - position.y
	MainTween.tween_property(self, "position:y", offset, TWEEN_SPEED)\
		.as_relative().set_trans(Tween.TRANS_SINE)

func setPhase(_phase: Game.Phases, instant: bool) -> void:
	phase = _phase
	onUpdatePin(instant)
	onUpdateSelectableCards()

func onUpdateSelectableCards() -> void:
	selectable_cards = isValidSelectableCards()
	for HandCardUI: Control in get_children():
		var Card: CardGD = HandCardUI.getCard()
		if Card == null: continue
		HandCardUI.setDisabled(isCardDisabled(Card))

func onCreateHandCardUI(Card: CardGD, instant: bool = false) -> TbcUI:
	var HandCardUI: Control = HandCardUIPacked.instantiate()
	add_child(HandCardUI)
	HandCardUI.setInfo(Card, isCardDisabled(Card))
	var CardUI: Control = HandCardUI.getCardUI()
	
	CardUI.reparent(DrawManager)
	CardUI.position = Vector2.ZERO
	
	AniPlayer.play("DrawCard")
	onShiftHandCards(HandCardUI)
	
	await AniPlayer.animation_finished
	await onShiftDrawnHandCard(HandCardUI, CardUI)
	
	return CardUI

func isCardDisabled(Card: CardGD) -> bool:
	return !selectable_cards or !Card.isPlayable(energy)

func onUpdateEnergy(_energy: int) -> void:
	energy = _energy
	onUpdateSelectableCards()
	
func onUpdateCardEnergy() -> void:
	onUpdateSelectableCards()
	
func onUpdatePlayerPhaseNoAction(_is_player_phase_no_action: bool, instant: bool = false) -> void:
	is_player_phase_no_action = _is_player_phase_no_action
	onUpdatePin(instant)
	onUpdateSelectableCards()
	
func isValidPin() -> bool: return phase == Game.Phases.START or is_player_phase_no_action
func isValidSelectableCards() -> bool: return phase == Game.Phases.START or is_player_phase_no_action
func isValidDown() -> bool: return !pinned and !is_mouse_in_ui

func onShiftHandCards(IgnoreHandCardUI: Control = null) -> void:
	var amount: int = get_child_count()
	var rotations: Array = CARD_AMOUNT_TO_ROTATION[amount]
	for i: int in range(amount):
		var HandCardUI: Control = get_child(i)
		if HandCardUI == IgnoreHandCardUI: continue
		
		var CardUI: TbcUI = HandCardUI.getCardUI()
		onCreateRotationTween(CardUI, rotations[i])
		onCreatePosYTween(CardUI, rotations[i] * 2)
		
func onCreateRotationTween(CardUI: TbcUI, _new_rot: float) -> void:
	var rtween := create_tween()
	var new_rot: float = _new_rot - CardUI.rotation_degrees
	rtween.tween_property(CardUI, "rotation_degrees", new_rot, SHIFT_HANDS_TIME)\
		.as_relative().set_trans(Tween.TRANS_SINE)
	
func onCreatePosYTween(CardUI: TbcUI, _new_p: float, desired_position: Vector2 = CardUI.global_position) -> void:
	var ptween := create_tween()
	var new_p := Vector2(desired_position.x, desired_position.y + _new_p) - CardUI.global_position
	ptween.tween_property(CardUI, "global_position", new_p, SHIFT_HANDS_TIME)\
		.as_relative().set_trans(Tween.TRANS_SINE)
	await ptween.finished
	
func onShiftDrawnHandCard(HandCardUI: Control, CardUI: TbcUI) -> void:
	var amount: int = get_child_count()
	var new_rot: float = CARD_AMOUNT_TO_ROTATION[amount][amount - 1]
	
	onCreateRotationTween(CardUI, new_rot)
	var stween := create_tween()
	var new_s: Vector2 = Vector2.ONE - DrawManager.scale
	stween.tween_property(DrawManager, "scale", new_s, SHIFT_HANDS_TIME)\
		.as_relative().set_trans(Tween.TRANS_SINE)
	await onCreatePosYTween(CardUI, new_rot * 2, HandCardUI.global_position)
	CardUI.reparent(HandCardUI)
