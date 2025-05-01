extends Node3D
const DIVINUS_ID: int = 2
var ChampionCard: CardGD

@onready var Decoration: Node3D = %Decoration

func setInfo(area_id: int) -> void:
	var champion_info: ChampionCardInfo = Helper.getFofInfoID(ChampionCardInfo, DIVINUS_ID)
	var champion_data := SavedDataCard.new(champion_info.id, true)
	
	ChampionCard = SavedData.onLoadModel(champion_data, self)
	ChampionCard.onCreateModel()
	ChampionCard.getModel().rotation.y = 0
	
	var area_info: AreaInfo = Helper.getFofInfoID(AreaInfo, area_id)
	var decoration_datastore: DecorationDatastore = area_info.main_menu_decoration
	
	for data: SavedData in decoration_datastore.data:
		SavedData.onLoadModel(data, Decoration)
	
func onStart() -> void:
	ChampionCard.onIdle()
	ChampionCard.AniPlayer.play("ChampionEntrance")
	
func onSetToEndState() -> void:
	ChampionCard.onIdle()
