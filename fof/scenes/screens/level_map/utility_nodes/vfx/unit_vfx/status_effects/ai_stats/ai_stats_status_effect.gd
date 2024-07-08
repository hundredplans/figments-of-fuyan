extends UnitVFXBase

var Camera: Camera3D
func setInfo(Unit: UnitGD, _Camera: Camera3D) -> void:
	Camera = _Camera
	setAIStats(Unit)

func setAIStats(Unit: UnitGD) -> void:
	for child in get_children():
		child.setInfo(Unit.ai[child.name])

func _process(_delta: float) -> void: look_at(Camera.position)
