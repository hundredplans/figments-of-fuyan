extends Node3D

const START_ANIMATION_DELAY: float = 5.0

@onready var Decoration: Node3D = %Decoration
@export var area_id: int

@export var ChampionSelectPacked: PackedScene

var ChampionEntrance: Node3D
var ChampionSelect: Node3D

var UI: Control

func _ready() -> void:
	UI.load_champion_select.connect(onLoadChampionSelect)
	onLoadChampionEntrance()
	
func onLoadChampionEntrance() -> void:
	var area_info: AreaInfo = Helper.getFofInfoID(AreaInfo, area_id)
	ChampionEntrance = area_info.champion_entrance_packed.instantiate()
	
	add_child(ChampionEntrance)
	ChampionEntrance.setInfo(area_id)
	ChampionEntrance.add_child(area_info.default_light.instantiate())
	
func onFirstLoad() -> void:
	await get_tree().create_timer(START_ANIMATION_DELAY).timeout
	ChampionEntrance.onStart()
	
func onNotFirstLoad() -> void:
	ChampionEntrance.onSetToEndState()
	
func onLoadChampionSelect(ChampionSelectUI: Control) -> void:
	ChampionEntrance.queue_free()
	ChampionSelect = ChampionSelectPacked.instantiate()
	ChampionSelectUI.arrow_pressed.connect(ChampionSelect.onRotateChampions)
	ChampionSelectUI.view_champion.connect(ChampionSelect.onViewChampion)
	ChampionSelectUI.unview_champion.connect(ChampionSelect.onUnviewChampion)
	onReplaceDecoration()
	
	add_child(ChampionSelect)
	
	UI.setChampionCards(ChampionSelect.getChampionCards())

func onUnloadChampionSelect() -> void:
	ChampionSelect.queue_free()
	ChampionSelect = null
	onLoadChampionEntrance()
	onNotFirstLoad()

func onReplaceDecoration() -> void:
	for child: Node3D in Decoration.get_children(): child.queue_free()
