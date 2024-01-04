extends Control
signal fileloader_state
const TID: int = 10
const FILE_LOADER_NAME: String = "Encounter"
var option_amount: int = 0

func _ready() -> void:
	on_reload_option_amount(1)
	
func on_reload_option_amount(i: int) -> void:
	option_amount = clamp(option_amount + i, 1, 5)
	
	$EncounterOptionSettings/Amount.text = str(option_amount)
	$EncounterOptionSettings/ModifyButtons/MinusButton.disabled = option_amount == 1
	$EncounterOptionSettings/ModifyButtons/AddButton.disabled = option_amount == 5
	
	if i > 0:
		for __ in range(i):
			var tedit := TextEdit.new()
			$EncounterOptions.add_child(tedit)
			tedit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			tedit.placeholder_text = "Write option text here!"
	elif i < 0: $EncounterOptions.get_child($EncounterOptions.get_child_count() - 1).queue_free()


func _on_save_encounter_pressed():
	if $EncounterOptions.get_children().all(func(x: TextEdit): return x.text.length() > 0):
		var contents: String = "%s\n%s" % [$Contents/EncounterText.text.replace("\n", " "), $EncounterOptions.get_children().map(func(x: TextEdit): return x.text)]
		Helper.create_base_game_id_dir(Helper.write_to_base_game_file(FILE_LOADER_NAME, $Contents/EditFileName, contents, TID), FILE_LOADER_NAME)
	else:
		AudioMaster.play_sfx("unconfirm_default")
		print_debug("One of your text boxes is empty!")
		
func _on_load_encounter_pressed():
	var FileLoader: Control = preload("res://scenes/editor/file_loader/file_loader.tscn").instantiate()
	FileLoader.on_ready(FILE_LOADER_NAME)
	FileLoader.item_selected.connect(on_encounter_selected)
	add_child(FileLoader)
	
func on_encounter_selected(item_info: Dictionary) -> void:
	$Contents/EditFileName.set_text(item_info.iname, item_info.sname)
	$Contents/EncounterText.text = item_info.text
	for child in $EncounterOptions.get_children(): child.free()
	option_amount = 0
	on_reload_option_amount(item_info.options.size())
	
	for i in range($EncounterOptions.get_child_count()):
		$EncounterOptions.get_child(i).text = item_info.options[i]

func _on_default_encounter_pressed():
	for child in $EncounterOptions.get_children(): child.queue_free()
	option_amount = 0
	on_reload_option_amount(1)
	
	$Contents/EditFileName.set_text("", "")
	$Contents/EncounterText.text = ""
