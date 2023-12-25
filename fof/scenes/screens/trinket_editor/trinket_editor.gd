extends Control
signal fileloader_state
const TID: int = 6
const FILE_LOADER_NAME: String = "Trinket"


func _on_save_trinket_pressed():
	var contents: String = $Contents/TrinketText.text.replace("\n", " ")
	Helper.create_base_game_id_dir(Helper.write_to_base_game_file(FILE_LOADER_NAME, $Contents/EditFileName, contents, TID), FILE_LOADER_NAME)

func _on_load_trinket_pressed():
	var FileLoader: Control = preload("res://scenes/editor/file_loader/file_loader.tscn").instantiate()
	FileLoader.on_ready(FILE_LOADER_NAME)
	FileLoader.item_selected.connect(on_load_trinket)
	add_child(FileLoader)

func on_load_trinket(trinket_info: Dictionary) -> void:
	$Contents/EditFileName.set_text(trinket_info.iname, trinket_info.sname)
	$Contents/TrinketText.text = trinket_info.text

func _on_default_trinket_pressed():
	$Contents/EditFileName.set_text("", "")
	$Contents/TrinketText.text = ""
