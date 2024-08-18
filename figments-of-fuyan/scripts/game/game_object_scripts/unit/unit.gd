class_name UnitGD
extends GameObjectGD

#region Signals
signal mouse_entered
signal mouse_exited
#endregion

#region Base Functions
func _ready() -> void:
	for body in getStaticBodies():
		body.mouse_entered.connect(func(): mouse_entered.emit(self))
		body.mouse_exited.connect(func(): mouse_exited.emit(self))
#endregion

#region Setters
func setScale(_scale: Vector3) -> void:
	scale = _scale
	
func setScaleUniform(x: float) -> void:
	scale = Vector3(x, x, x)

func setDefaultCollisionLayers() -> void:
	for body in getStaticBodies(): body.collision_layer = 480
#endregion

#region Positions
func setMapPosition() -> void:
	position = Vector3((sqrt(3) * data.coords.x + sqrt(3) * data.coords.y * 0.5), data.coords.w * 0.6, data.coords.y * 3 / 2.0)
#endregion
