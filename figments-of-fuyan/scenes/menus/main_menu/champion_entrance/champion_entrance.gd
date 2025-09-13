class_name ChampionEntrance extends Node3D

var ChampionCard: CardGD
@onready var ChampionParent: Node3D = %ChampionParent
@onready var Camera: Camera3D = %Camera3D

func setInfo(area_id: int) -> void:
	var area_info: AreaInfo = Helper.getFofInfoID(AreaInfo, area_id)
	Helper.level_editor_area_info = area_info
	var DecorationParent := Node3D.new()
	add_child(DecorationParent)
	
	Camera.current = true
	
	var champion_info: ChampionCardInfo = Helper.getFofInfoID(ChampionCardInfo, area_info.getChampionID())
	var champion_data := SavedDataCard.new(champion_info.id, true)
	
	ChampionCard = SavedData.onLoadModel(champion_data, ChampionParent)
	ChampionCard.onCreateModel()
	ChampionCard.getModel().rotation.y = 0
	ChampionCard.setIdleModifier("Intro")
	
	var decoration_datastore: DecorationDatastore = area_info.main_menu_decoration
	for _data: SavedData in decoration_datastore.data:
		var data: SavedData = _data.duplicate()
		SavedData.onLoadModel(_data, DecorationParent)
		
	add_child(area_info.getBackgroundScene())
	
func onStart() -> void:
	ChampionCard.AniPlayer.play("IntroEntrance")
	
func onSetToEndState() -> void:
	ChampionCard.onIdle()
