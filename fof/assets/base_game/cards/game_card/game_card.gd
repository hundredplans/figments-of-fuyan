class_name GameCardGD
extends Control
var base_card: BaseCardGD

signal pressed
var past_is_hover: bool = false
var is_hover: bool = false

@export var EnergyLabel: Control
@export var RegularStats: HBoxContainer
@export var Art: Control
@export var Text: Control
@export var Stats: Control

func setText(text: String) -> void:
	Text.get_node("Text").text = base_card.text

func set_info(_base_card: Resource) -> void:
	base_card = _base_card
	for stat in ["attack", "health", "speed"]:
		RegularStats.get_node(stat.capitalize() + "Label").text = str(base_card[stat])
	EnergyLabel.text = str(base_card.energy)
	
	setText(base_card.text)
	Text.get_node("Name").text = base_card.name
	
	Art.get_node("CardButton").texture_normal = load("res://assets/base_game/cards/game_card/art/rarity/" + str(base_card.rarity) + ".png")
	Helper.create_button_clickmask(Art.get_node("CardButton"))
			
	$Art/ArtPop.texture = load("res://assets/base_game/cards/cards/" + base_card.folder_name + "/art_pop.png")

func set_tool(_tool_id: int) -> void:
	pass

func _on_front_card_mouse_entered(): if is_hover: modulate = Helper.LIGHT_GREY
func _on_front_card_mouse_exited(): if is_hover: modulate = Helper.BASE
func _on_front_card_pressed(): pressed.emit()

func on_set_disabled(state: bool) -> void:
	Art.get_node("CardButton").disabled = state
	modulate = Helper.BASE if !state else Helper.DARK_GREY
	is_hover = !state
