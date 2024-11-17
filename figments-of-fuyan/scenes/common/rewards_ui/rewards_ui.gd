extends Control

signal mouse_in_ui
signal add_reward
signal rewards_finished

@export var RewardsCardsPacked: PackedScene
@export var RewardsItemPacked: PackedScene
@onready var MainContainer: VBoxContainer = %MainContainer
@onready var RewardsContainer: HBoxContainer = %RewardsContainer
@onready var SkipButton: Button = %SkipButton

var reward_amount: int = 0
var rewards: Rewards

func setInfo(_rewards: Rewards) -> void:
	rewards = _rewards
	for item in rewards.items:
		onCreateReward(item, false)
		reward_amount += 1
		
	for item in rewards.taken_items:
		onCreateReward(item, true)
	onRewardsFinished()
		
func onCreateReward(item: Variant, taken: bool) -> void:
	var RewardsItem: Control = RewardsItemPacked.instantiate()
	RewardsContainer.add_child(RewardsItem)
	RewardsItem.mouse_signal.connect(onMouseInUI)
	RewardsItem.setInfo(item, taken)
	
	if !taken:
		RewardsItem.pressed.connect(onRewardPressed)
		
func onMouseInUI(state: bool) -> void:
	mouse_in_ui.emit(state)
	
func onRewardPressed(reward: Variant) -> void:
	add_reward.emit(reward)
		
func onRewardTaken(reward: Variant) -> void:
	for child in RewardsContainer.get_children():
		if child.item is Array:
			if reward is CardGD and reward in child.item:
				child.setTaken(true)
		elif child.item == reward:
			child.setTaken(true)
		
	rewards.onRewardTaken(reward)
	reward_amount -= 1
	onRewardsFinished()

func onRewardsFinished() -> void:
	if reward_amount == 0:
		SkipButton.text = "Continue"

func onSkipButtonPressed() -> void:
	rewards_finished.emit()
