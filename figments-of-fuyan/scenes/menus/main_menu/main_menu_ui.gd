extends Control

#region Globals
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
		World.begin_travel.connect(onBeginTravel)
		World.end_travel.connect(onEndTravel)
		World.champion_pressed.connect(onChampionPressed)
#endregion

func onBeginTravel(__: String, ___: bool) -> void:
	GoBackLabel.visible = false
	onClearChampionUI()

func onEndTravel(__: String, ___: bool) -> void:
	GoBackLabel.visible = true

#region Champion Selected
var ChampionSelectUI: Control
func onChampionPressed(Unit: UnitGD) -> void:
	onClearChampionUI()
	ChampionSelectUI = ChampionSelectUIPacked.instantiate()
	add_child(ChampionSelectUI)
	ChampionSelectUI.setInfo(Unit)
	ChampionSelectUI.start.connect(onStart.bind(Unit))
	
func onClearChampionUI() -> void:
	if ChampionSelectUI != null: ChampionSelectUI.queue_free()
	
func onStart(Unit: UnitGD) -> void: start.emit(Unit)
#endregion
