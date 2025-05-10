extends Control

signal mouse_in_ui
signal add_reward
signal rewards_finished

const ELITE_FIGHT_DIVIDER_SIZE: int = 50

@export var RewardsCardsPacked: PackedScene
@export var RewardsItemPacked: PackedScene
@export var EliteCardRewardUIPacked: PackedScene

@onready var MainContainer: VBoxContainer = %MainContainer
@onready var RewardsContainer: HBoxContainer = %RewardsContainer
@onready var SkipButton: Button = %SkipButton
@onready var MinimapControl: Control = %MinimapControl

@onready var FirstContainer: Container = %FirstContainer
@onready var FadeCreamBackground: Control = %FadeCreamBackground

var EliteCardRewardUI: Control

var rewards: Rewards
var save_file: SaveFileGD
var level_type: Game.FightTypes

var is_elite: bool
var epic_default_rewards: Array

const ELITE_MOVE_DOWN_HEIGHT: int = 100

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE) # Avoid kuba glitch

func setInfo(_rewards: Rewards, _save_file: SaveFileGD, _level_type: Game.FightTypes) -> void:
	FadeCreamBackground.onFade(true)
	rewards = _rewards
	save_file = _save_file
	level_type = _level_type
	
	is_elite = level_type == Game.FightTypes.ELITE
	
	if is_elite:
		FirstContainer.size.y -= ELITE_MOVE_DOWN_HEIGHT
		FirstContainer.position.y += ELITE_MOVE_DOWN_HEIGHT
		
	var items: Array = rewards.items
	for reward: Reward in items:
		onCreateReward(reward)
	onRewardsFinished()
	
		
func onCreateReward(reward: Reward) -> void:
	if reward.item is CardGD and is_elite:
		EliteCardRewardUI = EliteCardRewardUIPacked.instantiate()
		FirstContainer.add_child(EliteCardRewardUI)
		FirstContainer.move_child(EliteCardRewardUI, 0)
		EliteCardRewardUI.setInfo(reward)
		EliteCardRewardUI.pressed.connect(onRewardPressed)
		return
	
	var RewardsItem: Control = RewardsItemPacked.instantiate()
	RewardsContainer.add_child(RewardsItem)
	RewardsItem.mouse_signal.connect(onMouseInUI)
	RewardsItem.setInfo(reward)
	
	if !reward.taken: RewardsItem.pressed.connect(onRewardPressed)
		
func onMouseInUI(state: bool) -> void:
	mouse_in_ui.emit(state)
	
func onRewardPressed(reward: Reward) -> void:
	add_reward.emit(reward)
	if reward.item is ActionWrapper and reward.item.hasType(ChangeShillingsAction):
		reward.item.onUse()
		onRewardTaken(reward)
		
	elif reward.item is ActionWrapper and reward.item.hasType(ChooseRewardAction):
		var ChooseRewardsUI: Control = Game.onCreateChooseRewardsUIScreen(reward, self)
		ChooseRewardsUI.taken.connect(onRewardTaken)
		
	elif reward.item is BoonGD:
		Game.getArea().onPushAction(AddBoonAction.new(reward.item.info.id, reward.item.getAscended()))
		onRewardTaken(reward)
		
	elif reward.item is ToolGD:
		var ToolPickedUpUI: Control = Game.onCreateToolPickedUpUI(reward.item, false, self)
		ToolPickedUpUI.taken.connect(onToolTaken.bind(reward))
		
	elif reward.item is CardGD:
		Game.getArea().onPushAction(AddToDeckAction.new(reward.item))
		onRewardTaken(reward)
		
func onToolTaken(_Tool: ToolGD, reward: Reward) -> void:
	onRewardTaken(reward)
		
func onRewardTaken(reward: Reward) -> void:
	if is_elite and !EliteCardRewardUI.taken:
		EliteCardRewardUI.setTaken(true)
		EliteCardRewardUI.reward.setTaken(true)
		if reward.item is CardGD:
			for _reward: Reward in rewards.items.duplicate():
				onRewardTaken(_reward)
		
	for child in RewardsContainer.get_children():
		if child.reward == reward:
			child.setTaken(true)
			break
		
	rewards.onRewardTaken(reward)
	onRewardsFinished()

func onRewardsFinished() -> void:
	if rewards.items.all(func(x: Reward): return x.taken):
		SkipButton.text = "Continue"

func onSkipButtonPressed() -> void:
	rewards_finished.emit()
	queue_free()

func onRemoveRewards() -> void:
	EliteCardRewardUI.queue_free()
	for child in RewardsContainer.get_children():
		child.queue_free()
		
	FirstContainer.size.y += ELITE_MOVE_DOWN_HEIGHT
	FirstContainer.position.y -= ELITE_MOVE_DOWN_HEIGHT
	rewards.taken_items = []
