extends Node3D
const DIVINUS_ID: int = 2
var ChampionCard: CardGD

@onready var Camera: Camera3D = %Camera3D
@onready var Decoration: Node3D = %Decoration

func setInfo(area_id: int) -> void:
	Helper.level_editor_area_info = Helper.getFofInfoID(AreaInfo, area_id)
	var champion_info: ChampionCardInfo = Helper.getFofInfoID(ChampionCardInfo, DIVINUS_ID)
	var champion_data := SavedDataCard.new(champion_info.id, true)
	
	Camera.current = true
	ChampionCard = SavedData.onLoadModel(champion_data, self)
	ChampionCard.onCreateModel()
	ChampionCard.getModel().rotation.y = 0
	ChampionCard.setIdleModifier("Intro")
	
	var area_info: AreaInfo = Helper.getFofInfoID(AreaInfo, area_id)
	var decoration_datastore: DecorationDatastore = area_info.main_menu_decoration
	
	for _data: SavedData in decoration_datastore.data:
		var data: SavedData = _data.duplicate()
		SavedData.onLoadModel(_data, Decoration)
	
func onStart() -> void:
	ChampionCard.AniPlayer.play("IntroEntrance")
	
func onSetToEndState() -> void:
	ChampionCard.onIdle()
