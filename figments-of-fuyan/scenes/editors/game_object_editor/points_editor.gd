extends Node3D

var Model: Node3D
@onready var Ray: RayCast3D = $Ray
@export var Camera: Camera3D
func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("MainInput"):
		onSendRay()
		
func onSendRay() -> void:
	pass
