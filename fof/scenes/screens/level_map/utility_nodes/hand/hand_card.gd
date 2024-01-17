class_name HandCardGD
extends Node

var History: HistoryGD

var id: int = 0
var tool_id: int = 0
var effects: Array = []

func on_create_card(_id: int, _tool_id: int, _effects: Array) -> void:
	id = _id
	tool_id = _tool_id
	effects = _effects
	
	History.add_to_history(["create_hand_card", id, tool_id, effects])
