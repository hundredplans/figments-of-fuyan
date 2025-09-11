extends Control

signal pressed

var disabled: bool
var ChampionCard: CardGD
@onready var CardUI: TbcUI = %CardUI

func setInfo(action: Action, reward: Reward) -> void:
	var tier: int = action.getTier()
	var champion_id: int = Game.getSaveFile().getChampionCard().info.id
	var card_info: CardInfo = Helper.getFofInfoID(CardInfo, champion_id)
	var card_data := SavedDataCard.new(card_info.id, true)
	card_data.tier = tier
	Game.setCardDataFromInfo(card_data, card_info)
	
	ChampionCard = SavedData.onLoadModel(card_data, Game.getSaveFile())
	CardUI.setInfo(ChampionCard, true, false, true, reward.isTaken())
	CardUI.setMouseFilter(Control.MOUSE_FILTER_IGNORE if reward.isTaken() else Control.MOUSE_FILTER_STOP)
	setDisabled(reward.isTaken())

func setDisabled(state: bool) -> void:
	disabled = state
	CardUI.setDisabled(disabled)

func onTreeExited() -> void:
	ChampionCard.onClear()

func onRewardPressed(__: TbcUI) -> void:
	if disabled: return
	pressed.emit()

func onScaleIconUISize(state: bool, instant: bool = false) -> void:
	CardUI.onScaleIconUISize(state, instant)

func setMouseFilter(_mouse_filter: Control.MouseFilter) -> void:
	CardUI.setMouseFilter(_mouse_filter)
	
