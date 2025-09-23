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

var is_mouse_in_ui: bool
var phase: Game.Phases

var MainTween: Tween

const DEGREE_CHANGE: float = 2.5
var CARD_AMOUNT_TO_ROTATION: Dictionary[int, Array] = {
	0: [],
	1: [0],
	2: [-5, 5],
	3: [-5, 0, 5],
	4: [-7.5, -2.5, 2.5, 7.5],
	5: [-10, -5, 0, 5, 10]
}

func onMouseInUI(state: bool) -> void:
	is_mouse_in_ui = state
	mouse_in_ui.emit(state)
	
func onCreateHand(cards: Array) -> Array:
	var card_uis: Array = []
	for __: CardGD in cards:
		var HandCardUI: Control = HandCardUIPacked.instantiate()
		add_child(HandCardUI)

	for i: int in range(cards.size()):
		var HandCardUI: Control = get_child(i)
		var Card: CardGD = cards[i]
		HandCardUI.setInfo(Card, true)
		
		var CardUI: TbcUI = HandCardUI.getCardUI()
		card_uis.append(CardUI)
		CardUI.reparent(DrawManager)
		CardUI.position = Vector2.ZERO
		AniPlayer.play("DrawCard")
		await AniPlayer.animation_finished
		await onShiftDrawnHandCard(HandCardUI, CardUI, cards.size(), i)
		
	for CardUI: TbcUI in card_uis:
		CardUI.setHoverable(true)
		CardUI.setAutoscale(true)
		CardUI.setDraggable(true)
	return card_uis

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
	var new_p := Vector2(desired_position.x, desired_position.y - _new_p) - CardUI.global_position
	print(Vector2(desired_position.x, desired_position.y - _new_p))
	ptween.tween_property(CardUI, "global_position", new_p, SHIFT_HANDS_TIME)\
		.as_relative().set_trans(Tween.TRANS_SINE)
	await ptween.finished
	
func onShiftDrawnHandCard(HandCardUI: Control, CardUI: TbcUI, cards_size: int, index: int) -> void:
	var mid_point: float = float(cards_size) / 2.0
	var rot_value: float = 0

	if index < mid_point: rot_value = -DEGREE_CHANGE * (mid_point - index)
	elif index >= mid_point: rot_value = DEGREE_CHANGE * (index - mid_point + 1)
	
	var pos_value: float = abs(rot_value * 2) * -1
	var stween := create_tween()
	var new_s: Vector2 = Vector2.ONE - DrawManager.scale
	stween.tween_property(DrawManager, "scale", new_s, SHIFT_HANDS_TIME)\
		.as_relative().set_trans(Tween.TRANS_SINE)
		
	await onCreatePosYTween(CardUI, pos_value, HandCardUI.global_position)
	
	CardUI.reparent(HandCardUI)
