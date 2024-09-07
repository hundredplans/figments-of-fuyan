extends Node
@export var RichText: RichTextLabel

func _ready() -> void:
	if RichText: RichText.text = on_apply_text_processing(RichText.text)

func on_apply_text_processing(text: String) -> String:
	text = on_replace_att_hp_spd(text)
	text = on_color_words(text)
	text = on_bold_caps_words(text)
	text = on_color_card_names(text)
	
	text = text.insert(0, "[center]")
	text += "[/center]"
	
	for type in DirAccess.get_files_at("res://assets/base_game/cards/game_card/art/bbcode/"):
		text = on_add_bbcode_image(text, type.left(-4))
	return text

func on_add_bbcode_image(text: String, type: String) ->  String:
	return text.replace(type, "[img=14x14]res://assets/base_game/cards/game_card/art/bbcode/" + type + ".png[/img]")

var STAT_TO_INDEX: Array = ["ATTACK", "HEALTH", "SPEED"]
const CARD_TEXT_TO_COLOR: Dictionary = {
	"DMG": "navajo_white",
	"RANGED": "brown",	
	"GBONE": "papaya_whip",
	"BLOCK": "gray",
	"CARD_NAME": "slate_gray",
	"ATTACK": "orange",
	"HEALTH": "red",
	"SPEED": "green",
	"ENERGY": "yellow",
}

func on_bold_caps_words(text: String) -> String:
	var regex := RegEx.new()
	regex.compile(Helper.return_file_contents("res://assets/base_game/cards/game_card/art/bbcode/to_highlight.txt").replace("\n", ""))
	for result in regex.search_all(text):
		var on_replace: String = result.get_string()
		var replacement: String = ""
		
		replacement = "[b]" + on_replace + "[/b]"
		text = text.replace(on_replace, replacement)
	
	return text

func on_color_words(text: String) -> String:
	var regex := RegEx.new()
	regex.compile("((\\[[[0-9]\\]\\s)|[+-][0-9][\\s\\n])?(ENERGY|HEALTH|ATTACK|SPEED|DMG|GBONE|RANGED|BLOCK)(\\s\\[[0-9](-[0-9])?\\])?")
	for result in regex.search_all(text):
		var on_replace: String = result.get_string()
		var replacement: String = "[b][color=" + CARD_TEXT_TO_COLOR[on_replace.get_slice(" ", 1 if !(on_replace.contains("RANGED") or on_replace.contains("BLOCK")) else 0)] \
		+ "]" + on_replace + "[/color][/b]"
		text = text.replace(on_replace, replacement)
	return text
	
func on_color_card_names(text: String) -> String:
	var regex := RegEx.new()
	regex.compile("{[a-zA-Z\\s\\-0-9']*}")
	for result in regex.search_all(text):
		var on_replace: String = result.get_string()
		
		text = text.replace(on_replace, "[b][color=" + CARD_TEXT_TO_COLOR["CARD_NAME"] + "]" + \
		on_replace.substr(1, on_replace.length() - 2) + "[/color][/b]")
	return text

func on_replace_att_hp_spd(text: String) -> String:
	var regex := RegEx.new()
	regex.compile("\\[[+-]?-?[0-9]/-?[0-9]/*-?[0-9]*\\]")
	for result in regex.search_all(text):
		var stats: Array = Array(result.get_string().split("/", false)).map(func(x: String): return int(x))
		var replacement: String = ""
		
		for j in range(stats.size()):
			if stats[j] != 0:
				var replacement_operator: String = "+" if stats[j] > 0 else "-"
				replacement += replacement_operator + str(abs(stats[j])) + " " + STAT_TO_INDEX[j] + " "
		text = text.replace(result.get_string(), replacement)
	return text
