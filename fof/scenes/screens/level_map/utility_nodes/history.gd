class_name HistoryGD
extends Node

var GameState: Node
func on_load_world_history() -> void:
	var history: Array = GameState.history.duplicate()
	GameState.history = []
	for event in history:
		pass

func add_to_history(history_info: Array) -> void:
	GameState.history.append(history_info)
