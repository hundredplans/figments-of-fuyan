extends Control

const WAIT_TIME: float = 4
const FADEOUT_TIME: float = 1.5

@onready var ChampionUpgradeLabel: Label = %ChampionUpgradeLabel
@onready var MainContainer: HBoxContainer = %MainContainer

func setInfo() -> void:
	var upgrade_level: int = Game.getSaveFile().getChampionLevel()
	ChampionUpgradeLabel.text = "Champion Upgrade [" + str(upgrade_level - 1) + " -> " + str(upgrade_level) + "]"
	var ChampionCard: CardGD = Game.getSaveFile().getChampionCard()
	
	var champion_data: SavedData = ChampionCard.onSave()
	var data := SavedDataCard.new(ChampionCard.info.id, true)
	var info: ChampionCardInfo = Helper.getFofInfoID(ChampionCardInfo, data.id)
	Game.setCardDataFromInfo(data, info)
	data.tool_data = champion_data.tool_data
	
	var PreviousChampionCard: CardGD = SavedData.onLoadModel(data, Game.getSaveFile())
	PreviousChampionCard.onChangeCardPlace(Game.CardPlaces.NULL)
	
	for i in range(upgrade_level - 1):
		PreviousChampionCard.onUpgrade(i)
		
	await get_tree().process_frame # While actions are processed
	var PreviousCardUI: Control = PreviousChampionCard.onCreateCardUI(MainContainer, false, false)
	PreviousCardUI.setDisableTooltip(true)
	PreviousChampionCard.onClear()
	
	var CardUI: Control = ChampionCard.onCreateCardUI(MainContainer, false, false)
	CardUI.setDisableTooltip(true)
	MainContainer.move_child(PreviousCardUI, 0)
	
	await get_tree().create_timer(WAIT_TIME).timeout
	
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 0, FADEOUT_TIME)
	
	await tween.finished
	queue_free()
