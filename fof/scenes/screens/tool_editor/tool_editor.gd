extends Control
signal fileloader_state
const TID: int = 3
const FILE_LOADER_NAME: String = "Tool"
var rarity: int = 1

@onready var UpgradedToolText: TextEdit = $Contents/UpgradedToolText
@onready var ToolText: TextEdit = $Contents/ToolText

func _ready() -> void:
	on_modulate_rarity()

func _on_save_tool_pressed():
	var contents: String = "%s\n%s\n%s" % [rarity, ToolText.text.replace("\n", " "), UpgradedToolText.text.replace("\n", " ")]
	Helper.create_base_game_id_dir(Helper.write_to_base_game_file(FILE_LOADER_NAME, $Contents/EditFileName, contents, TID), FILE_LOADER_NAME)

func _on_rarity_selector_item_selected(i: int): 
	rarity = i
	on_modulate_rarity()
	
func on_modulate_rarity() -> void:
	$Background/Inside.color = Helper.rarity_secondary_colors[rarity]
	$Background/Outside.color = Helper.rarity_secondary_accent_colors[rarity]

func _on_load_tool_pressed():
	var FileLoader: Control = preload("res://scenes/editor/file_loader/file_loader.tscn").instantiate()
	FileLoader.on_ready(FILE_LOADER_NAME)
	FileLoader.item_selected.connect(on_tool_selected)
	add_child(FileLoader)
	
func on_tool_selected(item_info: Dictionary) -> void:
	$Contents/EditFileName.set_text(item_info.iname, item_info.sname)
	ToolText.text = item_info.text
	UpgradedToolText.text = item_info.utext
	_on_rarity_selector_item_selected(item_info.r)
	$Contents/RaritySelector.select_item(item_info.r)

func _on_default_tool_pressed():
	rarity = 1
	$Contents/RaritySelector.select_item(1)
	$Contents/EditFileName.set_text("", "")
	ToolText.text = ""
	UpgradedToolText.text = ""
