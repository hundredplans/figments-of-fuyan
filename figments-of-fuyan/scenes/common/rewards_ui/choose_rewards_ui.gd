extends Control

signal taken
signal mouse_signal

const NON_CARD_REWARD_MINIMUM_SIZE_X: int = 350

@onready var RewardsContainer: HBoxContainer = %RewardsContainer

@export var ToolIconPacked: PackedScene
@export var BoonIconPacked: PackedScene

func setInfo(reward: Reward) -> void:
	for item: FofGD in reward.item.getType(ChooseRewardAction)[0].getItems():
		var DisplayedUI: Control
		if item is CardGD:
			DisplayedUI = item.onCreateCardUI(RewardsContainer, true)
			DisplayedUI.pressed.connect(onCardPressed.bind(reward))
		elif item is ToolGD:
			DisplayedUI = ToolIconPacked.instantiate()
			RewardsContainer.add_child(DisplayedUI)
			DisplayedUI.setInfo(item, true)
			DisplayedUI.pressed.connect(onCreateToolPickedUpUI.bind(reward))
			
		elif item is BoonGD:
			DisplayedUI = BoonIconPacked.instantiate()
			RewardsContainer.add_child(DisplayedUI)
			DisplayedUI.setInfo(item, true)
			DisplayedUI.onDisplayCharges(false)
			DisplayedUI.pressed.connect(onRewardPressed.bind(reward))
		DisplayedUI.custom_minimum_size.x = NON_CARD_REWARD_MINIMUM_SIZE_X
		DisplayedUI.mouse_in_ui.connect(onMouseInUI)

var mouse_in_ui: bool
func onMouseInUI(state: bool) -> void:
	mouse_in_ui = state
	mouse_signal.emit(mouse_in_ui)
	
func onCardPressed(CardUI: Control, reward: Reward) -> void:
	onRewardPressed(CardUI.Card, reward)

func onRewardPressed(chosen_item: FofGD, reward: Reward) -> void:
	var choose_reward_action: ChooseRewardAction = reward.item.getType(ChooseRewardAction)[0]
	choose_reward_action.onItemChosen(chosen_item)
	reward.item.onUse()
	
	queue_free()
	taken.emit(reward)

func onCreateToolPickedUpUI(Tool: ToolGD, reward: Reward) -> void:
	var ToolPickedUpUI: Control = Game.onCreateToolPickedUpUI(Tool, false, self)
	ToolPickedUpUI.taken.connect(onRewardPressed.bind(reward))
