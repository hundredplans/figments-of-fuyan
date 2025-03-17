extends Control

signal taken
signal mouse_signal

const NON_CARD_REWARD_MINIMUM_SIZE_X: int = 350

@onready var RewardsContainer: HBoxContainer = %RewardsContainer

@export var ToolIconPacked: PackedScene
@export var BoonIconPacked: PackedScene

func setInfo(rewards: ActionWrapper) -> void:
	for reward: FofGD in rewards.getType(ChooseRewardAction)[0].getItems():
		var DisplayedUI: Control
		if reward is CardGD:
			DisplayedUI = reward.onCreateCardUI(RewardsContainer, true)
			DisplayedUI.pressed.connect(onCardPressed.bind(rewards))
		elif reward is ToolGD:
			DisplayedUI = ToolIconPacked.instantiate()
			RewardsContainer.add_child(DisplayedUI)
			DisplayedUI.setInfo(reward, true)
			DisplayedUI.pressed.connect(onCreateToolPickedUpUI.bind(rewards))
			
		elif reward is BoonGD:
			DisplayedUI = BoonIconPacked.instantiate()
			RewardsContainer.add_child(DisplayedUI)
			DisplayedUI.setInfo(reward, true)
			DisplayedUI.onDisplayCharges(false)
			DisplayedUI.pressed.connect(onRewardPressed.bind(rewards))
		DisplayedUI.custom_minimum_size.x = NON_CARD_REWARD_MINIMUM_SIZE_X
		DisplayedUI.mouse_in_ui.connect(onMouseInUI)

var mouse_in_ui: bool
func onMouseInUI(state: bool) -> void:
	mouse_in_ui = state
	mouse_signal.emit(mouse_in_ui)
	
func onCardPressed(CardUI: Control, rewards: ActionWrapper) -> void:
	onRewardPressed(CardUI.Card, rewards)

func onRewardPressed(reward: FofGD, rewards: ActionWrapper) -> void:
	var choose_reward_action: ChooseRewardAction = rewards.getType(ChooseRewardAction)[0]
	choose_reward_action.onItemChosen(reward)
	rewards.onUse()
	
	queue_free()
	taken.emit(rewards)

func onCreateToolPickedUpUI(Tool: ToolGD, rewards: ActionWrapper) -> void:
	var ToolPickedUpUI: Control = Game.onCreateToolPickedUpUI(Tool, false, self)
	ToolPickedUpUI.taken.connect(onRewardPressed.bind(rewards))
