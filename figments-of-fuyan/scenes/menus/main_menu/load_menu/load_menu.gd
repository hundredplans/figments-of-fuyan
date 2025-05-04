extends Control

signal new_game
signal load_game
signal mouse_in_ui
signal remove_save
signal back

const FADE_BACKGROUND_TIME: float = 0.25

@export var save_file_ui_packed: PackedScene
@onready var FadeBackground: Control = %FadeBackground
@onready var BackButton: Control = %BackButton
@onready var MainContainer: VBoxContainer = %MainContainer
@onready var AniPlayer: AnimationPlayer = %AniPlayer

var pressable: bool = true
const DIR_PATH: String = SaveFileInfo.SAVE_DIRECTORY
func _ready() -> void:
	var files: Array = Array(DirAccess.get_files_at(DIR_PATH))
	var saves: Array = files.map(func(x: String): return load(DIR_PATH + x))
	saves.sort_custom(func(x: SavedDataSaveFile, y: SavedDataSaveFile): return x.id < y.id)
	
	for i in range(Helper.SAVE_FILE_MAX_AMOUNT):
		var save_file_data: SavedDataSaveFile = saves[i] if i < saves.size() else null
		var save_file_ui: Control = save_file_ui_packed.instantiate()
		MainContainer.add_child(save_file_ui)
		save_file_ui.setInfo(save_file_data)
		save_file_ui.remove_save.connect(onRemoveSave)
		save_file_ui.save_file_pressed.connect(onSaveFilePressed)
		save_file_ui.mouse_in_ui.connect(onMouseInUI)
	MainContainer.move_child(BackButton, MainContainer.get_child_count() - 1)
	AniPlayer.play("SlideUIElements")
	
func onRemoveSave(save_file_data: SavedDataSaveFile) -> void:
	DirAccess.remove_absolute(save_file_data.resource_path)
	remove_save.emit()

func onSaveFilePressed(save_file_data: SavedDataSaveFile) -> void:
	if save_file_data != null: load_game.emit(save_file_data)
	else: new_game.emit()
	setPressable(false)
	queue_free()

func onMouseInUI(state: bool) -> void:
	mouse_in_ui.emit(state)

func onBackButtonPressed() -> void:
	AniPlayer.play_backwards("SlideUIElements")
	back.emit()
	setPressable(false)
	await AniPlayer.animation_finished
	queue_free()
	
func setPressable(_pressable: bool) -> void:
	pressable = _pressable
	for btn: Control in get_tree().get_nodes_in_group("SceneButtons"):
		btn.setPressable(pressable)
	
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("Back") and pressable:
		onBackButtonPressed()
