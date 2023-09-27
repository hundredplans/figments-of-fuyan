extends Control

var rarity: int = 1
var stats: Array = [1,1,1,1]
var personality_sliders: Array = [1,1,1,1,1]

const TID: int = 2
const FILE_LOADER_NAME: String = "Card"
@export var CardText: TextEdit
@export var FlavorText: TextEdit

var old_stat_texts: Array = ["", "", "", ""]
func _ready():
	for child in $CardCreator/Stats.get_children():
		child.text_submitted.connect(on_stat_text_submitted.bind(child.get_index()))
		child.text_changed.connect(on_stat_text_changed.bind(child))

	for child in $AISettings.get_children():
		child.item_selected.connect(on_ai_settings_item_selected.bind(child.get_index()))

func on_ai_settings_item_selected(item: int, i: int) -> void:
	personality_sliders[i] = item

func on_stat_text_submitted(__: String, i: int) -> void:
	i = i + 1
	if i < 4:
		$CardCreator/Stats.get_child(i).grab_focus()
	else:
		$CardCreator/EditFileName/Internal.grab_focus()

func on_stat_text_changed(text: String, node: LineEdit) -> void:
	if text != "" and !text.is_valid_int():
		node.text = old_stat_texts[node.get_index()]
	else:
		old_stat_texts[node.get_index()] = text
		stats[node.get_index()] = int(node.text)
		
func on_stat_submitted(__: String):
	for child in $CardCreator/Stats.get_children():
		child.release_focus()

func _on_choose_rarity_item_selected(i: int):
	var rarity_colors: Dictionary = {
		0: "cbccd0",
		1: "67554d",
		2: "6de0ee",
		3: "ebdf60",
		4: "a001fb",
		5: "d72500",
		6: "00ea3d",
	}
	$CardCreator/RarityColor.color = rarity_colors[i]
	rarity = i

func _on_card_text_changed():
	if CardText.text.ends_with("\n"):
		CardText.text = CardText.text.left(-1)
		FlavorText.grab_focus()

func _on_flavor_text_changed():
	if FlavorText.text.ends_with("\n"):
		FlavorText.text = FlavorText.text.left(-1)
		FlavorText.release_focus()

func _on_edit_file_name_text_submitted():
	$CardCreator/CardText.grab_focus()

func _on_save_card_pressed():
	var contents: String = "%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s"\
	% [stats[0], stats[1], stats[2], stats[3], rarity, CardText.text, FlavorText.text,
	personality_sliders[0], personality_sliders[1], personality_sliders[2], personality_sliders[3], personality_sliders[4]]
	var item_dict: Dictionary = Helper.write_to_base_game_file(FILE_LOADER_NAME, $CardCreator/EditFileName, contents, TID)
	if item_dict and Settings.auto_create_dir == 1:
		DirAccess.make_dir_absolute("res://assets/base_game/cards/" + str(item_dict.id) + " - " + item_dict.iname)
