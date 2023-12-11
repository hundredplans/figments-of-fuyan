extends Node

func _ready() -> void:
	for file in DirAccess.get_files_at("res://static/base_game/cards/"):
		var dir: DirAccess = DirAccess.open("res://assets/base_game/cards/")
		dir.make_dir(file.left(-4))
