extends MeshInstance3D

var GameObject: GameObjectGD
func _queue_free() -> void:
	GameObject.onRemovePoint(position)
	queue_free()
	
func setInfo(_GameObject: GameObjectGD) -> void:
	GameObject = _GameObject
