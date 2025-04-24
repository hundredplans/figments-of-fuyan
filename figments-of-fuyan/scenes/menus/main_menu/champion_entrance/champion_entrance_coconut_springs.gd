extends Node3D
const DIVINUS_ID: int = 2
var ChampionCard: CardGD

func setInfo() -> void:
	var champion_info: ChampionCardInfo = Helper.getFofInfoID(ChampionCardInfo, DIVINUS_ID)
	var champion_data := SavedDataCard.new(champion_info.id, true)
	
	ChampionCard = SavedData.onLoadModel(champion_data, self)
	ChampionCard.onCreateModel()
	ChampionCard.getModel().rotation.y = 0
	
func onStart() -> void:
	ChampionCard.onIdle()
	ChampionCard.AniPlayer.play("ChampionEntrance")
	
func onSetToEndState() -> void:
	ChampionCard.onIdle()
