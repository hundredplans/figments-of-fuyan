class_name GameCardGD
extends Control
var info: Dictionary

signal pressed
var past_is_hover: bool = false
var is_hover: bool = false
var Heroes: HeroesGD

@export var EnergyLabel: Control
@export var RegularStats: HBoxContainer
@export var Art: Control
@export var Text: Control
@export var Stats: Control

func set_info(_info: Dictionary) -> void:
	info = _info
	for stat in ["a", "h", "s"]:
		RegularStats.get_node(Helper.stat_ai_dict[stat] + "Label").text = str(info[stat])
	EnergyLabel.text = str(info["e"])
	
	Text.get_node("Text").text = info.text.compiled
	Text.get_node("Name").text = info["sname"]
	
	Art.get_node("CardButton").texture_normal = load("res://assets/base_game/cards/game_card/rarity/" + str(info.r) + ".png")
	Helper.create_button_clickmask(Art.get_node("CardButton"))
			
	$Art/ArtPop.texture = load("res://assets/base_game/cards/" + info.bgfn + "/art_pop.png")

func set_tool(_tool_id: int) -> void:
	pass

func _on_front_card_mouse_entered(): if is_hover: modulate = Helper.LIGHT_GREY
func _on_front_card_mouse_exited(): if is_hover: modulate = Helper.BASE
func _on_front_card_pressed(): pressed.emit()

func on_set_disabled(state: bool) -> void:
	Art.get_node("CardButton").disabled = state
	modulate = Helper.BASE if !state else Helper.DARK_GREY
	is_hover = !state
