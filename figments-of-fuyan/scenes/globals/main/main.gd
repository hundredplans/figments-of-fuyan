extends Node

@onready var KeepAcross: Node3D = %KeepAcross
@export_group("Main Menu")
@export var main_menu_ui: PackedScene
@export var main_menu_world: PackedScene

@export var map_ui: PackedScene
@export var map_world: PackedScene

@export var level_ui: PackedScene
@export var level_world: PackedScene

@export var SHILLING_START_COUNT: int = 10

@onready var ActionManager: ActionManagerGD
@export var ActionManagerPacked: PackedScene

#region Base Functions
func _ready():
	if !Helper.getAdmin():
		var scenes: Dictionary = onLoadScreenWorld(main_menu_ui, main_menu_world)
		scenes.world.onFirstLoad()
	else:
		var DIR_PATH: String = SaveFileInfo.SAVE_DIRECTORY
		var files: Array = Array(DirAccess.get_files_at(DIR_PATH))
		if files.is_empty(): onStartGame(SavedData.onLoadModel(SavedDataCard.new(3, true), KeepAcross))
		else: onLoadGame(load(DIR_PATH + files[0]))
#endregion

#region Load Screen + World
var ActiveScreen: Control
var ActiveWorld: Node3D

func onLoadScreenWorld(packed_ui: PackedScene, packed_world: PackedScene) -> Dictionary:
	onLoadScreen(packed_ui)
	onLoadWorld(packed_world)
	
	ActiveScreen.World = ActiveWorld
	ActiveWorld.UI = ActiveScreen
	
	add_child(ActiveScreen)
	add_child(ActiveWorld)
	return {"ui": ActiveScreen, "world": ActiveWorld}

func onLoadScreen(packed_scene: PackedScene) -> void:
	if ActiveScreen != null: ActiveScreen.queue_free()
	ActiveScreen = packed_scene.instantiate()
	
	match packed_scene:
		main_menu_ui:
			ActiveScreen.load_game.connect(onLoadGame)
	
func onLoadWorld(packed_scene: PackedScene) -> void:
	if ActiveWorld != null: ActiveWorld.queue_free()
	ActiveWorld = packed_scene.instantiate()
	
	match packed_scene:
		main_menu_world: ActiveWorld.start.connect(onStartGame)
	
func onStartGame(Card: CardGD) -> void:
	Game.highest_public_id = 0
	var area_id: int = 1
	var area_data: SavedDataArea = SavedDataArea.new(area_id, true)
	
	var save_file_data := SavedDataSaveFile.new(getFirstEmptySaveSlotID(), true, 0, randi(), area_data, \
	SHILLING_START_COUNT, [], 0, [Card.onSave(), SavedDataCard.new(4, true), SavedDataCard.new(5, true), SavedDataCard.new(6, true), SavedDataCard.new(7, true)],
	[], Game.highest_public_id)
	
	onLoadGame(save_file_data)
	
func onLoadGame(save_file_data: SavedDataSaveFile) -> void:
	Game.highest_public_id = save_file_data.highest_public_id
	ActionManager = ActionManagerPacked.instantiate()
	add_child(ActionManager)
	Game.ActionManagerReference = ActionManager
	
	var load_map: bool = save_file_data.area_data.level_data == null
	var save_file: SaveFileGD = SavedData.onLoadModel(save_file_data, KeepAcross)
	save_file.load_level.connect(onLoadLevel)
	if load_map:
		var scenes: Dictionary = onLoadScreenWorld(map_ui, map_world)
		scenes.ui.setInfo(save_file)
		scenes.world.setInfo(save_file)
		save_file.area.onAfterScenesLoad()
	else: onLoadLevel(save_file_data.area_data.level_data, save_file)
	
func onLoadLevel(level_data: SavedDataLevel, save_file: SaveFileGD) -> void:
	var scenes: Dictionary = onLoadScreenWorld(level_ui, level_world)
	var area: AreaGD =  save_file.area
	var level: LevelGD = area.onLoadActiveLevel(level_data)
	
	scenes.ui.setInfo(save_file)
	scenes.world.setInfo(save_file)
	level.onLoadActiveLevel(level_data)
	
func getFirstEmptySaveSlotID() -> int:
	return min(DirAccess.get_files_at(SaveFileInfo.SAVE_DIRECTORY).size() + 1, 5)
#endregion
