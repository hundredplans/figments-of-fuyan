extends Node3D

@onready var MapWorld: Node3D = %MapWorld

func setInfo(MinimapUI: Control) -> void:
	MapWorld.setInfo(Game.getSaveFile(), true)
	MinimapUI.exit.connect(onMinimapWorldExit)

func onMinimapWorldExit() -> void:
	queue_free()
