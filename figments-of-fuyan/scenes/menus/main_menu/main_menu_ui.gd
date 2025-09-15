extends Control

signal mouse_in_ui
signal start_game
signal load_game
signal load_champion_select

const VALID_AREA_IDS: Array = [1, 3]
var selected_area_id: int
var MAIN_MENU_BUTTONS: Array = ["Start", "Settings", "Extras", "", "Exit"]

@onready var AniPlayer: AnimationPlayer = %AniPlayer
@onready var FadeBackground: Control = %FadeBackground
@onready var MainMenuButtonsVBox: VBoxContainer = %MainMenuButtonsVBox

@export var LoadMenuPacked: PackedScene
@export var ChampionSelectUIPacked: PackedScene
@export var MainMenuButtonPacked: PackedScene

var World: Node3D
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("Back") and pressable:
		onBackInputPressed()

func onFirstLoad() -> void:
	AniPlayer.play("FirstLoad")
	AniPlayer.queue("SlideUIElements")

func onNotFirstLoad() -> void:
	FadeBackground.modulate = Color.BLACK
	onTransitionEnd()
	AniPlayer.play("SlideUIElements")

func _ready() -> void:
	Audio.onPlayMusic(Audio.MAIN_MENU)
	selected_area_id = VALID_AREA_IDS.pick_random()
	onLoadButtons(MAIN_MENU_BUTTONS, false)

#region Mouse In UI
var is_mouse_in_ui: bool
func onMouseInUI(state: bool) -> void:
	is_mouse_in_ui = state
	mouse_in_ui.emit(state)
#endregion

#region Main Menu Buttons
var active_button_name: String
const SLIDE_MAIN_MENU_BUTTONS_DELAY: float = 0.20
func onLoadButtons(button_names: Array, use_animation: bool = true) -> void:
	if use_animation:
		AniPlayer.play("SlideMainMenuButtons")
		await get_tree().create_timer(AniPlayer.get_animation("SlideMainMenuButtons").length / 2).timeout
	
	for child: Control in MainMenuButtonsVBox.get_children(): child.queue_free()
	for button_name: String in button_names:
		var HBox := HBoxContainer.new()
		var MainMenuButton: Label = MainMenuButtonPacked.instantiate()
		MainMenuButton.setAreaID(selected_area_id)
		MainMenuButton.text = button_name
		MainMenuButton.pressed.connect(onMainMenuButtonPressed.bind(MainMenuButton.text))
		MainMenuButton.setPressable(false)
		MainMenuButtonsVBox.add_child(HBox)
		
		var fill := Control.new()
		fill.size_flags_vertical = Control.SIZE_EXPAND_FILL
		
		HBox.add_child(MainMenuButton)
		HBox.add_child(fill)
		
		match button_name:
			"Continue":
				if Helper.getSaveFileCount() == 0: MainMenuButton.setDisabled(true)
			"New Game":
				if Helper.getSaveFileCount() == Helper.SAVE_FILE_MAX_AMOUNT: MainMenuButton.setDisabled(true)
		
	await get_tree().create_timer(SLIDE_MAIN_MENU_BUTTONS_DELAY).timeout
	setPressable(true)
	
	get_viewport().update_mouse_cursor_state()
	
var PLAY_BUTTON_NAMES: Array = ["Continue", "New Game", "Load", "", "Back"]
var EXTRAS_BUTTON_NAMES: Array = ["Fuyanopedia", "", "Back"]
var SETTINGS_BUTTON_NAMES: Array = ["To", "Be", "Released", "", "Back"]
var LOAD_BUTTON_NAMES: Array = ["Back"]

func getMainMenuButtons() -> Array:
	var main_menu_buttons: Array = []
	for HBox: Control in MainMenuButtonsVBox.get_children():
		main_menu_buttons.append(HBox.get_child(0))
	return main_menu_buttons

func onMainMenuButtonPressed(button_name: String) -> void:
	setPressable(false)
		
	match button_name:
		"Start": onLoadButtons(PLAY_BUTTON_NAMES)
		"Settings": onLoadButtons(SETTINGS_BUTTON_NAMES)
		"Extras": onLoadButtons(EXTRAS_BUTTON_NAMES)
		"New Game":
			onNewGamePressed()
		"Load": onLoadLoadMenu()
		"Continue": onContinue()
		"Back": onBack()
		"Exit": get_tree().quit()
		_:
			setPressable(true)
			return
		
	active_button_name = button_name # Has to be at end or else pressed button takes it
#endregion

#region Back
func onBackInputPressed() -> void:
	var success: bool = onBack()
	if success:
		setPressable(false)
	
func onBack() -> bool: # Returns if it succeeded
	if active_button_name in ["New Game", "Start", "Extras", "Settings", "Back", "Load"]:
		onLoadButtons(MAIN_MENU_BUTTONS)
		active_button_name = ""
		return true
	return false
#endregion

#region Champion Select
var ChampionSelectUI: Control
const FADE_BACKGROUND_TIME: float = 0.25
func onLoadChampionSelect() -> void:
	await onTransitionStart()
	
	ChampionSelectUI = ChampionSelectUIPacked.instantiate() # Necessary order
	ChampionSelectUI.back.connect(onUnloadChampionSelect)
	ChampionSelectUI.start_game.connect(onStartGame)
	load_champion_select.emit(ChampionSelectUI)
	
	await onTransitionMiddle()
	
	add_child(ChampionSelectUI)
	onTransitionEnd()
	
func onNewGamePressed() -> void:
	AniPlayer.play_backwards("SlideUIElements")
	onLoadChampionSelect()
	
func onUnloadChampionSelect() -> void:
	await onTransitionStart()
	await get_tree().process_frame
	World.onUnloadChampionSelect()
	
	ChampionSelectUI.queue_free()
	ChampionSelectUI = null
	
	await onTransitionMiddle()
	onTransitionEnd()
	
	AniPlayer.play("SlideUIElements")
	onLoadButtons(PLAY_BUTTON_NAMES, false)
	
func setChampionCards(champion_cards: Array) -> void:
	ChampionSelectUI.setChampionCards(champion_cards)
	
func onStartGame(champion_info: ChampionCardInfo) -> void:
	await onTransitionStart()
	await get_tree().process_frame
	start_game.emit(champion_info)

func onTransitionStart() -> void:
	FadeBackground.visible = true
	FadeBackground.modulate = Color(0, 0, 0, 0)
	
	var tween := create_tween()
	tween.tween_property(FadeBackground, "modulate:a", 1.0, FADE_BACKGROUND_TIME)
	await tween.finished
	
func onTransitionMiddle() -> void:
	await get_tree().create_timer(FADE_BACKGROUND_TIME).timeout
	
func onTransitionEnd() -> void:
	var tween: Tween = create_tween()
	tween.tween_property(FadeBackground, "modulate:a", 0.0, FADE_BACKGROUND_TIME)
	await tween.finished
#endregion

var LoadMenu: Control
func onLoadLoadMenu() -> void:
	LoadMenu = LoadMenuPacked.instantiate()
	LoadMenu.back.connect(onUnloadLoadMenu)
	LoadMenu.new_game.connect(onLoadChampionSelect)
	LoadMenu.load_game.connect(onLoadMenuContinue)
	add_child(LoadMenu)
	
	AniPlayer.play_backwards("SlideUIElements")
	
func onUnloadLoadMenu() -> void:
	LoadMenu = null
	AniPlayer.play("SlideUIElements")
	onLoadButtons(PLAY_BUTTON_NAMES, false)

func onContinue() -> void:
	var DIR_PATH: String = SaveFileInfo.SAVE_DIRECTORY
	var files: Array = Array(DirAccess.get_files_at(DIR_PATH))
	if files.is_empty(): return
	
	var time_values: Array = files.map(func(x: String): return FileAccess.get_modified_time(DIR_PATH + "/" + x))
	
	var recent_save_file_path: String = files[time_values.find(time_values.max())]
	var save_file_data: SavedDataSaveFile = load(DIR_PATH + recent_save_file_path)
	
	AniPlayer.play_backwards("SlideUIElements")
	await onTransitionStart()
	load_game.emit(save_file_data)

func onLoadMenuContinue(save_file_data: SavedDataSaveFile) -> void:
	await onTransitionStart()
	load_game.emit(save_file_data)
	
var pressable: bool
func setPressable(state: bool) -> void:
	pressable = state
	for MainMenuButton: Label in getMainMenuButtons():
		MainMenuButton.setPressable(state)

func getSelectedAreaID() -> int: return selected_area_id
