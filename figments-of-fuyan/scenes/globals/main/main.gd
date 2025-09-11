extends Node

signal push_action
signal push_after_action
signal append_action
signal force_action

@onready var KeepAcross: Node3D = %KeepAcross
@onready var LoadingScreenBackground: Node3D = %LoadingScreenBackground

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
@export var LoadingScreenUIPacked: PackedScene

var NAME_TO_LOADING_SCREEN_DATASTORE: Dictionary[String, LoadingScreenDatastore] = {}

const SAVE_LABEL_DELAY_TIME: float = 0.5
const SAVE_LABEL_VISIBLE_TIME: float = 1.0

#region Base Functions
func _ready():
	ActionManager = ActionManagerPacked.instantiate()
	add_child(ActionManager)
	Game.ActionManagerReference = ActionManager
	Game.main = self
	ActionManager.process_action.connect(onProcessAction)
	
	push_action.connect(Game.ActionManagerReference.onPushAction)
	push_after_action.connect(Game.ActionManagerReference.onPushAfterAction)
	append_action.connect(Game.ActionManagerReference.onAppendAction)
	force_action.connect(Game.ActionManagerReference.onForceAction)
	
	onCreateLoadingScreens()
	
	DirAccess.make_dir_recursive_absolute("user://save/save_files")
	if !Helper.admin_datastore.skip_main_menu:
		onLoadMainMenu(Helper.admin_datastore.skip_start_cutscene)
	else:
		var DIR_PATH: String = SaveFileInfo.SAVE_DIRECTORY
		var files: Array = Array(DirAccess.get_files_at(DIR_PATH))
		
		var champion_id: int = Helper.admin_datastore.starting_champion_id
		var card_info: CardInfo = Helper.getFofInfoID(ChampionCardInfo, champion_id)
		
		if files.is_empty() or Helper.admin_datastore.use_new_save_file: onStartGame(card_info)
		else: onLoadGame(load(DIR_PATH + files[0]))
	
func onProcessAction(action: Action) -> void:
	if action.post:
		if action is StartLoadingScreenAction:
			onStartLoadingScreenPost()
		elif action is EndLoadingScreenAction:
			onEndLoadingScreen()
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
			ActiveScreen.start_game.connect(onStartGame)
	
func onLoadWorld(packed_scene: PackedScene) -> void:
	if ActiveWorld != null: ActiveWorld.queue_free(); ActiveWorld.get_parent().remove_child(ActiveWorld)
	ActiveWorld = packed_scene.instantiate()
	
func onStartGame(champion_info: ChampionCardInfo) -> void:
	Game.public_id_objects = {}
	Game.highest_public_id = 0
	
	var card_data := SavedDataCard.new(champion_info.id, true)
	Game.setCardDataFromInfo(card_data, champion_info)
	
	var save_file_data := SavedDataSaveFile.new(
		getFirstEmptySaveSlotID(), true, 0, randi(), null,\
		SHILLING_START_COUNT, 0, [card_data], [], Game.highest_public_id)
	
	onLoadGame(save_file_data)
	
func onLoadGame(save_file_data: SavedDataSaveFile) -> void:
	Game.public_id_objects = {}
	Game.highest_public_id = save_file_data.highest_public_id
	
	var save_file: SaveFileGD = SavedData.onLoadModel(save_file_data, KeepAcross)
	save_file.load_level.connect(onLoadLevel)
	save_file.load_map.connect(onLoadMap)
	save_file.load_main_menu.connect(onLoadMainMenu)
	save_file.input_saved.connect(onSaveFileSaved)
	save_file.onLoadGame()
	
func onLoadLevel(level_data: SavedDataLevel) -> void:
	var save_file: SaveFileGD = Game.getSaveFile()
	var area: AreaGD = Game.getArea()
	var scenes: Dictionary = onLoadScreenWorld(level_ui, level_world)
	var level: LevelGD = area.onLoadActiveLevel(level_data)
	
	scenes.ui.setInfo(save_file)
	scenes.world.setInfo(save_file)
	level.onLoadActiveLevel(level_data, save_file)

func onLoadMap() -> void:
	var area: AreaGD = Game.getArea()
	var save_file: SaveFileGD = Game.getSaveFile()
	var scenes: Dictionary = onLoadScreenWorld(map_ui, map_world)
	area.onLoadMap(ActiveWorld)
	
	scenes.ui.setInfo(save_file)
	scenes.world.setInfo(save_file)
	area.call_deferred("onLoadMapAfterScenes")
	
func onLoadMainMenu(skip_cutscene: bool = true) -> void:
	get_tree().set_auto_accept_quit(true)
	onLoadScreenWorld(main_menu_ui, main_menu_world)
	for child in KeepAcross.get_children(): child.queue_free()
	if !skip_cutscene:
		ActiveWorld.onFirstLoad()
		ActiveScreen.onFirstLoad()
	else:
		ActiveWorld.onNotFirstLoad()
		ActiveScreen.onNotFirstLoad()
	
var SaveFileTween: Tween
func onSaveFileSaved() -> void:
	if SaveFileTween != null:
		SaveFileTween.stop()
	
	SaveLabel.modulate = Color(1, 1, 1, 1)
	await get_tree().create_timer(SAVE_LABEL_DELAY_TIME).timeout
		
	SaveFileTween = create_tween()
	SaveFileTween.tween_property(SaveLabel, "modulate:a", 0.0, SAVE_LABEL_VISIBLE_TIME)
	
#endregion

func onCreateLoadingScreens() -> void:
	for child: Node3D in LoadingScreenBackground.get_children(): child.queue_free()

	var j: int = 1
	var areas: Array = Helper.getFofInfoArray(AreaInfo)
	for area_info: AreaInfo in areas:
		var loading_screens: Array = area_info.getLoadingScreens()
		for i: int in range(loading_screens.size()):
			var decoration_datastore: DecorationDatastore = loading_screens[i].getDecorationDatastore()
			var parent := Node3D.new()
			parent.name = loading_screens[i].getName()
			LoadingScreenBackground.add_child(parent)
			
			parent.position.x += (2000 * j)
			for _data: SavedData in decoration_datastore.data:
				var data: SavedData = _data.duplicate()
				data.public_id = 0
				SavedData.onLoadModel(data, parent)
			var background_scene: Node3D = area_info.getBackgroundScene()
			parent.add_child(background_scene)
			
			var camera: Camera3D = loading_screens[i].getCamera()
			parent.add_child(camera)
			camera.name = "LoadingCamera"
			parent.visible = false
			
			NAME_TO_LOADING_SCREEN_DATASTORE[parent.name] = loading_screens[i]
			j += 1
		
func onEndLoadingScreen() -> void:
	for LoadingParent: Node3D in LoadingScreenBackground.get_children():
		LoadingParent.visible = false
	onRemoveLoadingScreenUI()
		
func onStartLoadingScreen(action: StartLoadingScreenAction) -> void:
	var area_id: int = action.getAreaID()
	var loading_screens: Array = Helper.getFofInfoID(AreaInfo, area_id).getLoadingScreens()
	var loading_screens_names: Array = loading_screens.map(func(x: LoadingScreenDatastore): return x.getName())

	var LoadingParent: Node3D = LoadingScreenBackground.get_children()\
		.filter(func(x: Node3D): return x.name in loading_screens_names).pick_random()
	LoadingParent.get_node("LoadingCamera").current = true
	LoadingParent.visible = true
	
	onCreateLoadingScreenUI(action)
	
func onStartLoadingScreenPost() -> void:
	onAppendAction(EndLoadingScreenAction.new())
	
var LoadingScreenUI: Control
func onCreateLoadingScreenUI(action: StartLoadingScreenAction) -> void:
	onRemoveLoadingScreenUI()
	LoadingScreenUI = LoadingScreenUIPacked.instantiate()
	add_child(LoadingScreenUI)
	LoadingScreenUI.setInfo(action)
	
func onRemoveLoadingScreenUI() -> void:
	if LoadingScreenUI != null: LoadingScreenUI.onRemove()
		
#region Action
func onPushAction(actions: Variant, action_owner: Variant = self) -> void:
	if actions is Action:
		actions = [actions]

	for action in actions:
		action.owner = action_owner
	push_action.emit(actions)
		
# If action is succesfully found
func onPushAfterAction(actions: Variant, action_or_script: Variant, action_owner: Variant = self) -> bool:
	var after_action: Action
	if action_or_script is GDScript:
		var action: Action = Game.ActionManagerReference.onFindFirstAction(action_or_script)
		if action == null: return false
		after_action = action
		
	elif action_or_script is Action:
		after_action = action_or_script
	
	if actions is Action:
		actions = [actions]
		
	actions.reverse()
	for action in actions:
		action.owner = action_owner
		
	push_after_action.emit(actions, after_action)
	return true
	
func onAppendAction(actions: Variant, action_owner: Variant = self) -> void:
	if actions is Action: actions = [actions]
	
	for action in actions:
		action.owner = action_owner
		append_action.emit(action)
		
func onForceAction(action: Action) -> void:
	action.owner = self
	action.forced = true
	force_action.emit(action)
#endregion
