extends Control
const TID: int = 3
const FILE_LOADER_NAME: String = "Aura"
var rarity: int = 1

@onready var AuraText: TextEdit = $Contents/AuraText
@onready var FlavorText: TextEdit = $Contents/FlavorText

func _ready() -> void:
	on_modulate_rarity()

func _on_save_aura_pressed():
	var contents: String = "%s\n%s\n%s" % [rarity, AuraText.text.replace("\n", " "), FlavorText.text.replace("\n", " ")]
	Helper.create_base_game_id_dir(Helper.write_to_base_game_file(FILE_LOADER_NAME, $Contents/EditFileName, contents, TID), FILE_LOADER_NAME)

func _on_rarity_selector_item_selected(i: int): 
	rarity = i
	on_modulate_rarity()
	
func on_modulate_rarity() -> void:
	$Background/Inside.color = Helper.rarity_colors[rarity]
	$Background/Outside.color = Helper.rarity_accent_colors[rarity]

func _on_load_aura_pressed():
	var FileLoader: Control = preload("res://scenes/editor/file_loader/file_loader.tscn").instantiate()
	FileLoader.on_ready(FILE_LOADER_NAME)
	FileLoader.item_selected.connect(on_aura_selected)
	add_child(FileLoader)
	
func on_aura_selected(item_info: Dictionary) -> void:
	$Contents/EditFileName.set_text(item_info.iname, item_info.sname)
	AuraText.text = item_info.text
	FlavorText.text = item_info.flavor
	_on_rarity_selector_item_selected(item_info.r)
	$Contents/RaritySelector.select_item(item_info.r)
