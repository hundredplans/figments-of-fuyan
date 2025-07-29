extends Control

signal reward_taken
signal stash_screen_fade_in
signal stash_screen_fade_out
var reward: Reward
var action: ChooseRewardAction
var StashScreen: Control

const CLAIMED_COLOR := Color(0.5, 0.5, 0.5, 1.0)

const PRECALCULATED_CLAIMED_LABEL_BOON_OFFSET := Vector2(-125, 120)
const PRECALCULATED_CLAIMED_LABEL_TOOL_OFFSET := Vector2(-125, 120)
const PRECALCULATED_CLAIMED_LABEL_CARD_UI_OFFSET := Vector2(-125, 120)

@export var ToolIconPacked: PackedScene
@export var spicy_rice_massive: LabelSettings
@export var ClaimedLabelPacked: PackedScene

@onready var BoonControl: Control = %BoonControl
@onready var ToolControl: Control = %ToolControl
@onready var CardControl: Control = %CardControl

@onready var Main: Control = %Main
@onready var CardContainer: Container = %CardContainer

@onready var BoonLabel: Label = %BoonLabel
@onready var ToolLabel: Label = %ToolLabel
@onready var CardLabel: Label = %CardLabel

@onready var BoonIcon: Control = %BoonIcon
@onready var ToolIcon: Control = %ToolIcon
var EpicCardUI: Control

func setInfo(_reward: Reward) -> void:
	reward = _reward
	action = reward.getItem().getType(ChooseRewardAction)[0]
	var reward_type: ChooseRewardAction.RewardType = action.reward_type
	var rarity := Game.Rarities.MINIBOSS if reward_type == ChooseRewardAction.RewardType.MINIBOSS else Game.Rarities.BOSS
	
	for label: Label in [BoonLabel, ToolLabel, CardLabel]:
		label.modulate = Game.getRarityColor(rarity)
		
	var items: Array = action.getItems()
	
	for i: int in range(items.size()):
		var item: FofGD = items[i]
		var IconUI: Control
		if item is BoonGD:
			IconUI = BoonIcon
			BoonIcon.setInfo(item, !reward.isTaken())
			BoonIcon.setMouseFilter(Control.MouseFilter.MOUSE_FILTER_IGNORE\
				if reward.isTaken() else Control.MouseFilter.MOUSE_FILTER_STOP)
			BoonIcon.mouse_in_ui.connect(onMouseInIconUI.bind(BoonIcon))
			BoonIcon.pressed.connect(onBoonPressed.bind(BoonIcon))
		elif item is ToolGD:
			IconUI = ToolIcon
			ToolIcon.setInfo(item, !reward.isTaken())
			ToolIcon.setMouseFilter(Control.MouseFilter.MOUSE_FILTER_IGNORE\
				if reward.isTaken() else Control.MouseFilter.MOUSE_FILTER_STOP)
			ToolIcon.mouse_in_ui.connect(onMouseInIconUI.bind(ToolIcon))
			ToolIcon.pressed.connect(onToolPressed.bind(IconUI))
		elif item is CardGD:
			var CardUI: Control = item.onCreateCardUI(CardControl, !reward.isTaken())
			if reward.isTaken():
				CardUI.onChangeBackgroundMouseFilter(false, false)
			IconUI = CardUI
			EpicCardUI = CardUI
			CardUI.position = Vector2(80, 0)
			#CardUI.set_anchors_preset(Control.PRESET_CENTER_TOP)
			CardUI.mouse_in_ui.connect(onMouseInIconUI.bind(CardUI))
			CardUI.pressed.connect(onCardUIPressed)
			
		if reward.isTaken() and i == action.chosen_index:
			call_deferred("onCreateClaimedLabel", item)

	BoonIcon.onDisplayCharges(false)
	ToolIcon.setExpandMode(TextureRect.ExpandMode.EXPAND_FIT_HEIGHT)
	
	if reward.isTaken(): Main.modulate = CLAIMED_COLOR

func onMouseInIconUI(state: bool, IconUI: Control) -> void:
	if reward.isTaken(): return
	var tween: Tween = create_tween()
	var target_value: float = 1.1 if state else 0.9
	var value: float = target_value - IconUI.scale.x
	tween.tween_property(IconUI, "scale", Vector2(value, value), 0.25).as_relative().set_trans(Tween.TRANS_SINE)

func onCardUIPressed(CardUI: Control) -> void:
	if reward.isTaken(): return
	var DupeCard: CardGD = SavedData.onLoadModel(CardUI.Card.getDuplicateData(), Game.getSaveFile())
	Game.getSaveFile().onPushAction(AddToDeckAction.new(DupeCard))
	onRewardTaken(CardUI, CardUI.Card)
	
func onBoonPressed(Boon: BoonGD, BoonUI: Control) -> void:
	if reward.isTaken(): return
	Game.getSaveFile().onPushAction(AddBoonAction.new(Boon.info.id, Game.getArea().getWorldDifficulty()))
	onRewardTaken(BoonUI, Boon)
	
func onRewardTaken(_IconUI: Control, item: FofGD) -> void:
	onCreateClaimedLabel(item)
	reward.setTaken(true)
	
	for NewIconUI: Control in [BoonIcon, ToolIcon, EpicCardUI]:
		NewIconUI.setHighlightOnHover(false)
		var tween := create_tween()
		tween.tween_property(NewIconUI, "scale", Vector2.ONE, 0.25)
		
	ToolIcon.setMouseFilter(Control.MOUSE_FILTER_IGNORE)
	BoonIcon.setMouseFilter(Control.MOUSE_FILTER_IGNORE)
	EpicCardUI.onChangeBackgroundMouseFilter(false, false)
	reward_taken.emit(reward)
	
	var new_tween := create_tween()
	new_tween.tween_property(Main, "modulate", CLAIMED_COLOR, Game.FADE_TIME)
	action.onItemChosen(item)
	
func onToolPressed(Tool: ToolGD, OriginalToolIcon: Control) -> void:
	if reward.isTaken() or StashScreen != null: return
	var _ToolIcon: Control = ToolIconPacked.instantiate()
	add_child(_ToolIcon)
	_ToolIcon.setInfo(Tool, false)
	_ToolIcon.setDisableTooltip(true)
	_ToolIcon.setSizeScale(3)
	_ToolIcon.top_level = true
	
	StashScreen = Game.onCreateStashScreen(self, _ToolIcon)
	stash_screen_fade_in.emit()
	StashScreen.active_tool_added.connect(onToolClaimed.bind(_ToolIcon, OriginalToolIcon))
	StashScreen.exit_start.connect(onActiveToolStashExitStart.bind(_ToolIcon))
	
func onToolClaimed(_CardUI: Control, _ToolIcon: Control, OriginalToolIcon: Control) -> void:
	onRemoveActiveToolIcon(_ToolIcon)
	onRewardTaken(OriginalToolIcon, _ToolIcon.Tool)
	
func onCreateClaimedLabel(item: FofGD) -> Label:
	var ClaimedLabel: Label = ClaimedLabelPacked.instantiate()
	ClaimedLabel.label_settings = spicy_rice_massive
	add_child(ClaimedLabel)
	
	if StashScreen != null:
		move_child(ClaimedLabel, StashScreen.get_index())
	
	var offset: Vector2
	var control: Control
	if item is ToolGD:
		offset = PRECALCULATED_CLAIMED_LABEL_TOOL_OFFSET
		control = ToolControl
	elif item is BoonGD:
		offset = PRECALCULATED_CLAIMED_LABEL_BOON_OFFSET
		control = BoonControl
	elif item is CardGD:
		offset = PRECALCULATED_CLAIMED_LABEL_CARD_UI_OFFSET
		control = CardControl
	
	ClaimedLabel.global_position = control.global_position + offset
	return ClaimedLabel

func onRemoveActiveToolIcon(_ToolIcon: Variant) -> void:
	if _ToolIcon != null: _ToolIcon.queue_free()
	
func onActiveToolStashExitStart(_ToolIcon: Variant) -> void:
	onRemoveActiveToolIcon(_ToolIcon)
	stash_screen_fade_out.emit()
