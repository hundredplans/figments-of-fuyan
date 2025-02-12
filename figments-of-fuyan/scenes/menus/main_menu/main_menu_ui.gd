extends Control

#region Globals
signal cancel_champion_selected
signal start
signal load_game
signal mouse_in_ui
signal remove_save

var World: Node3D
@onready var GoBackLabel: Label = %GoBackLabel
@onready var ContinueLabel: Label = %ContinueLabel
@onready var NewGameLabel: Label = %NewGameLabel
@onready var LoadLabel: Label = %LoadLabel
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
		World.create_ui.connect(onCreateUI)
		World.mouse_in_mesh.connect(onMouseInMesh)
#endregion

#region Travelling
func onTravelStateChanged(travel_info: CameraTravelDatastore) -> void:
	if ActiveMenu != null: ActiveMenu.queue_free()
	GoBackLabel.visible = !travel_info.is_start and !travel_info.end.name == "MainMenu"
	if travel_info.start != null and travel_info.start.name == "ChampionPressed": onClearChampionUI()
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
	
func onStart(Card: CardGD) -> void:
	start.emit(Card)
#endregion

#region Menus
var ActiveMenu: Control
func onCreateUI(_menu: PackedScene) -> void:
	if ActiveMenu != null: ActiveMenu.queue_free()
	ActiveMenu = _menu.instantiate()
	ActiveMenu.load_game.connect(onLoadGame)
	ActiveMenu.mouse_in_ui.connect(onMouseInUI)
	
	if "remove_save" in ActiveMenu: ActiveMenu.remove_save.connect(onRemoveSave)
	
	add_child(ActiveMenu)
	
func onLoadGame(saved_data: SavedDataSaveFile) -> void:
	load_game.emit(saved_data)
	
func onRemoveSave() -> void:
	remove_save.emit()
#endregion

#region Mouse In UI
var is_mouse_in_ui: bool
func onMouseInUI(state: bool) -> void:
	is_mouse_in_ui = state
	mouse_in_ui.emit(state)
	
func onMouseInMesh(mesh: MeshInstance3D, state: bool) -> void:
	if mesh == null: return
	match mesh.name:
		"NewGame": NewGameLabel.visible = state
		"LoadGame": LoadLabel.visible = state
		"Continue": ContinueLabel.visible = state
#endregion
