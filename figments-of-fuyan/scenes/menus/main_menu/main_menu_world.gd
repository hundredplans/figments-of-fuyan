extends Node3D

const START_ANIMATION_DELAY: float = 3.0

@onready var WorldEnv: WorldEnvironment = %WorldEnv
@onready var Decoration: Node3D = %Decoration
@export var ChampionSelectPacked: PackedScene

var ChampionEntranceNode: Node3D
var ChampionSelect: Node3D

var UI: Control

func _ready() -> void:
	UI.load_champion_select.connect(onLoadChampionSelect)
	onLoadChampionEntrance()
	
func onLoadChampionEntrance() -> void:
	var area_id: int = UI.getSelectedAreaID()
	var area_info: AreaInfo = Helper.getFofInfoID(AreaInfo, area_id)
	ChampionEntranceNode = area_info.champion_entrance_packed.instantiate()
	
	add_child(ChampionEntranceNode)
	ChampionEntranceNode.setInfo(area_id)
	ChampionEntranceNode.add_child(area_info.default_light.instantiate())
	
	WorldEnv.environment = area_info.getBaseEnvironment()
	
func onFirstLoad() -> void:
	await get_tree().create_timer(START_ANIMATION_DELAY).timeout
	ChampionEntranceNode.onStart()
	
func onNotFirstLoad() -> void:
	ChampionEntranceNode.onSetToEndState()
	
func onLoadChampionSelect(ChampionSelectUI: Control) -> void:
	ChampionEntranceNode.queue_free()
	ChampionSelect = ChampionSelectPacked.instantiate()
	ChampionSelectUI.arrow_pressed.connect(ChampionSelect.onRotateChampions)
	ChampionSelectUI.view_champion.connect(ChampionSelect.onViewChampion)
	ChampionSelectUI.unview_champion.connect(ChampionSelect.onUnviewChampion)
	ChampionSelectUI.setChampionSelect(ChampionSelect)
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
