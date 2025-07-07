extends Control

@export var ClaimedLabelPacked: PackedScene

@onready var Main: Control = %Main
@onready var CardContainer: Container = %CardContainer

signal reward_taken

var reward: Reward
var action: ChooseRewardAction
var taken: bool

const PRECALCULATED_CLAIMED_LABEL_POSITION := Vector2(-195, 110)
const CLAIMED_CARD_COLOR := Color(0.2, 0.2, 0.2)
const CLAIMED_COLOR := Color(0.5, 0.5, 0.5, 1.0)

func setInfo(_reward: Reward) -> void:
	reward = _reward
	action = reward.getItem().getType(ChooseRewardAction)[0]
	var taken: bool = reward.isTaken()
	
	var i: int = 0
	for Card: CardGD in action.getItems():
		var control := Control.new()
		control.custom_minimum_size = Game.CARD_UI_SIZE
		CardContainer.add_child(control)
		
		var CardUI: Control = Card.onCreateCardUI(control, !taken, true, null)
		CardUI.set_anchors_preset(Control.PRESET_CENTER)
		CardUI.pressed.connect(onRewardPressed)
		CardUI.mouse_in_ui.connect(onMouseInCardUI.bind(CardUI))
		if taken and i == action.chosen_index:
			call_deferred("onCreateClaimedLabel", CardUI)
		i += 1
		
	if reward.isTaken(): Main.modulate = CLAIMED_COLOR
		
func onRewardPressed(CardUI: Control) -> void:
	if reward.isTaken(): return
	reward.setTaken(true)
	action.onItemChosen(CardUI.getCard())
	
	for control: Control in CardContainer.get_children():
		var _CardUI: Control = control.get_child(0)
		_CardUI.setHighlightOnHover(false)
	
	get_viewport().update_mouse_cursor_state()
	
	var tween := create_tween()
	tween.tween_property(Main, "modulate", CLAIMED_COLOR, Game.FADE_TIME)

	var scale_tween := create_tween()
	scale_tween.tween_property(CardUI, "scale", Vector2.ONE, 0.25)

	var ClaimedLabel: Label = onCreateClaimedLabel(CardUI)
	ClaimedLabel.modulate.a = 0.0
	
	var label_tween := create_tween()
	label_tween.tween_property(ClaimedLabel, "modulate:a", 1.0, Game.FADE_TIME)
	
	reward_taken.emit(reward)
	
	var Card: CardGD = CardUI.Card
	Game.getSaveFile().onPushAction(AddToDeckAction.new(Card))
	
func onCreateClaimedLabel(CardUI: Control) -> Label:
	var ClaimedLabel: Label = ClaimedLabelPacked.instantiate()
	add_child(ClaimedLabel)
	
	var control: Control = CardUI.get_parent()
	ClaimedLabel.global_position = control.global_position + PRECALCULATED_CLAIMED_LABEL_POSITION
	return ClaimedLabel

func onMouseInCardUI(state: bool, CardUI: Control) -> void:
	if reward.isTaken(): return
	var tween: Tween = create_tween()
	var value: float = 0.1 if state else -0.1
	tween.tween_property(CardUI, "scale", Vector2(value, value), 0.25).as_relative().set_trans(Tween.TRANS_SINE)
