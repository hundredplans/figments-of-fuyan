extends Control
signal fileloader_state
const TID: int = 7
const FILE_LOADER_NAME: String = "Challenge"

func _on_save_challenge_pressed():
	var contents: String = $Contents/ChallengeText.text.replace("\n", " ")
	Helper.create_base_game_id_dir(Helper.write_to_base_game_file(FILE_LOADER_NAME, $Contents/EditFileName, contents, TID), FILE_LOADER_NAME)
		
func _on_load_challenge_pressed():
	var FileLoader: Control = preload("res://scenes/editor/file_loader/file_loader.tscn").instantiate()
	FileLoader.on_ready(FILE_LOADER_NAME)
	FileLoader.item_selected.connect(on_load_challenge)
	add_child(FileLoader)

func _on_default_challenge_pressed():
	$Contents/EditFileName.set_text("", "")
	$Contents/ChallengeText.text = ""

func on_load_challenge(item_info: Dictionary) -> void:
	$Contents/EditFileName.set_text(item_info.iname, item_info.sname)
	$Contents/ChallengeText.text = item_info.text
