extends Control

signal load_world
var GameState: Node

func _ready() -> void:
	$SeedLabel.text = str(GameState.gseed)

func _queue_free() -> void: 
	if !GameState.is_inside_level:
		GameState.queue_free()
		load_world.emit(null)
