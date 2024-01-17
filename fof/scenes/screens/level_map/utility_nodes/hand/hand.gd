class_name HandGD
extends Node

var energy: int = 0

var SpectateCamera: Camera3D
var LevelUI: LevelUIGD
var History: HistoryGD
var GameState: GameStateGD

func on_draw_card(deck_card: DeckCardGD) -> void:
	on_create_card(deck_card.id, deck_card.tool_id, deck_card.effects)

func on_create_card(id: int, tool_id: int = 0, effects: Array = []) -> void:
	var card := HandCardGD.new()
	card.name = str(randi())
	card.script = preload("res://scenes/screens/level_map/utility_nodes/hand/hand_card.gd")
	add_child(card)
	
	card.History = History
	card.on_create_card(id, tool_id, effects)
	LevelUI.on_draw_card(card)

var card_selected_index: int
func on_card_selected(index: int) -> void:
	card_selected_index = index
	if index > -1:
		SpectateCamera.on_spectate("Spawn")
