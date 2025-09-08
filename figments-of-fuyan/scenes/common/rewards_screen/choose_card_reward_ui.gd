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

const MAX_SCALE_SIZE: float = 1.1

func setInfo(_reward: Reward) -> void:
	reward = _reward
	action = reward.getItem().getType(ChooseRewardAction)[0]
	var is_taken: bool = reward.isTaken()
	
	var i: int = 0
	for Card: CardGD in action.getItems():
		var control := Control.new()
		control.custom_minimum_size = Game.CARD_UI_SIZE
		control.mouse_filter = Control.MOUSE_FILTER_IGNORE
		CardContainer.add_child(control)
		
		var CardUI: Control = Card.onCreateCardUI(control, !is_taken, false, true)
		if is_taken:
			CardUI.onChangeBackgroundMouseFilter(false)
			CardUI.onScaleIconUISize(true, true)
			CardUI.scale = Vector2(MAX_SCALE_SIZE, MAX_SCALE_SIZE)
		
		CardUI.set_anchors_preset(Control.PRESET_CENTER)
		CardUI.pressed.connect(onRewardPressed)
		if is_taken and i == action.chosen_index:
			call_deferred("onCreateClaimedLabel", CardUI)
		i += 1
		
	if reward.isTaken(): Main.modulate = CLAIMED_COLOR
		
func onRewardPressed(CardUI: Control) -> void:
	if reward.isTaken(): return
	reward.setTaken(true)
	action.onItemChosen(CardUI.getCard())
	
	for control: Control in CardContainer.get_children():
		var _CardUI: Control = control.get_child(0)
		_CardUI.setHoverable(false)
		_CardUI.onChangeBackgroundMouseFilter(false)
	
	get_viewport().update_mouse_cursor_state()
	
	var tween := create_tween()
	tween.tween_property(Main, "modulate", CLAIMED_COLOR, Game.FADE_TIME)

	var ClaimedLabel: Label = onCreateClaimedLabel(CardUI)
	ClaimedLabel.modulate.a = 0.0
	
	var label_tween := create_tween()
	label_tween.tween_property(ClaimedLabel, "modulate:a", 1.0, Game.FADE_TIME)
	
	reward_taken.emit(reward)
	CardUI.onScaleIconUISize(true, true)
	
	var Card: CardGD = CardUI.Card
	var data: SavedDataCard = Card.onSave()
	var DupeCard: CardGD = SavedData.onLoadModel(Card.getDuplicateData(), Game.getSaveFile())
	Game.getSaveFile().onPushAction(AddToDeckAction.new(DupeCard))
	
func onCreateClaimedLabel(CardUI: Control) -> Label:
	var ClaimedLabel: Label = ClaimedLabelPacked.instantiate()
	add_child(ClaimedLabel)
	
	var control: Control = CardUI.get_parent()
	ClaimedLabel.global_position = control.global_position + PRECALCULATED_CLAIMED_LABEL_POSITION
	return ClaimedLabel
	
