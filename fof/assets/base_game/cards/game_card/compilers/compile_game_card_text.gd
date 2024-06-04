class_name CompileGameCardTextGD
extends Node

@export var base_card: BaseCardGD

func _ready() -> void:
	onSaveApplyTextProcessing()
	
func onSaveApplyTextProcessing() -> void:
	if base_card != null:
		base_card.text = on_apply_text_processing(base_card.raw_text)
		ResourceSaver.save(base_card)

func setBaseCardFromGameCard(GameCard: GameCardGD) -> void:
	if GameCard != null:
		base_card = GameCard.base_card
		onSaveApplyTextProcessing()

func on_apply_text_processing(text: String) -> String:
	text = on_replace_att_hp_spd(text)
	text = on_color_words(text)
	text = on_bold_caps_words(text)
	text = on_color_card_names(text)
	
	text = text.insert(0, "[center]")
	text += "[/center]"
	
	for type in DirAccess.get_files_at("res://assets/base_game/cards/game_card/art/bbcode/"):
		text = on_add_bbcode_image(text, type.left(-4))
	
	text = on_replace_ability_names(text)
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
	"Spawn Tile": "green",
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
	regex.compile("((\\[[[0-9]\\]\\s)|[+-][0-9][\\s\\n])?(ENERGY|HEALTH|ATTACK|SPEED|DMG|GBONE|RANGED|BLOCK|Spawn Tile)(\\s\\[[0-9](-[0-9])?\\])?")
	for result in regex.search_all(text):
		var on_replace: String = result.get_string()
		var to_replace: String = on_replace
		if to_replace != "Spawn Tile":
			to_replace = on_replace.get_slice(" ", 1 if !(on_replace.contains("RANGED") or on_replace.contains("BLOCK")) else 0)
		var replacement: String = "[b][color=" + CARD_TEXT_TO_COLOR[to_replace]+ "]" + on_replace + "[/color][/b]"
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

func on_replace_ability_names(text: String) -> String:
	var ability_indexes: Dictionary = {}
	var regex := RegEx.new()
	regex.compile("\\$[a-zA-Z\\s]*")
	
	for result in regex.search_all(text):
		var result_str: String = result.get_string()
		var index: int = text.find(result_str) + result_str.length()
		ability_indexes[result_str.substr(1)] = index - result_str.length()
		text = text.replace(result_str, "")
	
	var DIR_PATH: String = "res://assets/base_game/cards/cards/" + base_card.folder_name + "/abilities/"
	if DirAccess.dir_exists_absolute(DIR_PATH):
		var ability_regex := RegEx.new()
		ability_regex.compile("\\[img=[0-9][0-9]x[0-9][0-9]\\]")
		for ability_name in Array(DirAccess.get_files_at(DIR_PATH)).filter(func(x: String): return x.ends_with(".tres")):
			var ability: AbilityGD = load(DIR_PATH + ability_name)
			if ability is TargetAbilityGD and !ability.ability_description.is_empty():
				var ability_description_big: String = ability.ability_description
				for result in ability_regex.search_all(ability_description_big):
					ability_description_big = ability_description_big.replace(result.get_string(), "[img=28x28]")
				ability.ability_description_big = ability_description_big
				ResourceSaver.save(ability)
				
			if ability.max_charges != -1:
				ability.ability_index = ability_indexes[ability.ability_name]
				ResourceSaver.save(ability)
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
