extends Node

@onready var KeepAcross: Node3D = %KeepAcross
@export_group("Main Menu")
@export var main_menu_ui: PackedScene
@export var main_menu_world: PackedScene

@export var map_ui: PackedScene
@export var map_world: PackedScene

@export var level_ui: PackedScene
@export var level_world: PackedScene

@export var SHILLING_START_COUNT: int = 60

@onready var ActionManager: ActionManagerGD
@export var ActionManagerPacked: PackedScene

@onready var SaveLabel: Label = %SaveLabel

@export var main_menu_music: AudioStream

const SAVE_LABEL_DELAY_TIME: float = 0.5
const SAVE_LABEL_VISIBLE_TIME: float = 1.0

#region Base Functions
func _ready():
	if !Helper.admin_datastore.skip_main_menu:
		onLoadMainMenu()
		if !Helper.admin_datastore.skip_start_cutscene:
			ActiveWorld.onFirstLoad()
			ActiveScreen.onFirstLoad()
		else:
			ActiveWorld.onNotFirstLoad()
			ActiveScreen.onNotFirstLoad()
	else:
		var DIR_PATH: String = SaveFileInfo.SAVE_DIRECTORY
		var files: Array = Array(DirAccess.get_files_at(DIR_PATH))
		
		var champion_id: int = Helper.admin_datastore.starting_champion_id
		var card_info: CardInfo = Helper.getFofInfoID(CardInfo, champion_id)
			
		var card_data: SavedDataCard = card_info.saved_data.new(card_info.id, true)
		Game.setCardDataFromInfo(card_data, card_info)
		
		if files.is_empty(): onStartGame(card_data)
		else: onLoadGame(load(DIR_PATH + files[0]))
	
#endregion

#region Helper
func getFirstEmptySaveSlotID() -> int:
	return min(Helper.getSaveFileCount() + 1, 5)
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
	if ActiveScreen != null: ActiveScreen.queue_free(); ActiveScreen.get_parent().remove_child(ActiveScreen)
	ActiveScreen = packed_scene.instantiate()
	
	match packed_scene:
		main_menu_ui:
			ActiveScreen.load_game.connect(onLoadGame)
	
func onLoadWorld(packed_scene: PackedScene) -> void:
	if ActiveWorld != null: ActiveWorld.queue_free(); ActiveWorld.get_parent().remove_child(ActiveWorld)
	ActiveWorld = packed_scene.instantiate()
	
	match packed_scene:
		_: pass
		#main_menu_world: ActiveWorld.start.connect(onStartGame)
	
func onStartGame(card_data: SavedDataCard) -> void:
	Game.highest_public_id = 0
	var area_id: int = 1
	var area_data: SavedDataArea = SavedDataArea.new(area_id, true)
	card_data.card_place = Game.CardPlaces.DECK
	
	var save_file_data := SavedDataSaveFile.new(
		getFirstEmptySaveSlotID(), true, 0, randi(), area_data,\
		SHILLING_START_COUNT, 0, [card_data], [], Game.highest_public_id, [])
	
	onLoadGame(save_file_data)
	
func onLoadGame(save_file_data: SavedDataSaveFile) -> void:
	Audio.onPlayMusic()
	Game.highest_public_id = save_file_data.highest_public_id
	ActionManager = ActionManagerPacked.instantiate()
	add_child(ActionManager)
	Game.ActionManagerReference = ActionManager
	
	var save_file: SaveFileGD = SavedData.onLoadModel(save_file_data, KeepAcross)
	
	save_file.load_level.connect(onLoadLevel)
	save_file.load_map.connect(onLoadMap)
	save_file.load_main_menu.connect(onLoadMainMenu)
	save_file.input_saved.connect(onSaveFileSaved)
	save_file.exit_save.connect(onExitSaveFile)
	save_file.onLoadGame()
	
func onLoadLevel(level_data: SavedDataLevel, save_file: SaveFileGD, area: AreaGD) -> void:
	var scenes: Dictionary = onLoadScreenWorld(level_ui, level_world)
	var level: LevelGD = area.onLoadActiveLevel(level_data)
	
	scenes.ui.setInfo(save_file)
	scenes.world.setInfo(save_file)
	level.onLoadActiveLevel(level_data, save_file)

func onLoadMap(save_file: SaveFileGD, area: AreaGD) -> void:
	var scenes: Dictionary = onLoadScreenWorld(map_ui, map_world)
	area.onLoadMap()
	
	scenes.ui.setInfo(save_file)
	scenes.world.setInfo(save_file)
	area.onLoadMapAfterScenes()
	
func onLoadMainMenu() -> void:
	onLoadScreenWorld(main_menu_ui, main_menu_world)
	for child in KeepAcross.get_children(): child.queue_free()
	
func onExitSaveFile() -> void:
	for child in KeepAcross.get_children(): child.queue_free()
	onLoadScreenWorld(main_menu_ui, main_menu_world)
	
var SaveFileTween: Tween
func onSaveFileSaved() -> void:
	if SaveFileTween != null:
		SaveFileTween.stop()
	
	SaveLabel.modulate = Color(1, 1, 1, 1)
	await get_tree().create_timer(SAVE_LABEL_DELAY_TIME).timeout
		
	SaveFileTween = create_tween()
	SaveFileTween.tween_property(SaveLabel, "modulate:a", 0.0, SAVE_LABEL_VISIBLE_TIME)
	
#endregion
