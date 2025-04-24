extends Node3D

const START_ANIMATION_DELAY: float = 5.0

var ChampionEntrance: Node3D
@onready var Decoration: Node3D = %Decoration
@export var area_id: int
var UI: Control

func _ready() -> void:
	var area_info: AreaInfo = Helper.getFofInfoID(AreaInfo, area_id)
	var decoration_datastore: DecorationDatastore = area_info.main_menu_decoration
	
	for data: SavedData in decoration_datastore.data:
		SavedData.onLoadModel(data, Decoration)
	
	add_child(area_info.default_light.instantiate())
	ChampionEntrance = area_info.champion_entrance_packed.instantiate()
	ChampionEntrance.setInfo()
	add_child(ChampionEntrance)
	
func onFirstLoad() -> void:
	await get_tree().create_timer(START_ANIMATION_DELAY).timeout
	ChampionEntrance.onStart()
	
func onNotFirstLoad() -> void:
	ChampionEntrance.onSetToEndState()
