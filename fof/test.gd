extends Node3D

@onready var ray = %RayCast3D
func _ready():
	ray.target_position = Vector3(0, -10, 0)
	ray.force_raycast_update()
	if ray.is_colliding(): print("Here")
