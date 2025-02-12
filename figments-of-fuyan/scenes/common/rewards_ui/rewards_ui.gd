extends Control

signal mouse_in_ui
signal add_reward
signal rewards_finished

const ELITE_FIGHT_DIVIDER_SIZE: int = 50

@export var RewardsCardsPacked: PackedScene
@export var RewardsItemPacked: PackedScene
@export var ChiefCardRewardUIPacked: PackedScene

@onready var MainContainer: VBoxContainer = %MainContainer
@onready var RewardsContainer: HBoxContainer = %RewardsContainer
@onready var SkipButton: Button = %SkipButton
@onready var MinimapControl: Control = %MinimapControl

@onready var FirstContainer: Container = %FirstContainer

var ChiefCardRewardUI: Control

var reward_amount: int = 0
var rewards: Rewards
var save_file: SaveFileGD
var is_elite: bool

const ELITE_MOVE_DOWN_HEIGHT: int = 100

func setInfo(_rewards: Rewards, _save_file: SaveFileGD, _is_elite: bool = false) -> void:
	rewards = _rewards
	save_file = _save_file
	is_elite = _is_elite
	
	if is_elite:
		FirstContainer.size.y -= ELITE_MOVE_DOWN_HEIGHT
		FirstContainer.position.y += ELITE_MOVE_DOWN_HEIGHT
	
	for item in rewards.items:
		onCreateReward(item, false)
		reward_amount += 1
		
	for item in rewards.taken_items:
		onCreateReward(item, true)
	onRewardsFinished()
		
func onCreateReward(item: Variant, taken: bool) -> void:
	if !(item is CardGD and is_elite):
		var RewardsItem: Control = RewardsItemPacked.instantiate()
		RewardsContainer.add_child(RewardsItem)
		RewardsItem.mouse_signal.connect(onMouseInUI)
		RewardsItem.setInfo(item, taken)
		
		if !taken: RewardsItem.pressed.connect(onRewardPressed)
		return
		
	ChiefCardRewardUI = ChiefCardRewardUIPacked.instantiate()
	FirstContainer.add_child(ChiefCardRewardUI)
	FirstContainer.move_child(ChiefCardRewardUI, 0)
	ChiefCardRewardUI.setInfo(item, taken)
	ChiefCardRewardUI.pressed.connect(onChiefCardRewardPressed)
	
func onChiefCardRewardPressed(Card: CardGD) -> void:
	onRewardPressed(Card)
	ChiefCardRewardUI.setTaken(true)
	for _reward in rewards.items.duplicate():
		var reward: FofGD = _reward if _reward is not Array else _reward[0]
		onRewardTaken(reward)
		
func onMouseInUI(state: bool) -> void:
	mouse_in_ui.emit(state)
	
func onRewardPressed(reward: Variant) -> void:
	add_reward.emit(reward)
	if reward is MapEffectGD and reward.info.id == 2: # Shillings gain
		reward.onPickup(save_file)
		onRewardTaken(reward)
		
	elif reward is Array:
		var RewardsCardsUI: Control = Game.onCreateRewardsCardsUIScreen(reward, self)
		RewardsCardsUI.taken.connect(onRewardTaken)
		
	elif reward is BoonGD:
		save_file.onAddBoon(reward)
		onRewardTaken(reward)
		
	elif reward is ToolGD:
		var ToolPickedUpUI: Control = Game.onCreateToolPickedUpUI(reward, false, self)
		ToolPickedUpUI.taken.connect(onRewardTaken)
		
	elif reward is CardGD:
		Game.save_file.onAddToDeck(reward)
		onRewardTaken(reward)
		
func onRewardTaken(reward: Variant) -> void:
	if is_elite and !ChiefCardRewardUI.taken:
		rewards.onRewardTaken(ChiefCardRewardUI.CardUI.Card)
		reward_amount -= 1
		ChiefCardRewardUI.setTaken(true)
		
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
