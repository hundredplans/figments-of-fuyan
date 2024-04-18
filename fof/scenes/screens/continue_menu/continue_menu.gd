extends Control

signal screen_change_sig
var _CRect: PackedScene = preload("res://scenes/screens/continue_menu/save_file_empty.tscn")
var _SaveFileButton: PackedScene = preload("res://scenes/screens/continue_menu/save_file_button.tscn")
func _ready() -> void:
	for i in range(1, 6):
		var contents: Dictionary = Helper.on_save_file_contents(i)
		if contents.is_empty():
			$SaveFiles.add_child(_CRect.instantiate())
		else:
			var SaveFileButton: Control = _SaveFileButton.instantiate()
			SaveFileButton.on_load_save_file(contents, Helper.getFofInfo(contents.area_id, "area"))
			SaveFileButton.get_node("RemoveButton").pressed.connect(_on_remove_button_pressed.bind(i))
			SaveFileButton.pressed.connect(on_save_file_pressed)
			$SaveFiles.add_child(SaveFileButton)

func on_save_file_pressed(index: int) -> void:
	Helper.on_load_game_state(index)
	
	if get_node("SaveFiles").get_child(index - 1).level_id == 0: screen_change_sig.emit("res://scenes/screens/map_menu/map_menu.tscn")
	else: screen_change_sig.emit("res://scenes/screens/level_ui/level_ui.tscn")
	

var save_file_index: int = 0
var _DeletePrompt: PackedScene = preload("res://scenes/editor/delete_prompt/delete_prompt.tscn")
func _on_remove_button_pressed(_save_file_index: int):
	save_file_index = _save_file_index
	var DeletePrompt: Control = _DeletePrompt.instantiate()
	DeletePrompt.delete_item.connect(on_delete_save_file)
	DeletePrompt.on_ready(1, "", true)
	add_child(DeletePrompt)
	DeletePrompt.global_position = Vector2(0, 0)

func on_delete_save_file() -> void:
	if Settings.clear_backup_files_array[Settings.clear_backup_files] != 0:
		Helper.write_to_file("user://save/temp/save_files/", str(randi()), ".txt",\
		Helper.return_file_contents("user://save/save_files/" + str(save_file_index) + ".txt"), false)
	Helper.delete_file("user://save/save_files/", str(save_file_index), ".txt")
	
	$SaveFiles.get_child(save_file_index - 1).queue_free()
	var CRect: Control = _CRect.instantiate()
	$SaveFiles.add_child(CRect)
	$SaveFiles.move_child(CRect, save_file_index - 1)
