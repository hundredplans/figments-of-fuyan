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
const CARD_REMOVED_TIME: float = 0.75
const CARD_PLAYED_ROT: float = PI * (3 / 2)

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
	
func onCreateHand(cards: Array, instant: bool) -> Array:
	var card_uis: Array = []
	for __: CardGD in cards:
		var HandCardUI: Control = HandCardUIPacked.instantiate()
		add_child(HandCardUI)
	
	for i: int in range(cards.size()):
		var HandCardUI: Control = get_child(i)
		var Card: CardGD = cards[i]
		if !Card.is_in_group("HandCardsGD"): continue
		HandCardUI.setInfo(Card, !instant)
		
		var CardUI: TbcUI = HandCardUI.getCardUI()
		card_uis.append(CardUI)
		if !instant:
			CardUI.reparent(DrawManager)
			CardUI.position = Vector2.ZERO
			AniPlayer.play("DrawCard")
			await AniPlayer.animation_finished
		await onShiftDrawnHandCard(HandCardUI, CardUI, cards.size(), i, instant)
		
	if !instant:
		for CardUI: TbcUI in card_uis:
			CardUI.setHoverable(true)
			CardUI.setAutoscale(true)
			CardUI.setDraggable(true)
			CardUI.onUpdateCursorVisual(CardUI.is_mouse_in_ui)
	return card_uis
		
func onCardPlayed(Card: CardGD) -> void:
	var HandCardUI: Control = getHandCardUI(Card)
	var CardUI: Control = HandCardUI.getCardUI()
	await onCardUIRemovedEffect(CardUI)
	
func onCardUIRemovedEffect(CardUI: TbcUI) -> void:
	var stween := create_tween()
	stween.tween_property(CardUI, "scale", -CardUI.scale + Vector2(0.01, 0.01), CARD_REMOVED_TIME)\
		.as_relative().set_trans(Tween.TRANS_SINE)
		
	var rtween := create_tween()
	rtween.tween_property(CardUI, "rotation", CARD_PLAYED_ROT, CARD_REMOVED_TIME)\
		.as_relative().set_trans(Tween.TRANS_SINE)
	rtween.tween_callback(CardUI.queue_free)
	await rtween.finished
		
func onCreateRotationTween(CardUI: TbcUI, _new_rot: float) -> void:
	var rtween := create_tween()
	var new_rot: float = _new_rot - CardUI.rotation_degrees
	rtween.tween_property(CardUI, "rotation_degrees", new_rot, SHIFT_HANDS_TIME)\
		.as_relative().set_trans(Tween.TRANS_SINE)
	
func onCreatePosYTween(CardUI: TbcUI, _new_p: float) -> void:
	var ptween := create_tween()
	var new_pos := Vector2(0, _new_p) - CardUI.position 
	ptween.tween_property(CardUI, "position", new_pos, SHIFT_HANDS_TIME)\
		.as_relative().set_trans(Tween.TRANS_SINE)
	await ptween.finished
	
func onShiftDrawnHandCard(HandCardUI: Control, CardUI: TbcUI, cards_size: int, index: int, instant: bool) -> void:
	var rot_value: float = getRotValue(index, cards_size)
	var pos_value: float = getPosValue(rot_value)
	
	if !instant:
		var global_pos: Vector2 = CardUI.global_position
		CardUI.scale = Vector2(1.5, 1.5)
		CardUI.reparent(HandCardUI)
		CardUI.global_position = global_pos
		
		var stween := create_tween()
		var new_s: Vector2 = Vector2.ONE - CardUI.scale
		stween.tween_property(CardUI, "scale", new_s, SHIFT_HANDS_TIME)\
			.as_relative().set_trans(Tween.TRANS_SINE)
			
		onCreateRotationTween(CardUI, rot_value)
		await onCreatePosYTween(CardUI, pos_value)
	else:
		CardUI.rotation_degrees = rot_value
		CardUI.position = Vector2(0, pos_value)
	
func getRotValue(index: int, cards_size: int) -> float:
	var rot_value: float
	var mid_point: float = float(cards_size) / 2.0
	var is_even: bool = cards_size % 2 == 0
	if !is_even and floor(mid_point) == index: rot_value = 0
	elif index < mid_point: rot_value = -DEGREE_CHANGE * (mid_point - index)
	elif index >= mid_point: rot_value = DEGREE_CHANGE * (index - mid_point + 1)
	return rot_value
	
func getPosValue(rot_value: float) -> float:
	return abs(rot_value * 2)
	
func getHandCardUI(Card: CardGD) -> Control:
	for HandCardUI: Control in get_children():
		if HandCardUI.getCard() == Card: return HandCardUI
	return null

func onRemoveHand(hand_cards: Array) -> void:
	for HandCard: CardGD in hand_cards.filter(func(x: CardGD): return x.is_in_group("HandCardsGD")):
		HandCard.onChangeCardPlace(Game.CardPlaces.DECK)
	
	for HandCardUI: Control in get_children():
		var CardUI: TbcUI = HandCardUI.getCardUI()
		if CardUI == null: continue
		onCardUIRemovedEffect(CardUI)
