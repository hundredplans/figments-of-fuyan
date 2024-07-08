extends UnitVFXBase

const SPIN_SPEED: int = 300
func _process(delta):
	rotation_degrees.y += SPIN_SPEED * delta
