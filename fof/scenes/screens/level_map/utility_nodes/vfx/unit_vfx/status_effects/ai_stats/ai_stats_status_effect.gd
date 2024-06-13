extends Node3D

var Camera: Camera3D
var type: String
func setInfo(Unit: UnitGD, _Camera: Camera3D) -> void:
	Camera = _Camera
	setAIStats(Unit)

func setAIStats(Unit: UnitGD) -> void:
	for child in get_children():
		child.setInfo(Unit.ai[child.name])

func _process(_delta: float) -> void: look_at(Camera.position)
