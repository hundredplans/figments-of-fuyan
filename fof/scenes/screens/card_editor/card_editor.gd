extends Control

var old_stat_texts: Array = ["", "", "", ""]
func _ready():
	for child in $CardCreator/Stats.get_children():
		child.text_submitted.connect((func(_x: String, y: Node): y.release_focus()).bind(child))
		child.text_changed.connect(on_stat_text_changed.bind(child))

func on_stat_text_changed(text: String, node: LineEdit) -> void:
	if text != "" and !text.is_valid_int():
		node.text = old_stat_texts[node.get_index()]
	else:
		old_stat_texts[node.get_index()] = text

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
