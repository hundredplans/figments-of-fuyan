extends GPUParticles3D
var SpectateCamera: Node3D

func _on_finished(): queue_free()
func _process(_delta: float) -> void:
	look_at(SpectateCamera.global_position)
