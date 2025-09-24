extends Control

signal reward_taken

const PRECALCULATED_CLAIMED_LABEL_POSITION := Vector2(-480, 80)
const PRECALCULATED_CLAIMED_LABEL_POSITION_CARD := Vector2(-190, 100)

@export var ChampionUpgradeRewardPacked: PackedScene
@export var IconUpgradeRewardPacked: PackedScene

@export var energy_limit_icon: Texture2D
@export var deck_limit_icon: Texture2D

@export_multiline var energy_limit_text: String
@export_multiline var max_energy_text: String
@export_multiline var deck_limit_text: String
@export  var ClaimedLabelPacked: PackedScene

@onready var RewardsContainer: Container = %RewardsContainer

var TempChampionCard: CardGD
var reward: Reward
var action_wrapper: ActionWrapper

func setInfo(_reward: Reward) -> void:
	reward = _reward
	action_wrapper = reward.getItem()
	
	var chosen_index: int = action_wrapper.getChosenIndex()
	var i: int = 0
	for action: Action in action_wrapper.getActions():
		var ControlUI: Control
		if action is EnergyLimitAction or action is CardLimitAction:
			var IconUpgradeReward: Control = IconUpgradeRewardPacked.instantiate()
			RewardsContainer.add_child(IconUpgradeReward)
			var tx: Texture2D = getIconFromAction(action)
			var text: String = getTextFromAction(action)
			IconUpgradeReward.setInfo(tx, text, reward.isTaken())
			IconUpgradeReward.pressed.connect(onRewardPressed.bind(action, IconUpgradeReward))
			ControlUI = IconUpgradeReward
		elif action is CardRetieredAction:
			ControlUI = onCreateUpgradedChampionCard(action)
			
		if i == chosen_index:
			onCreateClaimedLabel.call_deferred(ControlUI, action is CardRetieredAction)
			if reward.isTaken():
				ControlUI.onScaleIconUISize(true, true)
		i += 1

func onRewardPressed(action: Action, control: Control) -> void:
	Game.getSaveFile().onPushAction(action)
	reward.setTaken(true)
	action_wrapper.setChosenIndex(action)
	
	onCreateClaimedLabel(control, action is CardRetieredAction)
	for child: Control in RewardsContainer.get_children():
		child.setDisabled(true)
		child.setMouseFilter(Control.MOUSE_FILTER_IGNORE)
		
	reward_taken.emit(reward)
	
func getIconFromAction(action: Action) -> Texture2D:
	if action is EnergyLimitAction: return energy_limit_icon
	elif action is CardLimitAction: return deck_limit_icon
	return null
	
func getTextFromAction(action: Action) -> String:
	if action is EnergyLimitAction: return energy_limit_text % action.getDelta()
	elif action is CardLimitAction: return deck_limit_text % action.getDelta()
	return ""

func onCreateUpgradedChampionCard(action: CardRetieredAction) -> Control:
	var ChampionUpgradeReward: Control = ChampionUpgradeRewardPacked.instantiate()
	RewardsContainer.add_child(ChampionUpgradeReward)
	ChampionUpgradeReward.setInfo(action, reward)
	ChampionUpgradeReward.pressed.connect(onRewardPressed.bind(action, ChampionUpgradeReward))
	return ChampionUpgradeReward

func onTreeExited() -> void:
	if TempChampionCard != null: TempChampionCard.onClear()

func onCreateClaimedLabel(control: Control, is_card: bool) -> Label:
	var ClaimedLabel: Label = ClaimedLabelPacked.instantiate()
	add_child(ClaimedLabel)
	
	if !is_card:
		ClaimedLabel.scale = Vector2(2, 2)
		ClaimedLabel.global_position = control.global_position + PRECALCULATED_CLAIMED_LABEL_POSITION
	else: ClaimedLabel.global_position = control.global_position + PRECALCULATED_CLAIMED_LABEL_POSITION_CARD
	
	return ClaimedLabel
