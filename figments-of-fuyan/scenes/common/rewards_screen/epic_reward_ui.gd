extends Control

signal reward_taken
signal stash_screen_fade_in
signal stash_screen_fade_out
var reward: Reward
var action: ChooseRewardAction

const CLAIMED_COLOR := Color(0.5, 0.5, 0.5, 1.0)
const PRECALCULATED_CLAIMED_LABEL_POSITION := Vector2(-70, 150)

@export var ToolIconPacked: PackedScene
@export var spicy_rice_massive: LabelSettings
@export var ClaimedLabelPacked: PackedScene

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
			BoonIcon.mouse_in_ui.connect(onMouseInIconUI.bind(BoonIcon))
			BoonIcon.pressed.connect(onBoonPressed.bind(BoonIcon))
		elif item is ToolGD:
			IconUI = ToolIcon
			ToolIcon.setInfo(item, !reward.isTaken())
			ToolIcon.mouse_in_ui.connect(onMouseInIconUI.bind(ToolIcon))
			ToolIcon.pressed.connect(onToolPressed)
		elif item is CardGD:
			var CardUI: Control = item.onCreateCardUI(CardContainer, !reward.isTaken())
			IconUI = CardUI
			EpicCardUI = CardUI
			CardContainer.move_child(CardUI, 0)
			CardUI.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
			CardUI.mouse_in_ui.connect(onMouseInIconUI.bind(CardUI))
			CardUI.pressed.connect(onCardUIPressed)
			
		if reward.isTaken() and i == action.chosen_index:
			onCreateClaimedLabel(IconUI)

	BoonIcon.onDisplayCharges(false)
	ToolIcon.setExpandMode(TextureRect.ExpandMode.EXPAND_FIT_HEIGHT)
	if reward.isTaken(): Main.modulate = CLAIMED_COLOR

func onMouseInIconUI(state: bool, IconUI: Control) -> void:
	if reward.isTaken(): return
	var tween: Tween = create_tween()
	var value: float = 0.1 if state else -0.1
	tween.tween_property(IconUI, "scale", Vector2(value, value), 0.25).as_relative().set_trans(Tween.TRANS_SINE)

func onCardUIPressed(CardUI: Control) -> void:
	if reward.isTaken(): return
	Game.getSaveFile().onPushAction(AddToDeckAction.new(CardUI.Card))
	onRewardTaken(CardUI, CardUI.Card)
	
func onBoonPressed(Boon: BoonGD, BoonUI: Control) -> void:
	if reward.isTaken(): return
	Game.getSaveFile().onPushAction(AddBoonAction.new(Boon.info.id, false))
	onRewardTaken(BoonUI, Boon)
	
func onRewardTaken(IconUI: Control, item: FofGD) -> void:
	onCreateClaimedLabel(IconUI)
	reward.setTaken(true)
	
	for _IconUI: Control in [BoonIcon, ToolIcon, EpicCardUI]:
		_IconUI.setHighlightOnHover(false)
		var tween := create_tween()
		tween.tween_property(_IconUI, "scale", Vector2.ONE, 0.25)
	reward_taken.emit(reward)
	
	var tween := create_tween()
	tween.tween_property(Main, "modulate", CLAIMED_COLOR, Game.FADE_TIME)
	action.onItemChosen(item)
	
func onToolPressed(Tool: ToolGD) -> void:
	if reward.isTaken(): return
	var ToolIcon: Control = ToolIconPacked.instantiate()
	add_child(ToolIcon)
	ToolIcon.setInfo(Tool, false)
	ToolIcon.setDisableTooltip(true)
	ToolIcon.setSizeScale(3)
	ToolIcon.top_level = true
	
	var StashScreen: Control = Game.onCreateStashScreen(self, ToolIcon)
	stash_screen_fade_in.emit()
	StashScreen.active_tool_added.connect(onToolClaimed.bind(ToolIcon))
	StashScreen.exit_start.connect(onActiveToolStashExitStart.bind(ToolIcon))
	
func onToolClaimed(_CardUI: Control, ToolIcon: Control) -> void:
	onRemoveActiveToolIcon(ToolIcon)
	onRewardTaken(ToolIcon, ToolIcon.Tool)
	
func onCreateClaimedLabel(IconUI: Control) -> Label:
	var ClaimedLabel: Label = ClaimedLabelPacked.instantiate()
	ClaimedLabel.label_settings = spicy_rice_massive
	add_child(ClaimedLabel)
	
	ClaimedLabel.global_position = IconUI.global_position
	return ClaimedLabel

func onRemoveActiveToolIcon(ToolIcon: Variant) -> void:
	if ToolIcon != null: ToolIcon.queue_free()
	
func onActiveToolStashExitStart(ToolIcon: Variant) -> void:
	onRemoveActiveToolIcon(ToolIcon)
	stash_screen_fade_out.emit()
