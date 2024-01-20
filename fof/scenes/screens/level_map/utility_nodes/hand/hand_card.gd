class_name HandCardGD
extends Node

var id: int = 0
var energy: int = 0
var tool_id: int = 0
var effects: Array = []

func on_create_card(_id: int, _tool_id: int, _effects: Array) -> void:
	id = _id
	tool_id = _tool_id
	effects = _effects
	
	energy = Helper.id_to_dict(id, "Card").e
