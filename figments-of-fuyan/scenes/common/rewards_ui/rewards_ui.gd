extends Control

signal mouse_in_ui
signal add_reward
signal rewards_finished

const ELITE_FIGHT_DIVIDER_SIZE: int = 50

@export var RewardsCardsPacked: PackedScene
@export var RewardsItemPacked: PackedScene
@export var EliteEpicCardRewardUIPacked: PackedScene

@onready var MainContainer: VBoxContainer = %MainContainer
@onready var RewardsContainer: HBoxContainer = %RewardsContainer
@onready var SkipButton: Button = %SkipButton
@onready var MinimapControl: Control = %MinimapControl

@onready var FirstContainer: Container = %FirstContainer

var EliteEpicCardRewardUI: Control

var reward_amount: int = 0
var rewards: Rewards
var save_file: SaveFileGD
var level_type: Game.FightTypes

var is_elite: bool
var is_epic: bool

var epic_default_rewards: Array

const ELITE_MOVE_DOWN_HEIGHT: int = 100


func setInfo(_rewards: Rewards, _save_file: SaveFileGD, _level_type: Game.FightTypes) -> void:
	rewards = _rewards
	save_file = _save_file
	level_type = _level_type
	
	is_elite = level_type == Game.FightTypes.ELITE
	is_epic = level_type in [Game.FightTypes.MINIBOSS, Game.FightTypes.BOSS]
	
	var is_epic_and_untaken: bool = is_epic and !rewards.epic_items.is_empty()
	if is_elite or is_epic_and_untaken:
		FirstContainer.size.y -= ELITE_MOVE_DOWN_HEIGHT
		FirstContainer.position.y += ELITE_MOVE_DOWN_HEIGHT
		
	var items: Array = rewards.items if !is_epic_and_untaken else rewards.epic_items
	for item in items:
		onCreateReward(item, false)
		reward_amount += 1
		
	for item in rewards.taken_items:
		onCreateReward(item, true)
	onRewardsFinished()
		
func onCreateReward(item: Variant, taken: bool) -> void:
	if item is CardGD and (is_elite or is_epic):
		EliteEpicCardRewardUI = EliteEpicCardRewardUIPacked.instantiate()
		FirstContainer.add_child(EliteEpicCardRewardUI)
		FirstContainer.move_child(EliteEpicCardRewardUI, 0)
		EliteEpicCardRewardUI.setInfo(item, taken)
		EliteEpicCardRewardUI.pressed.connect(onRewardPressed)
		return
	
	var RewardsItem: Control = RewardsItemPacked.instantiate()
	RewardsContainer.add_child(RewardsItem)
	RewardsItem.mouse_signal.connect(onMouseInUI)
	RewardsItem.setInfo(item, taken)
	
	if !taken: RewardsItem.pressed.connect(onRewardPressed)
		
func onMouseInUI(state: bool) -> void:
	mouse_in_ui.emit(state)
	
func onRewardPressed(reward: Variant) -> void:
	add_reward.emit(reward)
	if reward is ActionWrapper and reward.hasType(ChangeShillingsAction):
		reward.onUse()
		onRewardTaken(reward)
		
	elif reward is Array:
		var RewardsCardsUI: Control = Game.onCreateRewardsCardsUIScreen(reward, self)
		RewardsCardsUI.taken.connect(onRewardTaken)
		
	elif reward is BoonGD:
		Game.getArea().onPushAction(AddBoonAction.new(reward.info.id, reward.getAscended()))
		onRewardTaken(reward)
		
	elif reward is ToolGD:
		var ToolPickedUpUI: Control = Game.onCreateToolPickedUpUI(reward, false, self)
		ToolPickedUpUI.taken.connect(onRewardTaken)
		
	elif reward is CardGD:
		Game.getArea().onPushAction(AddToDeckAction.new(reward))
		onRewardTaken(reward)
		
func onRewardTaken(reward: Variant) -> void:
	if (is_elite or (is_epic and EliteEpicCardRewardUI != null)) and !EliteEpicCardRewardUI.taken:
		EliteEpicCardRewardUI.setTaken(true)
		
		if is_elite:
			for _reward in rewards.items.duplicate():
				var item_reward: FofGD = _reward if _reward is not Array else _reward[0]
				onRewardTaken(item_reward)
		elif is_epic:
			for item_reward in rewards.epic_items:
				onRewardTaken(item_reward)
			
			rewards.epic_items = []
			onRemoveRewards()
			
			for item in rewards.items:
				onCreateReward(item, false)
				reward_amount += 1
		
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
	queue_free()

func onRemoveRewards() -> void:
	EliteEpicCardRewardUI.queue_free()
	for child in RewardsContainer.get_children():
		child.queue_free()
	reward_amount = 0
	FirstContainer.size.y += ELITE_MOVE_DOWN_HEIGHT
	FirstContainer.position.y -= ELITE_MOVE_DOWN_HEIGHT
	rewards.taken_items = []
