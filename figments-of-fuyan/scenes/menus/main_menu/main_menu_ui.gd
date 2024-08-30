extends Control

#region Globals
signal cancel_champion_selected
signal start
var World: Node3D
@onready var GoBackLabel: Label = %GoBackLabel
#endregion

#region Exports
@export var ChampionSelectUIPacked: PackedScene
#endregion

#region Base Functions
func _ready() -> void:
	GoBackLabel.visible = false
	if World != null:
		World.travel.connect(onTravelStateChanged)
		World.champion_pressed.connect(onChampionPressed)
#endregion

#region Travelling
func onTravelStateChanged(travel_info: CameraTravelDatastore) -> void:
	GoBackLabel.visible = !travel_info.is_start
	if travel_info.start.name == "ChampionPressed": onClearChampionUI()
#endregion

#region Champion Selected
var ChampionSelectUI: Control
func onChampionPressed(Card: CardGD) -> void:
	onClearChampionUI()
	ChampionSelectUI = ChampionSelectUIPacked.instantiate()
	add_child(ChampionSelectUI)
	ChampionSelectUI.setInfo(Card)
	ChampionSelectUI.start.connect(onStart.bind(Card))
	ChampionSelectUI.cancel.connect(func(): cancel_champion_selected.emit())
	
func onClearChampionUI() -> void:
	if ChampionSelectUI != null: ChampionSelectUI.queue_free()
	
func onStart(Card: CardGD) -> void: start.emit(Card)
#endregion
