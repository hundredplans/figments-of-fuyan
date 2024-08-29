extends Node3D

func _ready() -> void:
	SavedData.onLoadModel(SavedData.new(1), self)
