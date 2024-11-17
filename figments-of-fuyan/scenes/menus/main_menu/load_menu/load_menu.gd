extends Control
signal load_game

@export var save_file_ui_packed: PackedScene
@onready var QuitButton: Button = %QuitButton
@onready var MainContainer: VBoxContainer = %MainContainer
const DIR_PATH: String = SaveFileInfo.SAVE_DIRECTORY
func _ready() -> void:
	var files: Array = Array(DirAccess.get_files_at(DIR_PATH))
	if !files.is_empty():
		var saves: Array = files.map(func(x: String): return load(DIR_PATH + x))
		saves.sort_custom(func(x: SavedDataSaveFile, y: SavedDataSaveFile): return x.id < y.id)
		
		for save in saves:
			var save_file_ui: Control = save_file_ui_packed.instantiate()
			MainContainer.add_child(save_file_ui)
			save_file_ui.setInfo(save)
			save_file_ui.remove_save.connect(onRemoveSave)
			save_file_ui.start.connect(onStart)
		MainContainer.move_child(QuitButton, MainContainer.get_child_count() - 1)

func _on_quit_button_pressed() -> void:
	queue_free()
	
func onRemoveSave(save_file_data: SavedDataSaveFile) -> void:
	DirAccess.remove_absolute(save_file_data.resource_path)
	if Array(DirAccess.get_files_at(DIR_PATH)).is_empty(): queue_free()

func onStart(save_file_data: SavedDataSaveFile) -> void:
	load_game.emit(save_file_data)
