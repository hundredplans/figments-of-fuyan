extends Control
signal fileloader_state
const TID: int = 9
const FILE_LOADER_NAME: String = "Task"
var difficulty: int = 1

func _ready() -> void:
	on_set_difficulty(difficulty)

func on_set_difficulty(i: int) -> void:
	difficulty = i
	for button in $DifficultySelect.get_children():
		button.disabled = button.get_index() == i

func _on_save_task_pressed():
	var contents: String = "%s\n%s" % [$Contents/TaskText.text.replace("\n", " "), difficulty]
	Helper.create_base_game_id_dir(Helper.write_to_base_game_file(FILE_LOADER_NAME, $Contents/EditFileName, contents, TID), FILE_LOADER_NAME)

func _on_load_task_pressed():
	var FileLoader: Control = preload("res://scenes/editor/file_loader/file_loader.tscn").instantiate()
	FileLoader.on_ready(FILE_LOADER_NAME)
	FileLoader.item_selected.connect(on_load_task)
	add_child(FileLoader)

func on_load_task(item_info: Dictionary) -> void:
	$Contents/EditFileName.set_text(item_info.iname, item_info.sname)
	$Contents/TaskText.text = item_info.text
	on_set_difficulty(item_info.difficulty)

func _on_default_task_pressed():
	on_set_difficulty(1)
	$Contents/EditFileName.set_text("", "")
	$Contents/TaskText.text = ""
