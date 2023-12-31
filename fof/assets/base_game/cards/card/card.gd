extends Control
var info: Dictionary

var Heroes: Node
@export var Art: Control
@export var Text: Control
@export var Stats: Control

func set_info(_info: Dictionary) -> void:
	info = _info
	for stat in ["a", "h", "s", "e"]:
		Stats.get_node(Helper.stat_ai_dict[stat] + "/Label").text = str(info[stat])
	
	Text.get_node("Text").text = info["text"]
	Text.get_node("Name").text = info["sname"]
	
	var hero_bgfn: String = info.bgfn if info.r != 7 else Helper.id_to_dict(Heroes.id_to_base(info.id), "Card").bgfn
	var texture_path: String = "res://assets/base_game/cards/card/default_art_max.png"
	var card_texture_path: String = "res://assets/base_game/cards/" + hero_bgfn + "/art_max.png"
	if FileAccess.file_exists(card_texture_path):
		texture_path = card_texture_path
	Art.get_node("ArtMax").texture = load(texture_path)
	Art.get_node("FrontCard").texture = load("res://assets/base_game/cards/card/rarity/" + str(info.r) + ".png")
