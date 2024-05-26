extends Node3D

var type: String
func _ready() -> void:
	$AnimationPlayer.play("CocusPocusIdle")
